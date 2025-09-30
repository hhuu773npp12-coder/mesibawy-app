import 'dart:async';
import 'package:flutter/material.dart';
import 'citizen_craft_api.dart';

class CraftRequestFollowUpScreen extends StatefulWidget {
  const CraftRequestFollowUpScreen({super.key, required this.jobId, required this.role, required this.title});
  final String jobId;
  final String role; // electrician | plumber | ac_tech | blacksmith
  final String title;

  @override
  State<CraftRequestFollowUpScreen> createState() => _CraftRequestFollowUpScreenState();
}

class _CraftRequestFollowUpScreenState extends State<CraftRequestFollowUpScreen> {
  final _api = CitizenCraftApi();
  Map<String, dynamic>? _job;
  bool _loading = false;
  Timer? _poll;

  @override
  void initState() {
    super.initState();
    _fetch();
    _poll = Timer.periodic(const Duration(seconds: 10), (_) => _fetch());
  }

  @override
  void dispose() {
    _poll?.cancel();
    super.dispose();
  }

  Future<void> _fetch() async {
    setState(() => _loading = true);
    try {
      final res = await _api.getOne(widget.jobId);
      setState(() => _job = (res.data as Map<String, dynamic>));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _addHours() async {
    final ctrl = TextEditingController(text: '1');
    final h = await showDialog<int>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('إضافة وقت إضافي'),
        content: TextField(
          controller: ctrl,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'عدد الساعات'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء')),
          FilledButton(onPressed: () => Navigator.pop(ctx, int.tryParse(ctrl.text.trim()) ?? 0), child: const Text('تأكيد')),
        ],
      ),
    );
    if (h == null || h <= 0) return;
    await _api.addHours(widget.jobId, h);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تمت إضافة الوقت')));
    await _fetch();
  }

  Future<void> _cancel() async {
    await _api.cancel(widget.jobId);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم إلغاء الطلب')));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final job = _job;
    final status = job?['status']?.toString() ?? '—';
    final timer = (job?['timerSecondsLeft'] as num?)?.toInt();
    final craftsmanName = job?['craftsmanName']?.toString();
    final craftsmanPhone = job?['craftsmanPhone']?.toString();
    final canCancel = status != 'IN_PROGRESS' && status != 'COMPLETED' && status != 'REJECTED';

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: Text('متابعة - ${widget.title}'),
          actions: [
            IconButton(onPressed: _loading ? null : _fetch, icon: const Icon(Icons.refresh), tooltip: 'تحديث')
          ],
        ),
        body: _loading && job == null
            ? const Center(child: CircularProgressIndicator())
            : Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (job != null) ...[
                      Text('الحالة: $status'),
                      if (timer != null) Text('الوقت المتبقي (ث): $timer'),
                      const SizedBox(height: 8),
                      Text('العنوان: ${job['address'] ?? '—'}'),
                      if ((job['detail']?.toString().isNotEmpty ?? false)) Text('التفاصيل: ${job['detail']}'),
                      const SizedBox(height: 8),
                      Text('الساعات المطلوبة: ${job['hoursRequested']} + الإضافية: ${job['hoursAdded']}'),
                      Text('السعر/ساعة: ${job['pricePerHour']} د.ع'),
                      const SizedBox(height: 12),
                      if (craftsmanName != null || craftsmanPhone != null)
                        Card(
                          color: Colors.green.withOpacity(0.06),
                          child: ListTile(
                            leading: const Icon(Icons.engineering_outlined),
                            title: Text(craftsmanName ?? '—'),
                            subtitle: Text(craftsmanPhone ?? '—'),
                          ),
                        ),
                    ],
                    const Spacer(),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        FilledButton.icon(onPressed: _addHours, icon: const Icon(Icons.more_time_outlined), label: const Text('إضافة وقت إضافي')),
                        OutlinedButton.icon(onPressed: _loading ? null : _fetch, icon: const Icon(Icons.refresh), label: const Text('تحديث')),
                        OutlinedButton.icon(onPressed: canCancel ? _cancel : null, icon: const Icon(Icons.cancel_outlined), label: const Text('إلغاء الطلب')),
                      ],
                    )
                  ],
                ),
              ),
      ),
    );
  }
}
