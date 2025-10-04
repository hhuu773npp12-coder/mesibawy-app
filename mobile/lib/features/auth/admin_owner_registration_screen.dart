import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';
import '../../core/api_client.dart';
import 'code_screen.dart';
import 'admin_owner_login_screen.dart';

class AdminOwnerRegistrationScreen extends StatefulWidget {
  const AdminOwnerRegistrationScreen({super.key, required this.role});
  final String role; // 'admin' or 'owner'

  @override
  State<AdminOwnerRegistrationScreen> createState() => _AdminOwnerRegistrationScreenState();
}

class _AdminOwnerRegistrationScreenState extends State<AdminOwnerRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  bool _loading = false;
  String? _error;

  // Fixed secrets (client-side UX check; backend must enforce)
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
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    // Use fixed secret automatically based on role priority
    final secret = _validSecrets.first;

    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('intended_role', widget.role);
      final phone = _phoneCtrl.text.trim();

      final res = await ApiClient.I.dio.post('/auth/request-code', data: {
        'phone': phone,
        'intendedRole': widget.role,
        'name': _nameCtrl.text.trim(),
        'secret': secret, // backend should verify and limit counts (10 admins, 2 owners)
      });
      final data = res.data as Map<String, dynamic>;
      final code = data['code']?.toString(); // dev only
      await prefs.setString('last_phone', phone);

      if (!mounted) return;
      // بعد التسجيل بنجاح، العودة إلى شاشة تسجيل الدخول لنفس الدور
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم إنشاء الحساب بنجاح. يمكنك تسجيل الدخول الآن.')),
      );
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => AdminOwnerLoginScreen(role: widget.role)),
        (route) => false,
      );
    } catch (e) {
      String friendly = 'تعذر إنشاء الحساب. تحقق من البيانات وحاول مجدداً.';
      if (e is DioException) {
        final data = e.response?.data;
        if (data is Map && data['message'] is String && (data['message'] as String).isNotEmpty) {
          friendly = data['message'] as String;
        } else if (e.error is String && (e.error as String).isNotEmpty) {
          friendly = e.error as String;
        }
      }
      setState(() => _error = friendly);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.role == 'admin' ? 'تسجيل الأدمن' : 'تسجيل المالك';
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
                validator: (v) => (v == null || v.trim().isEmpty) ? 'الاسم مطلوب' : null,
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
              // تم إلغاء إدخال الرمز السري والاعتماد على رمز ثابت داخل التطبيق
              const SizedBox(height: 12),
              if (_error != null) ...[
                Text(_error!, style: const TextStyle(color: Colors.red)),
                const SizedBox(height: 8),
              ],
              FilledButton(
                onPressed: _loading ? null : _register,
                child: _loading
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Text('تسجيل'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
