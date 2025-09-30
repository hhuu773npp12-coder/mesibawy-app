import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/api_client.dart';
import 'code_screen.dart';

class CitizenRegistrationScreen extends StatefulWidget {
  const CitizenRegistrationScreen({super.key});

  @override
  State<CitizenRegistrationScreen> createState() => _CitizenRegistrationScreenState();
}

class _CitizenRegistrationScreenState extends State<CitizenRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _createAccount() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('intended_role', 'citizen');
      final phone = _phoneController.text.trim();
      final res = await ApiClient.I.dio.post('/auth/request-code', data: {
        'phone': phone,
        'intendedRole': 'citizen',
        'name': _nameController.text.trim(),
      });
      final data = res.data as Map<String, dynamic>;
      final code = data['code']?.toString(); // يظهر أثناء التطوير فقط
      await prefs.setString('last_phone', phone);

      if (!mounted) return;
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => CodeScreen(phone: phone, devCode: code)),
      );
    } catch (e) {
      setState(() => _error = 'تعذر إنشاء الحساب. حاول مرة أخرى.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('تسجيل المواطن')),
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
                controller: _nameController,
                textDirection: TextDirection.rtl,
                decoration: const InputDecoration(border: OutlineInputBorder(), hintText: 'اسمك'),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'الاسم مطلوب' : null,
              ),
              const SizedBox(height: 12),
              const Text('رقم الهاتف'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _phoneController,
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
              if (_error != null) ...[
                Text(_error!, style: const TextStyle(color: Colors.red)),
                const SizedBox(height: 8),
              ],
              FilledButton(
                onPressed: _loading ? null : _createAccount,
                child: _loading
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Text('إنشاء حساب'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
