import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'role_select_screen.dart';
import '../../core/api_client.dart';
import '../auth/phone_screen.dart';
import '../common/waiting_approval_screen.dart';
import '../citizen/citizen_home.dart';
import '../driver/driver_home.dart';
import '../registration/vehicle_registration_screen.dart';
import '../registration/craft_registration_screen.dart';
import '../crafts/craft_home_base_screen.dart';
import '../admin/admin_home.dart';
import '../owner/owner_home.dart';
import '../restaurant/restaurant_home.dart';
import '../registration/restaurant_registration_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  double _opacity = 0.0;
  Offset _slideOffset = const Offset(0, 0.08);

  @override
  void initState() {
    super.initState();
    // Start entrance animation
    Future.delayed(const Duration(milliseconds: 200), () {
      if (!mounted) return;
      setState(() {
        _opacity = 1.0;
        _slideOffset = Offset.zero;
      });
    });
    _goNext();
  }

  Future<void> _goNext() async {
    await Future.delayed(const Duration(seconds: 5));
    final prefs = await SharedPreferences.getInstance();
    final seenOnboarding = prefs.getBool('seen_onboarding') ?? false;
    if (!mounted) return;

    if (!seenOnboarding) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const RoleSelectScreen()),
      );
      return;
    }

    final token = prefs.getString('auth_token');
    final approved = prefs.getBool('user_approved') ?? false;
    final role = prefs.getString('user_role');

    if (token == null || token.isEmpty) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const PhoneInputScreen()),
      );
      return;
    }

    if (!approved) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const WaitingApprovalScreen()),
      );
      return;
    }

    ApiClient.I.setAuthToken(token);
    Map<String, dynamic>? me;
    try {
      final res = await ApiClient.I.dio.get('/users/me');
      me = res.data as Map<String, dynamic>;
    } catch (_) {}

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
        dest = (me != null && ((me['vehicleType'] == null) || (me['vehicleType'] as String).isEmpty))
            ? const VehicleRegistrationScreen()
            : const DriverHome();
        break;
      case 'electrician':
      case 'plumber':
      case 'blacksmith':
      case 'ac_tech':
        dest = (me != null && ((me['craftType'] == null) || (me['craftType'] as String).isEmpty))
            ? const CraftRegistrationScreen()
            : CraftHomeBaseScreen(role: role!, title: _craftRoleTitle(role));
        break;
      case 'admin':
        dest = const AdminHome();
        break;
      case 'owner':
        dest = const OwnerHome();
        break;
      case 'restaurant_owner':
        final localRegistered = prefs.getBool('restaurant_registered') ?? false;
        dest = localRegistered ? const RestaurantHome() : const RestaurantRegistrationScreen();
        break;
      default:
        dest = const RoleSelectScreen();
    }

    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => dest));
  }

  String _craftRoleTitle(String role) {
    switch (role) {
      case 'electrician':
        return 'صاحب حرفة - كهربائي';
      case 'plumber':
        return 'صاحب حرفة - سباك';
      case 'blacksmith':
        return 'صاحب حرفة - حداد';
      case 'ac_tech':
      default:
        return 'صاحب حرفة - فني تبريد';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Theme.of(context).colorScheme.primary,
                Theme.of(context).colorScheme.secondary,
              ],
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              AnimatedOpacity(
                opacity: _opacity,
                duration: const Duration(milliseconds: 800),
                curve: Curves.easeOut,
                child: AnimatedSlide(
                  duration: const Duration(milliseconds: 800),
                  curve: Curves.easeOut,
                  offset: _slideOffset,
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24.0),
                    child: Text(
                      'تم إنشاء التطبيق من مجموعة الحسن للبرمجيات والتقنيات الدقيقة ومنظومات الطاقة المتجددة',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const CircularProgressIndicator(color: Colors.white),
            ],
          ),
