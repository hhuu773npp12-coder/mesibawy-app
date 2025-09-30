import 'package:flutter/material.dart';
import 'admin_api.dart';

class UsersTab extends StatefulWidget {
  const UsersTab({super.key});

  @override
  State<UsersTab> createState() => _UsersTabState();
}

class _UsersTabState extends State<UsersTab> {
  final _api = AdminApi();
  final _qCtrl = TextEditingController();
  String? _role;
  bool? _approved;
  bool _loading = false;
  List<dynamic> _items = [];

  @override
  void dispose() {
    _qCtrl.dispose();
    super.dispose();
  }

  Future<void> _fetch() async {
    setState(() => _loading = true);
    try {
      final res = await _api.listUsers(role: _role, approved: _approved, q: _qCtrl.text.trim().isEmpty ? null : _qCtrl.text.trim());
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
          child: Wrap(
            spacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              SizedBox(
                width: 180,
                child: TextField(
                  controller: _qCtrl,
                  decoration: const InputDecoration(labelText: 'بحث بالاسم/الهاتف'),
                ),
              ),
              DropdownButton<String>(
                value: _role,
                hint: const Text('الدور'),
                items: const [
                  DropdownMenuItem(value: 'citizen', child: Text('مواطن')),
                  DropdownMenuItem(value: 'taxi', child: Text('تاكسي')),
                  DropdownMenuItem(value: 'tuk_tuk', child: Text('ستوتة')),
                  DropdownMenuItem(value: 'kia_haml', child: Text('كيا حمل')),
                  DropdownMenuItem(value: 'kia_passenger', child: Text('كيا ركاب')),
                  DropdownMenuItem(value: 'stuta', child: Text('ستوتة (Alias)')),
                  DropdownMenuItem(value: 'bike', child: Text('دراجة')),
                  DropdownMenuItem(value: 'electrician', child: Text('كهربائي')),
                  DropdownMenuItem(value: 'plumber', child: Text('سباك')),
                  DropdownMenuItem(value: 'ac_tech', child: Text('تبريد وتكييف')),
                  DropdownMenuItem(value: 'blacksmith', child: Text('حدّاد')),
                  DropdownMenuItem(value: 'restaurant_owner', child: Text('صاحب مطعم')),
                  DropdownMenuItem(value: 'admin', child: Text('أدمن')),
                  DropdownMenuItem(value: 'owner', child: Text('مالك')),
                ],
                onChanged: (v) => setState(() => _role = v),
              ),
              DropdownButton<bool>(
                value: _approved,
                hint: const Text('الموافقة'),
                items: const [
                  DropdownMenuItem(value: true, child: Text('معتمد')),
                  DropdownMenuItem(value: false, child: Text('غير معتمد')),
                ],
                onChanged: (v) => setState(() => _approved = v),
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
                    final u = _items[i] as Map<String, dynamic>;
                    return ListTile(
                      title: Text(u['name']?.toString() ?? u['phone']?.toString() ?? 'مستخدم'),
                      subtitle: Text('الدور: ${u['role']} • ${u['isApproved'] == true ? 'معتمد' : 'غير معتمد'} • الرصيد: ${u['walletBalance'] ?? 0}'),
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
