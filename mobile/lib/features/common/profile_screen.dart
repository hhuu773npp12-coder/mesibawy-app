import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../../core/api_client.dart';
import '../onboarding/admin_select_screen.dart';
import 'package:image_picker/image_picker.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _loading = false;
  Map<String, dynamic>? _user;
  String? _error;
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  Future<void> _fetch() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final Dio dio = ApiClient.I.dio;
      final res = await dio.get('/users/me');
      final u = (res.data as Map<String, dynamic>);
      setState(() {
        _user = u;
        _nameCtrl.text = u['name']?.toString() ?? '';
        _phoneCtrl.text = u['phone']?.toString() ?? '';
      });
    } catch (e) {
      setState(() => _error = 'تعذر جلب البيانات');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _save() async {
    if (_user == null) return;
    setState(() => _loading = true);
    try {
      final Dio dio = ApiClient.I.dio;
      final id = _user!['id']?.toString();
      if (id == null) throw Exception('no id');
      await dio.patch(
        '/users/$id',
        data: {'name': _nameCtrl.text.trim(), 'phone': _phoneCtrl.text.trim()},
      );
      await _fetch();
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('تم حفظ التعديلات')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('تعذر حفظ التغييرات')));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _logout() {
    ApiClient.I.setAuthToken(null);
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const AdminSelectScreen()),
      (route) => false,
    );
  }

  void _pickAvatar() {
    _pickAndUpload();
  }

  Future<void> _pickAndUpload() async {
    try {
      final picker = ImagePicker();
      final x = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );
      if (x == null) return;
      setState(() => _loading = true);
      final dio = ApiClient.I.dio;
      final form = FormData.fromMap({
        'file': await MultipartFile.fromFile(x.path, filename: x.name),
      });
      final up = await dio.post(
        '/files/upload',
        data: form,
        options: Options(contentType: 'multipart/form-data'),
      );
      final url = (up.data is Map<String, dynamic>)
          ? (up.data['url']?.toString() ?? '')
          : '';
      if (url.isEmpty) throw Exception('upload failed');
      final id = _user?['id']?.toString();
      if (id == null) throw Exception('no user id');
      await dio.patch('/users/$id', data: {'avatarUrl': url});
      await _fetch();
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('تم تحديث الصورة')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('فشل رفع الصورة')));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final avatarUrl = _user?['avatarUrl']?.toString();
    final userId = _user?['userId']?.toString() ?? '';

    return Scaffold(
      appBar: AppBar(
        title: const Text('الملف الشخصي'),
        actions: [
          IconButton(
            onPressed: _loading ? null : _fetch,
            icon: const Icon(Icons.refresh),
          ),
          IconButton(
            onPressed: _loading ? null : _save,
            icon: const Icon(Icons.save),
          ),
        ],
      ),
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : (_error != null
                  ? Center(
                      child: Text(
                        _error!,
                        style: const TextStyle(color: Colors.red),
                      ),
                    )
                  : ListView(
                      padding: const EdgeInsets.all(16),
                      children: [
                        Center(
                          child: Stack(
                            children: [
                              CircleAvatar(
                                radius: 48,
                                backgroundImage:
                                    (avatarUrl != null && avatarUrl.isNotEmpty)
                                    ? NetworkImage(avatarUrl)
                                    : null,
                                child: (avatarUrl == null || avatarUrl.isEmpty)
                                    ? const Icon(Icons.person, size: 48)
                                    : null,
                              ),
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: InkWell(
                                  onTap: _pickAvatar,
                                  child: Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.primary,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.add,
                                      color: Colors.white,
                                      size: 18,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _nameCtrl,
                          decoration: const InputDecoration(
                            labelText: 'الاسم',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _phoneCtrl,
                          keyboardType: TextInputType.phone,
                          decoration: const InputDecoration(
                            labelText: 'رقم الهاتف',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 12),
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: const Text('الدعم'),
                          subtitle: const Text(
                            'يمكنك الاتصال بالدعم 07767508166',
                          ),
                          leading: const Icon(Icons.support_agent),
                          onTap: () {},
                        ),
                        const Divider(),
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: const Text('المعرف'),
                          subtitle: Text(userId.isEmpty ? '—' : userId),
                          leading: const Icon(Icons.badge_outlined),
                        ),
                        const SizedBox(height: 12),
                        FilledButton.icon(
                          onPressed: _logout,
                          icon: const Icon(Icons.logout),
                          label: const Text('تسجيل الخروج'),
                        ),
                      ],
                    )),
      ),
    );
  }
}
