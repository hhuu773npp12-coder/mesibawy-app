import 'package:flutter/material.dart';
import 'admin_api.dart';

class ApprovalsTab extends StatefulWidget {
  const ApprovalsTab({super.key});

  @override
  State<ApprovalsTab> createState() => _ApprovalsTabState();
}

class _ApprovalsTabState extends State<ApprovalsTab> {
  final _api = AdminApi();
  String? _status;
  bool _loading = false;
  List<dynamic> _items = [];

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  Future<void> _fetch() async {
    setState(() => _loading = true);
    try {
      final res = await _api.listApprovals(status: _status);
      setState(() => _items = (res.data as List));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _decide(String id, bool approve) async {
    // Optimistic update
    final idx = _items.indexWhere((e) => (e as Map<String, dynamic>)['id'].toString() == id);
    Map<String, dynamic>? backup;
    if (idx >= 0) {
      backup = Map<String, dynamic>.from(_items[idx] as Map<String, dynamic>);
      setState(() {
        final m = Map<String, dynamic>.from(_items[idx] as Map<String, dynamic>);
        m['status'] = approve ? 'APPROVED' : 'REJECTED';
        _items[idx] = m;
      });
    }
    try {
      if (approve) {
        await _api.approve(id, adminId: 'ADMIN');
      } else {
        await _api.reject(id, adminId: 'ADMIN');
      }
    } catch (_) {
      if (backup != null && idx >= 0) {
        setState(() => _items[idx] = backup!);
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(approve ? 'فشل الموافقة' : 'فشل الرفض')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              const Text('الحالة:'),
              const SizedBox(width: 8),
              DropdownButton<String>(
                value: _status,
                hint: const Text('الكل'),
                items: const [
                  DropdownMenuItem(value: 'PENDING', child: Text('قيد الانتظار')),
                  DropdownMenuItem(value: 'APPROVED', child: Text('موافق عليه')),
                  DropdownMenuItem(value: 'REJECTED', child: Text('مرفوض')),
                ],
                onChanged: (v) {
                  setState(() => _status = v);
                  _fetch();
                },
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
                    final user = it['user'] as Map<String, dynamic>?;
                    final role = user != null ? (user['role']?.toString() ?? '') : '';
                    final phone = user != null ? (user['phone']?.toString() ?? '') : '';
                    final createdAt = it['createdAt']?.toString() ?? '';
                    return ListTile(
                      title: Text(user != null ? (user['name'] ?? phone) : 'مستخدم'),
                      subtitle: Text('الدور: $role • الهاتف: $phone\nالحالة: ${it['status']}'),
                      isThreeLine: true,
                      trailing: Wrap(
                        spacing: 8,
                        children: [
                          Text(createdAt, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                          IconButton(
                            icon: const Icon(Icons.check_circle, color: Colors.green),
                            onPressed: () => _decide(it['id'].toString(), true),
                          ),
                          IconButton(
                            icon: const Icon(Icons.cancel, color: Colors.red),
                            onPressed: () => _decide(it['id'].toString(), false),
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
