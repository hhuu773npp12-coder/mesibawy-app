import 'package:flutter/material.dart';
import 'admin_api.dart';

class CampaignsTab extends StatefulWidget {
  const CampaignsTab({super.key});

  @override
  State<CampaignsTab> createState() => _CampaignsTabState();
}

class _CampaignsTabState extends State<CampaignsTab> {
  final _api = AdminApi();
  bool _loading = false;
  List<dynamic> _items = [];
  List<dynamic> _bookings = [];
  String? _bookingsForId;

  final _titleCtrl = TextEditingController();
  final _originCtrl = TextEditingController();
  final _seatsCtrl = TextEditingController(text: '40');
  final _priceCtrl = TextEditingController(text: '8000');

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _originCtrl.dispose();
    _seatsCtrl.dispose();
    _priceCtrl.dispose();
    super.dispose();
  }

  Future<void> _fetch() async {
    setState(() => _loading = true);
    try {
      final res = await _api.listCampaigns();
      setState(() => _items = (res.data as List));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _fetchBookings(String campaignId) async {
    setState(() {
      _bookingsForId = campaignId;
      _bookings = [];
    });
    try {
      final res = await _api.listCampaignBookings(campaignId);
      setState(() => _bookings = (res.data as List));
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('فشل تحميل الحجوزات')));
    }
  }

  Future<void> _book(String campaignId) async {
    final ctrl = TextEditingController();
    final userId = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('حجز مقعد'),
        content: TextField(
          controller: ctrl,
          decoration: const InputDecoration(hintText: 'أدخل userId'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, ctrl.text.trim()),
            child: const Text('تأكيد'),
          ),
        ],
      ),
    );
    if (userId == null || userId.isEmpty) return;
    try {
      await _api.bookCampaign(campaignId: campaignId, userId: userId);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('تم الحجز')));
      await _fetch();
      if (_bookingsForId == campaignId) {
        await _fetchBookings(campaignId);
      }
    } catch (_) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('فشل الحجز')));
    }
  }

  Future<void> _create() async {
    try {
      await _api.createCampaign(
        title: _titleCtrl.text.trim(),
        originArea: _originCtrl.text.trim(),
        seatsTotal: int.tryParse(_seatsCtrl.text.trim()) ?? 1,
        pricePerSeat: int.tryParse(_priceCtrl.text.trim()) ?? 0,
      );
      _titleCtrl.clear();
      _originCtrl.clear();
      await _fetch();
    } catch (_) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('فشل إنشاء الحملة')));
    }
  }

  Future<void> _share(String id) async {
    try {
      await _api.shareCampaign(id);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم تجهيز المشاركة (placeholder)')),
      );
    } catch (_) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('فشل المشاركة')));
    }
  }

  // إضافة دالة اختيار الدور
  Future<String?> _pickRole(BuildContext context) async {
    const roles = [
      'taxi',
      'tuk_tuk',
      'kia_passenger',
      'kia_haml',
      'stuta',
      'bike',
      'electrician',
      'plumber',
      'blacksmith',
      'ac_tech',
    ];

    return showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('اختر فئة للإشعار'),
        content: SizedBox(
          width: 320,
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: roles
                .map(
                  (r) => OutlinedButton(
                    onPressed: () => Navigator.pop(ctx, r),
                    child: Text(r),
                  ),
                )
                .toList(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('إلغاء'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // مدخلات إنشاء الحملة
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              SizedBox(
                width: 180,
                child: TextField(
                  controller: _titleCtrl,
                  decoration: const InputDecoration(labelText: 'عنوان الحملة'),
                ),
              ),
              SizedBox(
                width: 180,
                child: TextField(
                  controller: _originCtrl,
                  decoration: const InputDecoration(
                    labelText: 'منطقة الانطلاق',
                  ),
                ),
              ),
              SizedBox(
                width: 120,
                child: TextField(
                  controller: _seatsCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'المقاعد'),
                ),
              ),
              SizedBox(
                width: 120,
                child: TextField(
                  controller: _priceCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'السعر/راكب'),
                ),
              ),
              ElevatedButton(onPressed: _create, child: const Text('إنشاء')),
              ElevatedButton(onPressed: _fetch, child: const Text('تحديث')),
            ],
          ),
        ),
        // قائمة الحملات
        Expanded(
          child: _loading
              ? const Center(child: CircularProgressIndicator())
              : ListView.separated(
                  itemCount: _items.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (_, i) {
                    final it = _items[i] as Map<String, dynamic>;
                    final seatsTotal = it['seatsTotal'] ?? 0;
                    final seatsBooked = it['seatsBooked'] ?? 0;
                    final remaining =
                        (seatsTotal as int) - (seatsBooked as int);
                    final id = it['id'].toString();
                    return ListTile(
                      title: Text(it['title']?.toString() ?? ''),
                      subtitle: Text(
                        'الانطلاق: ${it['originArea']} • المقاعد: $seatsTotal • المتبقي: $remaining • السعر: ${it['pricePerSeat']}',
                      ),
                      trailing: Wrap(
                        spacing: 8,
                        children: [
                          TextButton(
                            onPressed: () => _share(id),
                            child: const Text('مشاركة'),
                          ),
                          TextButton(
                            onPressed: () => _fetchBookings(id),
                            child: const Text('الحجوزات'),
                          ),
                          ElevatedButton(
                            onPressed: () => _book(id),
                            child: const Text('حجز'),
                          ),
                          OutlinedButton(
                            onPressed: () async {
                              final role = await _pickRole(context);
                              if (role == null) return;
                              final titleCtrl = TextEditingController(
                                text: 'حملة زيارة جديدة',
                              );
                              final msgCtrl = TextEditingController(
                                text:
                                    'العنوان: ${it['title']} — الانطلاق: ${it['originArea']}',
                              );
                              final ok = await showDialog<bool>(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                  title: const Text('إرسال إشعار'),
                                  content: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      TextField(
                                        controller: titleCtrl,
                                        decoration: const InputDecoration(
                                          labelText: 'العنوان',
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      TextField(
                                        controller: msgCtrl,
                                        decoration: const InputDecoration(
                                          labelText: 'الرسالة',
                                        ),
                                      ),
                                    ],
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(ctx, false),
                                      child: const Text('إلغاء'),
                                    ),
                                    FilledButton(
                                      onPressed: () => Navigator.pop(ctx, true),
                                      child: const Text('إرسال'),
                                    ),
                                  ],
                                ),
                              );
                              if (ok == true) {
                                try {
                                  await _api.notifyByTags(
                                    tags: [
                                      {
                                        'key': 'role',
                                        'relation': '=',
                                        'value': role,
                                      },
                                    ],
                                    title: titleCtrl.text.trim(),
                                    message: msgCtrl.text.trim(),
                                    data: {
                                      'kind': 'campaign_share',
                                      'campaignId': id,
                                    },
                                  );
                                  if (!mounted) return;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('تم إرسال الإشعار'),
                                    ),
                                  );
                                } catch (_) {
                                  if (!mounted) return;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('فشل إرسال الإشعار'),
                                    ),
                                  );
                                }
                              }
                            },
                            child: const Text('إشعار'),
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),
        // قائمة الحجوزات
        if (_bookingsForId != null)
          Container(
            height: 220,
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              border: const Border(top: BorderSide(color: Colors.black12)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('حجوزات الحملة: ${_bookingsForId!}'),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => setState(() => _bookingsForId = null),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: _bookings.isEmpty
                      ? const Center(child: Text('لا توجد حجوزات'))
                      : ListView.separated(
                          itemCount: _bookings.length,
                          separatorBuilder: (_, __) => const Divider(height: 1),
                          itemBuilder: (_, i) {
                            final b = _bookings[i] as Map<String, dynamic>;
                            final u = b['user'] as Map<String, dynamic>?;
                            return ListTile(
                              dense: true,
                              title: Text(
                                u != null
                                    ? (u['name'] ?? u['phone'] ?? '')
                                    : 'مستخدم',
                              ),
                              subtitle: Text(
                                'الحالة: ${b['status']} • ${b['createdAt'] ?? ''}',
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
