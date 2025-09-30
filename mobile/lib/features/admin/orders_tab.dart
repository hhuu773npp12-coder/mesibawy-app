import 'package:flutter/material.dart';
import 'admin_api.dart';

class OrdersTab extends StatefulWidget {
  const OrdersTab({super.key});

  @override
  State<OrdersTab> createState() => _OrdersTabState();
}

class _OrdersTabState extends State<OrdersTab> {
  final _api = AdminApi();
  bool _loading = false;
  List<dynamic> _items = [];
  String? _category;
  String? _status;
  final _dateFromCtrl = TextEditingController();
  final _dateToCtrl = TextEditingController();
  final _limitCtrl = TextEditingController(text: '100');

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  Future<void> _fetch() async {
    setState(() => _loading = true);
    try {
      final res = await _api.listAdminOrders(
        limit: int.tryParse(_limitCtrl.text.trim()),
        category: _category,
        status: _status,
        dateFrom: _dateFromCtrl.text.trim().isEmpty ? null : _dateFromCtrl.text.trim(),
        dateTo: _dateToCtrl.text.trim().isEmpty ? null : _dateToCtrl.text.trim(),
      );
      setState(() => _items = (res.data as List));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              DropdownButton<String>(
                value: _category,
                hint: const Text('الفئة'),
                items: const [
                  DropdownMenuItem(value: 'taxi', child: Text('تاكسي')),
                  DropdownMenuItem(value: 'tuk_tuk', child: Text('ستوتة')),
                  DropdownMenuItem(value: 'kia_passenger', child: Text('كيا ركاب')),
                  DropdownMenuItem(value: 'kia_haml', child: Text('كيا حمل')),
                  DropdownMenuItem(value: 'stuta', child: Text('ستوتة (Alias)')),
                  DropdownMenuItem(value: 'bike', child: Text('دراجة')),
                  DropdownMenuItem(value: 'electrician', child: Text('كهربائي')),
                  DropdownMenuItem(value: 'plumber', child: Text('سباك')),
                  DropdownMenuItem(value: 'blacksmith', child: Text('حداد')),
                  DropdownMenuItem(value: 'ac_tech', child: Text('فني تبريد')),
                ],
                onChanged: (v) => setState(() => _category = v),
              ),
              DropdownButton<String>(
                value: _status,
                hint: const Text('الحالة'),
                items: const [
                  DropdownMenuItem(value: 'CREATED', child: Text('جديد')),
                  DropdownMenuItem(value: 'CANCELLED', child: Text('ملغي')),
                  DropdownMenuItem(value: 'COMPLETED', child: Text('مكتمل')),
                ],
                onChanged: (v) => setState(() => _status = v),
              ),
              SizedBox(
                width: 140,
                child: TextField(
                  controller: _dateFromCtrl,
                  readOnly: true,
                  decoration: InputDecoration(
                    labelText: 'من تاريخ',
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.date_range),
                      onPressed: () async {
                        final now = DateTime.now();
                        final picked = await showDatePicker(
                          context: context,
                          firstDate: DateTime(now.year - 5),
                          lastDate: DateTime(now.year + 5),
                          initialDate: now,
                        );
                        if (picked != null) {
                          _dateFromCtrl.text = picked.toIso8601String().substring(0, 10);
                        }
                      },
                    ),
                  ),
                ),
              ),
              SizedBox(
                width: 140,
                child: TextField(
                  controller: _dateToCtrl,
                  readOnly: true,
                  decoration: InputDecoration(
                    labelText: 'إلى تاريخ',
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.date_range),
                      onPressed: () async {
                        final now = DateTime.now();
                        final picked = await showDatePicker(
                          context: context,
                          firstDate: DateTime(now.year - 5),
                          lastDate: DateTime(now.year + 5),
                          initialDate: now,
                        );
                        if (picked != null) {
                          _dateToCtrl.text = picked.toIso8601String().substring(0, 10);
                        }
                      },
                    ),
                  ),
                ),
              ),
              SizedBox(
                width: 90,
                child: TextField(
                  controller: _limitCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'الحد'),
                ),
              ),
              ElevatedButton(onPressed: _fetch, child: const Text('تحديث')),
            ],
          ),
        ),
        Expanded(
          child: _loading
              ? const Center(child: CircularProgressIndicator())
              : ListView.separated(
                  itemBuilder: (_, i) {
                    final o = _items[i] as Map<String, dynamic>;
                    final user = o['user'] as Map<String, dynamic>?;
                    final status = (o['status'] ?? '').toString();
                    Color chipColor;
                    switch (status) {
                      case 'COMPLETED':
                        chipColor = Colors.green;
                        break;
                      case 'CANCELLED':
                        break;
                      default:
                        chipColor = Colors.orange;
                    }
                    return ListTile(
                      title: Wrap(
                        spacing: 8,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Text('نوع: ${o['category']} • السعر: ${o['priceTotal']} ${o['currency']}'),
                          Chip(label: Text(status), backgroundColor: chipColor.withOpacity(0.15), labelStyle: TextStyle(color: chipColor)),
                        ],
                      ),
                      subtitle: Text('المسافة: ${o['distanceKm']} كم • الوقت: ${o['durationMin'] ?? '-'} دقيقة\nالمستخدم: ${user != null ? (user['name'] ?? user['phone'] ?? '') : '—'}'),
                      trailing: TextButton(
                        child: const Text('مشاركة'),
                        onPressed: () async {
                          final titleCtrl = TextEditingController(text: 'طلب خدمة جديد');
                          final msgCtrl = TextEditingController(text: 'النوع: ${o['category']} • السعر: ${o['priceTotal']}');
                          final role = await _pickRole(context);
                          if (role == null) return;
                          final ok = await showDialog<bool>(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: const Text('مشاركة الطلب'),
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  TextField(controller: titleCtrl, decoration: const InputDecoration(labelText: 'العنوان')),
                                  const SizedBox(height: 8),
                                  TextField(controller: msgCtrl, decoration: const InputDecoration(labelText: 'الرسالة')),
                                ],
                              ),
                              actions: [
                                TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('إلغاء')),
                                FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('إرسال')),
                              ],
                            ),
                          );
                          if (ok == true) {
                            try {
                              await _api.notifyByTags(
                                tags: [
                                  { 'key': 'role', 'relation': '=', 'value': role },
                                ],
                                title: titleCtrl.text.trim(),
                                message: msgCtrl.text.trim(),
                                data: { 'kind': 'order_share', 'orderId': o['id'] },
                              );
                              if (!mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تمت المشاركة')));
                            } catch (_) {
                              if (!mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('فشل المشاركة')));
                            }
                          }
                        },
                      ),
                    );
                  },
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemCount: _items.length,
                ),
      ],
    );
  }

  Future<String?> _pickRole(BuildContext context) async {
    const roles = [
      'taxi', 'tuk_tuk', 'kia_passenger', 'kia_haml', 'stuta', 'bike',
      'electrician', 'plumber', 'blacksmith', 'ac_tech',
    ];
    return showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('اختر فئة للمشاركة'),
        content: SizedBox(
          width: 320,
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: roles
                .map((r) => OutlinedButton(
                      onPressed: () => Navigator.pop(ctx, r),
                      child: Text(r),
                    ))
                .toList(),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء')),
        ],
      ),
    );
  }
}
