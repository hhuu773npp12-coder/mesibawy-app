import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/api_client.dart';
import '../admin/admin_home.dart';
import '../owner/owner_home.dart';
import '../onboarding/admin_select_screen.dart';
import 'admin_owner_registration_screen.dart';

class AdminOwnerLoginScreen extends StatefulWidget {
  const AdminOwnerLoginScreen({super.key, required this.role});
  final String role; // 'admin' or 'owner'

  @override
  State<AdminOwnerLoginScreen> createState() => _AdminOwnerLoginScreenState();
}

class _AdminOwnerLoginScreenState extends State<AdminOwnerLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _secretCtrl = TextEditingController();
  bool _loading = false;
  String? _error;

  // Fixed secrets (client-side check for UX only; backend MUST enforce)
  static const List<String> _adminSecrets = [
    '914206', '830571', '662489', '770145', '591302', '408713', '237816', '128945', '953407', '746120',
  ];
  static const List<String> _ownerSecrets = [
    '519740', '286531',
  ];

  List<String> get _validSecrets => widget.role == 'admin' ? _adminSecrets : _ownerSecrets;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _secretCtrl.dispose();
    super.dispose();
  }

  bool _checkSecretLocally(String s) => _validSecrets.contains(s.trim());

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('intended_role', widget.role);
      final phone = _phoneCtrl.text.trim();

      final secret = _secretCtrl.text.trim();
      if (!_checkSecretLocally(secret)) {
        setState(() => _error = 'الرمز السري غير صحيح');
        return;
      }

      final res = await ApiClient.I.dio.post('/auth/admin-owner-login', data: {
        'phone': phone,
        'role': widget.role,
        'name': _nameCtrl.text.trim(),
        'secret': secret,
      });
      final data = res.data as Map<String, dynamic>;
      final token = data['token']?.toString();
      final user = (data['user'] as Map<String, dynamic>);
      await prefs.setString('auth_token', token ?? '');
      await prefs.setString('user_role', user['role']?.toString() ?? widget.role);
      await prefs.setBool('user_approved', true);
      ApiClient.I.setAuthToken(token);
      await prefs.setString('last_phone', phone);

      if (!mounted) return;
      final Widget dest = widget.role == 'admin' ? const AdminHome() : const OwnerHome();
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => dest),
        (route) => false,
      );
    } catch (e) {
      setState(() => _error = 'فشل طلب الكود. تحقق من البيانات وحاول مجدداً.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.role == 'admin' ? 'تسجيل دخول الأدمن' : 'تسجيل دخول المالك';
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('الاسم'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _nameCtrl,
                decoration: const InputDecoration(border: OutlineInputBorder(), hintText: 'اسمك'),
              ),
              const SizedBox(height: 12),
              const Text('رقم الهاتف'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _phoneCtrl,
                keyboardType: TextInputType.phone,
                textDirection: TextDirection.ltr,
                decoration: const InputDecoration(border: OutlineInputBorder(), hintText: '07XXXXXXXXX'),
                validator: (v) {
                  final s = (v ?? '').trim();
                  if (s.isEmpty) return 'الرجاء إدخال رقم الهاتف';
                  if (s.length < 7) return 'رقم الهاتف غير صحيح';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              const Text('الرمز السري'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _secretCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(border: OutlineInputBorder(), hintText: 'XXXXXX'),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'أدخل الرمز السري' : null,
              ),
              const SizedBox(height: 12),
              if (_error != null) ...[
                Text(_error!, style: const TextStyle(color: Colors.red)),
                const SizedBox(height: 8),
              ],
              Row(
                children: [
                  Expanded(
                    child: FilledButton(
                      onPressed: _loading ? null : _login,
                      child: _loading
                          ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                          : const Text('تسجيل الدخول'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _loading
                          ? null
                          : () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => AdminOwnerRegistrationScreen(role: widget.role),
                                ),
                              );
                            },
                      icon: const Icon(Icons.person_add_alt),
                      label: const Text('إنشاء حساب'),
                    ),
                  ),
                ],
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const AdminSelectScreen()),
                    (route) => false,
                  );
                },
                child: const Text('العودة إلى الفرز'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
