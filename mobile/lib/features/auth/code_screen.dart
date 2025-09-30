import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/api_client.dart';
import '../common/waiting_approval_screen.dart';
import '../../main.dart';
import '../citizen/citizen_home.dart';
import '../driver/driver_home.dart';
import '../driver/taxi_home_screen.dart';
import '../driver/tuk_tuk_home_screen.dart';
import '../driver/kia_haml_home_screen.dart';
import '../driver/stuta_home_screen.dart';
import '../driver/bike_home_screen.dart';
import '../admin/admin_home.dart';
import '../owner/owner_home.dart';
import '../registration/vehicle_registration_screen.dart';
import '../registration/craft_registration_screen.dart';
import '../crafts/electrician_home_screen.dart';
import '../crafts/plumber_home_screen.dart';
import '../crafts/ac_tech_home_screen.dart';
import '../crafts/blacksmith_home_screen.dart';

class CodeScreen extends StatefulWidget {
  final String phone;
  final String? devCode; // يظهر أثناء التطوير فقط
  const CodeScreen({super.key, required this.phone, this.devCode});

  @override
  State<CodeScreen> createState() => _CodeScreenState();
}

class _CodeScreenState extends State<CodeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _codeController = TextEditingController();
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    if (widget.devCode != null && widget.devCode!.isNotEmpty) {
      _codeController.text = widget.devCode!;
    }
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _verify() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final prefs = await SharedPreferences.getInstance();
      final intendedRole = prefs.getString('intended_role');
      final res = await ApiClient.I.dio.post('/auth/verify', data: {
        'phone': widget.phone,
        'code': _codeController.text.trim(),
        if (intendedRole != null) 'intendedRole': intendedRole,
      });
      final data = res.data as Map<String, dynamic>;
      final token = data['token']?.toString();
      final user = data['user'] as Map<String, dynamic>;
      final isApproved = (user['isApproved'] == true);
      final role = user['role']?.toString();

      await prefs.setString('auth_token', token ?? '');
      await prefs.setBool('user_approved', isApproved);
      if (role != null) await prefs.setString('user_role', role);

      ApiClient.I.setAuthToken(token);

      if (!mounted) return;
      if (!isApproved) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const WaitingApprovalScreen()),
          (route) => false,
        );
      } else {
        // Navigate based on role
        Widget dest;
        switch (role) {
          case 'citizen':
            dest = const CitizenHome();
            break;
          case 'taxi':
          case 'tuk_tuk':
          case 'kia_haml':
          case 'kia_passenger':
          case 'stuta':
          case 'bike':
            // If vehicle profile not completed, go to registration first
            if ((user['vehicleType'] == null || (user['vehicleType'] as String).isEmpty)) {
              dest = const VehicleRegistrationScreen();
            } else {
              switch (role) {
                case 'taxi':
                  dest = const TaxiHomeScreen();
                  break;
                case 'tuk_tuk':
                  dest = const TukTukHomeScreen();
                  break;
                case 'kia_haml':
                  dest = const KiaHamlHomeScreen();
                  break;
                case 'stuta':
                  dest = const StutaHomeScreen();
                  break;
                case 'bike':
                  dest = const BikeHomeScreen();
                  break;
                default:
                  dest = const DriverHome();
              }
            }
            break;
          case 'electrician':
          case 'plumber':
          case 'blacksmith':
          case 'ac_tech':
            if ((user['craftType'] == null || (user['craftType'] as String).isEmpty)) {
              dest = const CraftRegistrationScreen();
            } else {
              switch (role) {
                case 'electrician':
                  dest = const ElectricianHomeScreen();
                  break;
                case 'plumber':
                  dest = const PlumberHomeScreen();
                  break;
                case 'blacksmith':
                  dest = const BlacksmithHomeScreen();
                  break;
                case 'ac_tech':
                default:
                  dest = const AcTechHomeScreen();
              }
            }
            break;
          case 'admin':
            dest = const AdminHome();
            break;
          case 'owner':
            dest = const OwnerHome();
            break;
          default:
            dest = const PlaceholderHome();
        }
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => dest),
          (route) => false,
        );
      }
    } catch (e) {
      setState(() => _error = 'الكود غير صحيح أو منتهي الصلاحية');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('إدخال الكود')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('تم إرسال كود مكون من 4 أرقام إلى الأدمن لرقم: ${widget.phone}',
                  textAlign: TextAlign.center),
              const SizedBox(height: 12),
              TextFormField(
                controller: _codeController,
                maxLength: 4,
                keyboardType: TextInputType.number,
                textDirection: TextDirection.ltr,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'XXXX',
                ),
                validator: (v) {
                  final s = (v ?? '').trim();
                  if (s.length != 4) return 'أدخل 4 أرقام';
                  return null;
                },
              ),
              if (_error != null) ...[
                const SizedBox(height: 8),
                Text(_error!, style: const TextStyle(color: Colors.red)),
              ],
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: _loading ? null : _verify,
                child: _loading
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Text('تأكيد'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
