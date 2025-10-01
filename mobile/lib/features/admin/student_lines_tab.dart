import 'package:flutter/material.dart';
import 'admin_api.dart';

class StudentLinesTab extends StatefulWidget {
  const StudentLinesTab({super.key});

  @override
  State<StudentLinesTab> createState() => _StudentLinesTabState();
}

class _StudentLinesTabState extends State<StudentLinesTab> {
  final _api = AdminApi();
  bool _loading = false;
  List<dynamic> _items = [];
  bool _loadingPublic = false;
  List<dynamic> _public = [];

  final _nameCtrl = TextEditingController();
  final _originCtrl = TextEditingController();
  final _destCtrl = TextEditingController();
  final _distanceCtrl = TextEditingController(text: '7.5');
  String _kind = 'school';

  @override
  void initState() {
    super.initState();
    _fetch();
    _fetchPublic();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _originCtrl.dispose();
    _destCtrl.dispose();
    _distanceCtrl.dispose();
    super.dispose();
  }

  Future<void> _fetch() async {
    setState(() => _loading = true);
    try {
      final res = await _api.listStudentLines();
      setState(() => _items = (res.data as List));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _fetchPublic() async {
    setState(() => _loadingPublic = true);
    try {
      final res = await _api.listStudentLinePublicRequests();
      setState(() => _public = (res.data as List));
    } finally {
      if (mounted) setState(() => _loadingPublic = false);
    }
  }

  Future<void> _create() async {
    try {
      await _api.createStudentLine(
        name: _nameCtrl.text.trim(),
        originArea: _originCtrl.text.trim(),
        destinationArea: _destCtrl.text.trim(),
        distanceKm: double.tryParse(_distanceCtrl.text.trim()) ?? 0,
        kind: _kind,
      );
      _nameCtrl.clear();
      _originCtrl.clear();
      _destCtrl.clear();
      await _fetch();
    } catch (_) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('فشل إنشاء الخط')));
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
              SizedBox(
                width: 180,
                child: TextField(
                  controller: _nameCtrl,
                  decoration: const InputDecoration(
                    labelText: 'اسم المدرسة/الجامعة',
                  ),
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
                width: 180,
                child: TextField(
                  controller: _destCtrl,
                  decoration: const InputDecoration(labelText: 'منطقة الوجهة'),
                ),
              ),
              SizedBox(
                width: 120,
                child: TextField(
                  controller: _distanceCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'المسافة (كم)'),
                ),
              ),
              DropdownButton<String>(
                value: _kind,
                items: const [
                  DropdownMenuItem(value: 'school', child: Text('مدرسة')),
                  DropdownMenuItem(value: 'university', child: Text('جامعة')),
                ],
                onChanged: (v) => setState(() => _kind = v ?? 'school'),
              ),
              ElevatedButton(onPressed: _create, child: const Text('إنشاء')),
              ElevatedButton(onPressed: _fetch, child: const Text('تحديث')),
            ],
          ),
        ),
        Expanded(
          child: _loading
              ? const Center(child: CircularProgressIndicator())
              : ListView.separated(
                  itemBuilder: (_, i) {
                    final it = _public[i] as Map<String, dynamic>;
                    return ListTile(
                      leading: const Icon(Icons.school_outlined),
                      title: Text(
                        '${it['citizenName']} • ${it['citizenPhone']}',
                      ),
                      subtitle: Text(
                        'نوع: ${it['kind']} • عدد: ${it['count']}\n'
                        'المسافة: ${it['distanceKm']} كم • أسبوعي: ${it['weeklyPrice']} د.ع\n'
                        'من (${it['originLat']}, ${it['originLng']}) '
                        'إلى (${it['destLat']}, ${it['destLng']})',
                      ),
                      trailing: Wrap(
                        spacing: 8,
                        children: [
                          OutlinedButton(
                            onPressed: it['status'] == 'PENDING'
                                ? () async {
                                    await _api.approveStudentLinePublicRequest(
                                      it['id'],
                                    );
                                    _fetchPublic();
                                  }
                                : null,
                            child: const Text('موافقة'),
                          ),
                          OutlinedButton(
                            onPressed: it['status'] == 'PENDING'
                                ? () async {
                                    await _api.rejectStudentLinePublicRequest(
                                      it['id'],
                                    );
                                    _fetchPublic();
                                  }
                                : null,
                            child: const Text('رفض'),
                          ),
                        ],
                      ),
                    );
                  },
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemCount: _public.length,
                ),
        ),
      ],
    );
  }
}
