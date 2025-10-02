import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/api_client.dart';
import 'code_screen.dart';
import '../../main.dart';
import '../onboarding/role_select_screen.dart';
import 'citizen_registration_screen.dart';
import '../onboarding/craft_select_screen.dart';
import '../registration/craft_registration_screen.dart';
import '../registration/vehicle_registration_screen.dart';
import '../registration/restaurant_registration_screen.dart';

class PhoneInputScreen extends StatefulWidget {
  const PhoneInputScreen({super.key, this.titleOverride});
  final String? titleOverride;

  @override
  State<PhoneInputScreen> createState() => _PhoneInputScreenState();
}

class _PhoneInputScreenState extends State<PhoneInputScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _loading = false;
  String? _error;
  String? _intendedRole;

  @override
  void initState() {
    super.initState();
    _loadRole();
  }

  Future<void> _loadRole() async {
    final prefs = await SharedPreferences.getInstance();
    final role = prefs.getString('intended_role');
    if (!mounted) return;
    setState(() => _intendedRole = role);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _requestCode() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final prefs = await SharedPreferences.getInstance();
      final intendedRole = prefs.getString('intended_role');
      final res = await ApiClient.I.dio.post('/auth/request-code', data: {
        'phone': _phoneController.text.trim(),
        if (intendedRole != null) 'intendedRole': intendedRole,
        if (_nameController.text.trim().isNotEmpty) 'name': _nameController.text.trim(),
      });
      final data = res.data as Map<String, dynamic>;
      // For development only: code is returned by the backend response
      final code = data['code']?.toString();
      final phone = _phoneController.text.trim();

      // Save last used phone
      await prefs.setString('last_phone', phone);

      if (!mounted) return;
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => CodeScreen(phone: phone, devCode: code),
        ),
      );
    } catch (e) {
      setState(() => _error = 'تعذر إرسال الكود. تأكد من الاتصال وحاول مرة أخرى.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  bool get _isCraftRole => _intendedRole == 'electrician' || _intendedRole == 'plumber' || _intendedRole == 'blacksmith' || _intendedRole == 'ac_tech';
  bool get _isVehicleRole => _intendedRole == 'taxi' || _intendedRole == 'tuk_tuk' || _intendedRole == 'kia_haml' || _intendedRole == 'kia_passenger' || _intendedRole == 'stuta' || _intendedRole == 'bike';
  bool get _isRestaurantRole => _intendedRole == 'restaurant_owner';

  @override
  Widget build(BuildContext context) {
    final appBarTitle = widget.titleOverride ?? (_intendedRole == 'citizen'
        ? 'تسجيل دخول المواطن'
        : _isCraftRole
            ? 'تسجيل دخول صاحب الحِرفة'
            : _isVehicleRole
                ? 'تسجيل دخول صاحب المركبة'
                : _isRestaurantRole
                    ? 'تسجيل دخول صاحب المطعم'
                    : 'تسجيل الدخول');
    return Scaffold(
      appBar: AppBar(title: Text(appBarTitle)),
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
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'اسمك',
                ),
              ),
              const SizedBox(height: 12),
              const Text('أدخل رقم الهاتف'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                textDirection: TextDirection.ltr,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: '07XXXXXXXXX',
                ),
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
              ElevatedButton(
                onPressed: _loading ? null : _requestCode,
                child: _loading
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                    : Text((_intendedRole == 'citizen' || _isCraftRole || _isVehicleRole || _isRestaurantRole) ? 'تسجيل الدخول' : 'إرسال الكود'),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: _loading
                    ? null
                    : () {
                        if (_isCraftRole) {
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => const CraftRegistrationScreen()),
                          );
                        } else if (_isVehicleRole) {
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => const VehicleRegistrationScreen()),
                          );
                        } else if (_isRestaurantRole) {
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => const RestaurantRegistrationScreen()),
                          );
                        } else {
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => const CitizenRegistrationScreen()),
                          );
                        }
                      },
                child: const Text('إنشاء حساب جديد'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (_) => const RoleSelectScreen()),
                  );
                },
                child: const Text('العودة إلى واجهة الفرز'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
