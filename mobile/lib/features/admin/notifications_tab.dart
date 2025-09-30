import 'package:flutter/material.dart';
import 'admin_api.dart';

class NotificationsTab extends StatefulWidget {
  const NotificationsTab({super.key});

  @override
  State<NotificationsTab> createState() => _NotificationsTabState();
}

class _NotificationsTabState extends State<NotificationsTab> {
  final _api = AdminApi();

  // broadcast
  final _bTitle = TextEditingController();
  final _bMsg = TextEditingController();

  // users
  final _uIds = TextEditingController();
  final _uTitle = TextEditingController();
  final _uMsg = TextEditingController();

  // tags
  final _tKey = TextEditingController(text: 'role');
  String _tRelation = '=';
  final _tValue = TextEditingController(text: 'taxi');
  final _tTitle = TextEditingController();
  final _tMsg = TextEditingController();

  bool _loading = false;

  @override
  void dispose() {
    _bTitle.dispose();
    _bMsg.dispose();
    _uIds.dispose();
    _uTitle.dispose();
    _uMsg.dispose();
    _tKey.dispose();
    _tValue.dispose();
    _tTitle.dispose();
    _tMsg.dispose();
    super.dispose();
  }

  Future<void> _wrap(Future<void> Function() fn) async {
    setState(() => _loading = true);
    try {
      await fn();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم الإرسال')));
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('فشل الإرسال')));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AbsorbPointer(
      absorbing: _loading,
      child: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          const Text('بث عام', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(child: TextField(controller: _bTitle, decoration: const InputDecoration(labelText: 'العنوان'))),
              const SizedBox(width: 8),
              Expanded(child: TextField(controller: _bMsg, decoration: const InputDecoration(labelText: 'الرسالة'))),
              const SizedBox(width: 8),
              FilledButton(
                onPressed: () => _wrap(() async {
                  await _api.notifyBroadcast(title: _bTitle.text.trim(), message: _bMsg.text.trim());
                }),
                child: _loading ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('إرسال'),
              ),
            ],
          ),
          const Divider(height: 32),
          const Text('إشعار لمستخدمين محددين', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              SizedBox(
                width: 220,
                child: TextField(
                  controller: _uIds,
                  decoration: const InputDecoration(labelText: 'userIds (مفصولة بفواصل)'),
                ),
              ),
              SizedBox(width: 220, child: TextField(controller: _uTitle, decoration: const InputDecoration(labelText: 'العنوان'))),
              SizedBox(width: 220, child: TextField(controller: _uMsg, decoration: const InputDecoration(labelText: 'الرسالة'))),
              FilledButton(
                onPressed: () => _wrap(() async {
                  final ids = _uIds.text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
                  await _api.notifyUsers(userIds: ids, title: _uTitle.text.trim(), message: _uMsg.text.trim());
                }),
                child: _loading ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('إرسال'),
              ),
            ],
          ),
          const Divider(height: 32),
          const Text('إشعار حسب الوسوم (Tags)', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              SizedBox(width: 160, child: TextField(controller: _tKey, decoration: const InputDecoration(labelText: 'Tag Key'))),
              DropdownButton<String>(
                value: _tRelation,
                items: const [
                  DropdownMenuItem(value: '=', child: Text('=')),
                  DropdownMenuItem(value: '!=', child: Text('!=')),
                  DropdownMenuItem(value: 'exists', child: Text('exists')),
                  DropdownMenuItem(value: 'not_exists', child: Text('not_exists')),
                  DropdownMenuItem(value: '>', child: Text('>')),
                  DropdownMenuItem(value: '<', child: Text('<')),
                ],
                onChanged: (v) => setState(() => _tRelation = v ?? '='),
              ),
              SizedBox(width: 160, child: TextField(controller: _tValue, decoration: const InputDecoration(labelText: 'Value'))),
              SizedBox(width: 200, child: TextField(controller: _tTitle, decoration: const InputDecoration(labelText: 'العنوان'))),
              SizedBox(width: 200, child: TextField(controller: _tMsg, decoration: const InputDecoration(labelText: 'الرسالة'))),
              FilledButton(
                onPressed: () => _wrap(() async {
                  final tags = [
                    {'key': _tKey.text.trim(), 'relation': _tRelation, if (_tRelation != 'exists' && _tRelation != 'not_exists') 'value': _tValue.text.trim()},
                  ];
                  await _api.notifyByTags(tags: tags, title: _tTitle.text.trim(), message: _tMsg.text.trim());
                }),
                child: _loading ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('إرسال'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
