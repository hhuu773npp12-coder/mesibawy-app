import 'dart:async';
import 'package:flutter/material.dart';
import '../common/profile_screen.dart';
import '../common/wallet_screen.dart';
import '../common/notifications_screen.dart';
import '../citizen/energy_offers_screen.dart';
import 'craft_api.dart';

class CraftHomeBaseScreen extends StatefulWidget {
  const CraftHomeBaseScreen({super.key, required this.role, required this.title});
  final String role; // electrician | plumber | blacksmith | ac_tech
  final String title;

  @override
  State<CraftHomeBaseScreen> createState() => _CraftHomeBaseScreenState();
}

class _CraftHomeBaseScreenState extends State<CraftHomeBaseScreen> {
  final _api = CraftApi();
  bool _active = true;
  bool _loading = false;
  List<dynamic> _jobs = [];
  Timer? _poll;
  Timer? _ticker; // 1s UI countdown
  final Map<String, int> _localSeconds = {}; // jobId -> seconds left (UI only)

  @override
  void initState() {
    super.initState();
    _fetch();
    _poll = Timer.periodic(const Duration(seconds: 10), (_) => _fetch());
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
  }

  @override
  void dispose() {
    _poll?.cancel();
    _ticker?.cancel();
    super.dispose();
  }

  Future<void> _fetch() async {
    if (!_active) return;
    setState(() => _loading = true);
    try {
      final res = await _api.listJobs(role: widget.role);
      final list = (res.data as List);
      setState(() {
        _jobs = list;
        // sync local seconds map with server values
        for (final e in list) {
          final m = Map<String, dynamic>.from(e as Map);
          final id = m['id']?.toString();
          final sec = (m['timerSecondsLeft'] as num?)?.toInt();
          if (id != null && sec != null) {
            _localSeconds[id] = sec;
          }
        }
      });
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _tick() {
    if (!mounted) return;
    bool changed = false;
    for (final e in _jobs) {
      final m = Map<String, dynamic>.from(e as Map);
      final id = m['id']?.toString();
      final status = m['status']?.toString();
      if (id == null) continue;
      if (status == 'IN_PROGRESS') {
        final cur = _localSeconds[id] ?? (m['timerSecondsLeft'] as num?)?.toInt() ?? 0;
        if (cur > 0) {
          _localSeconds[id] = cur - 1;
          changed = true;
        }
      }
    }
    if (changed) setState(() {});
  }

  Future<void> _accept(String id) async {
    await _api.accept(id);
    await _fetch();
  }

  Future<void> _reject(String id) async {
    await _api.reject(id);
    await _fetch();
  }

  Future<void> _start(String id) async {
    await _api.start(id);
    await _fetch();
  }

  Future<void> _pause(String id) async {
    await _api.pause(id);
    await _fetch();
  }

  Future<void> _resume(String id) async {
    await _api.resume(id);
    await _fetch();
  }

  Future<void> _addHours(String id) async {
    final ctrl = TextEditingController(text: '1');
    final hours = await showDialog<double>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('إضافة ساعات'),
        content: TextField(
          controller: ctrl,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'عدد الساعات'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء')),
          FilledButton(onPressed: () => Navigator.pop(ctx, double.tryParse(ctrl.text.trim()) ?? 0), child: const Text('تأكيد')),
        ],
      ),
    );
    if (hours == null || hours <= 0) return;
    await _api.addHours(id, hours);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تمت الإضافة')));
    await _fetch();
  }

  Future<void> _complete(String id) async {
    await _api.complete(id);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم إكمال الطلب (خصم 10%)')));
    await _fetch();
  }

  Future<void> _notify(String id, String message) async {
    await _api.notifyUser(id, message);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم إرسال الإشعار')));
  }

