import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'admin_api.dart';

class CodesTab extends StatefulWidget {
  const CodesTab({super.key});

  @override
  State<CodesTab> createState() => _CodesTabState();
}

class _CodesTabState extends State<CodesTab> {
  final _api = AdminApi();
  final _phoneCtrl = TextEditingController();
  bool _loading = false;
  List<dynamic> _items = [];

  @override
  void dispose() {
    _phoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _fetch() async {
    setState(() => _loading = true);
    try {
      final res = await _api.listCodes(phone: _phoneCtrl.text.trim().isEmpty ? null : _phoneCtrl.text.trim());
      setState(() => _items = (res.data as List));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _phoneCtrl,
                  decoration: const InputDecoration(labelText: 'رقم الهاتف (اختياري)'),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(onPressed: _fetch, child: const Text('تحديث')),
            ],
          ),
        ),
        Expanded(
          child: _loading
              ? const Center(child: CircularProgressIndicator())
              : ListView.separated(
                  itemBuilder: (_, i) {
                    final it = _items[i] as Map<String, dynamic>;
                    final code = it['code']?.toString() ?? '';
                    return ListTile(
                      title: Text(it['phone']?.toString() ?? ''),
                      subtitle: Text('الكود: $code • الحالة: ${it['used'] == true ? 'مستخدم' : 'غير مستخدم'}'),
                      trailing: Wrap(
                        spacing: 8,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Text((it['expiresAt'] ?? '').toString()),
                          IconButton(
                            tooltip: 'نسخ رسالة الكود',
                            icon: const Icon(Icons.copy),
                            onPressed: () async {
                              final message = 'هذا رمز تسجيل الدخول الخاص بك: $code';
                              await Clipboard.setData(ClipboardData(text: message));
                              if (!context.mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم نسخ الرسالة')));
                            },
                          ),
                        ],
                      ),
                    );
                  },
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemCount: _items.length,
                ),
        ),
      ],
    );
  }
}
