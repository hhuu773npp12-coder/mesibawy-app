import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../auth/phone_screen.dart';

class _VehicleLoginWrapper extends StatelessWidget {
  const _VehicleLoginWrapper({required this.role, required this.title});
  final String role;
  final String title;

  Future<void> _prepareRole(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('intended_role', role);
    await prefs.setBool('seen_onboarding', true);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _prepareRole(context),
      builder: (context, snap) {
        if (snap.connectionState != ConnectionState.done) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()))
;        }
        return PhoneInputScreen(titleOverride: title);
      },
    );
  }
}

class TaxiLoginScreen extends StatelessWidget {
  const TaxiLoginScreen({super.key});
  @override
  Widget build(BuildContext context) => const _VehicleLoginWrapper(role: 'taxi', title: 'تسجيل دخول صاحب التكسي');
}

class TukTukLoginScreen extends StatelessWidget {
  const TukTukLoginScreen({super.key});
  @override
  Widget build(BuildContext context) => const _VehicleLoginWrapper(role: 'tuk_tuk', title: 'تسجيل دخول صاحب التكتك');
}

class StutaLoginScreen extends StatelessWidget {
  const StutaLoginScreen({super.key});
  @override
  Widget build(BuildContext context) => const _VehicleLoginWrapper(role: 'stuta', title: 'تسجيل دخول صاحب الستوتة');
}

class KiaHamlLoginScreen extends StatelessWidget {
  const KiaHamlLoginScreen({super.key});
  @override
  Widget build(BuildContext context) => const _VehicleLoginWrapper(role: 'kia_haml', title: 'تسجيل دخول صاحب الكيا حمل');
}

class KiaPassengerLoginScreen extends StatelessWidget {
  const KiaPassengerLoginScreen({super.key});
  @override
  Widget build(BuildContext context) => const _VehicleLoginWrapper(role: 'kia_passenger', title: 'تسجيل دخول صاحب الكيا نقل الركاب');
}

class BikeLoginScreen extends StatelessWidget {
  const BikeLoginScreen({super.key});
  @override
  Widget build(BuildContext context) => const _VehicleLoginWrapper(role: 'bike', title: 'تسجيل دخول صاحب الدراجة');
}