  String _formatSeconds(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  void _openFollowUp(Map<String, dynamic> job) {
    final id = job['id']?.toString() ?? '';
    final status = job['status']?.toString() ?? '';
    final seconds = _localSeconds[id] ?? (job['timerSecondsLeft'] as num?)?.toInt();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => SafeArea(
        child: Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            bottom: 16 + MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('متابعة الطلب: ${job['citizenName'] ?? ''}', style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              if (seconds != null) Text('الوقت المتبقي (ثانية): $seconds'),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  FilledButton(onPressed: (status == 'ACCEPTED' || status == 'PAUSED') ? () => _start(id) : null, child: const Text('بدء العمل')),
                  OutlinedButton(onPressed: status == 'IN_PROGRESS' ? () => _pause(id) : null, child: const Text('إيقاف مؤقت')),
                  OutlinedButton(onPressed: status == 'PAUSED' ? () => _resume(id) : null, child: const Text('استئناف')),
                  OutlinedButton(onPressed: () => _addHours(id), child: const Text('إضافة ساعات')),
                  FilledButton(onPressed: () => _complete(id), child: const Text('تم الطلب')),
                ],
              ),
              const SizedBox(height: 12),
              const Text('إشعارات سريعة'),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  OutlinedButton(onPressed: () => _notify(id, 'الحِرفي في باب المنزل'), child: const Text('الحِرفي في باب المنزل')),
                  OutlinedButton(onPressed: () => _notify(id, 'تم بدء العمل'), child: const Text('تم بدء العمل')),
                  OutlinedButton(onPressed: () => _notify(id, 'جارٍ التهيئة / التوصيل'), child: const Text('جارٍ التهيئة / التوصيل')),
                  OutlinedButton(onPressed: () => _notify(id, 'سأصل خلال 10 دقائق'), child: const Text('سأصل خلال 10 دقائق')),
                  OutlinedButton(onPressed: () => _notify(id, 'تم الانتهاء وسيتم التسليم'), child: const Text('تم الانتهاء')),
                ],
              ),
            ],
          ),
        ),
      ),
    ).whenComplete(_fetch);

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: Text('مسيباوي - ${widget.title}') ,
          actions: [
            IconButton(
              tooltip: 'عروض الطاقة',
              icon: const Icon(Icons.solar_power),
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const EnergyOffersScreen())),
            ),
            IconButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen())), icon: const Icon(Icons.person_outline), tooltip: 'الملف الشخصي'),
            IconButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const WalletScreen())), icon: const Icon(Icons.account_balance_wallet_outlined), tooltip: 'المحفظة'),
            IconButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationsScreen())), icon: const Icon(Icons.notifications_none), tooltip: 'الإشعارات'),
          ],
        ),
        body: SafeArea(
          child: Column(
          children: [
            SwitchListTile(
              title: const Text('نشط لاستقبال الطلبات'),
              value: _active,
              onChanged: (v) {
                setState(() => _active = v);
                if (v) _fetch();
              },
            ),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.separated(
                      itemCount: _jobs.length,
                      itemBuilder: (_, i) {
                        final j = _jobs[i] as Map<String, dynamic>;
                        final id = j['id']?.toString() ?? '';
                        final status = j['status']?.toString() ?? '';
                        final sec = _localSeconds[id] ?? (j['timerSecondsLeft'] as num?)?.toInt();
                        final subtitle = 'الهاتف: ${j['citizenPhone'] ?? ''} • العنوان: ${j['address'] ?? ''}\nالساعات: ${j['hoursRequested']} + ${j['hoursAdded']} • السعر/ساعة: ${j['pricePerHour']}';
                        return Card(
                          child: ListTile(
                            title: Text(j['citizenName']?.toString() ?? 'مواطن'),
                            subtitle: Text(sec != null ? '$subtitle\nالمتبقي (ث): ${_formatSeconds(sec)}' : subtitle),
                            isThreeLine: true,
                            trailing: Wrap(
                              spacing: 6,
                              children: [
                                if (status == 'PENDING') ...[
                                  IconButton(onPressed: () => _accept(id), icon: const Icon(Icons.check_circle, color: Colors.green)),
                                  IconButton(onPressed: () => _reject(id), icon: const Icon(Icons.cancel, color: Colors.red)),
                                ] else ...[
                                  Text(status, style: const TextStyle(fontSize: 12)),
                                  TextButton(onPressed: () => _openFollowUp(j), child: const Text('متابعة')),
                                ]
                              ],
                            ),
                          ),
                        );
                      },
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                    ),
            ),
          ],
        ),
        ),
      ),
    );
  }
}
