import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'features/auth/phone_screen.dart';
import 'features/auth/code_screen.dart';
import 'features/common/waiting_approval_screen.dart';
import 'features/admin/admin_home.dart';
import 'features/orders/order_screen.dart';
import 'features/map/map_screen.dart';
import 'features/onboarding/vehicle_select_screen.dart';
import 'features/onboarding/craft_select_screen.dart';
import 'features/onboarding/admin_select_screen.dart';
import 'features/citizen/citizen_home.dart';
import 'features/driver/driver_home.dart';
import 'core/api_client.dart';
import 'features/registration/vehicle_registration_screen.dart';
import 'features/registration/craft_registration_screen.dart';
import 'features/crafts/craft_home_base_screen.dart';
import 'features/owner/owner_home.dart';
import 'features/restaurant/restaurant_home.dart';
import 'features/registration/restaurant_registration_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Lock to portrait for now; can be relaxed later if needed
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'مسيباوي - Mesibawy',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0E6BA8)),
        useMaterial3: true,
        fontFamily: 'Roboto',
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0E6BA8),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
        fontFamily: 'Roboto',
      ),
      themeMode: ThemeMode.system,
      locale: const Locale('ar'),
      supportedLocales: const [Locale('ar'), Locale('en')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      builder: (context, child) {
        // Global responsive typography + RTL
        final mq = MediaQuery.of(context);
        final w = mq.size.width;
        final textScale = w < 360 ? 0.95 : (w < 600 ? 1.0 : 1.1);
        return MediaQuery(
          data: mq.copyWith(textScaler: TextScaler.linear(textScale)),
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: child!,
          ),
        );
      },
      home: const SplashToNext(),
    );
  }
}

/// Splash screen then decides where to go next
class SplashToNext extends StatefulWidget {
  const SplashToNext({super.key});

  @override
  State<SplashToNext> createState() => _SplashToNextState();
}

class _SplashToNextState extends State<SplashToNext> {
  bool _navigated = false;

  @override
  void initState() {
    super.initState();
    _start();
  }

  Future<void> _start() async {
    // Show splash for 5 seconds
    await Future.delayed(const Duration(seconds: 5));
    if (!mounted) return;

    final prefs = await SharedPreferences.getInstance();
    final seenOnboarding = prefs.getBool('seen_onboarding') ?? false;

    if (_navigated) return;
    _navigated = true;
    if (!seenOnboarding) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const OnboardingSelectRole()),
      );
      return;
    }

    // Check auth token and approval state
    final token = prefs.getString('auth_token');
    final approved = prefs.getBool('user_approved') ?? false;
    final role = prefs.getString('user_role');
    if (token != null && token.isNotEmpty) {
      if (!approved) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const WaitingApprovalScreen()),
        );
        return;
      }
      // Navigate based on stored role (check profile completion for vehicle/craft roles)
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
          if (me != null &&
              ((me['vehicleType'] == null) ||
                  (me['vehicleType'] as String).isEmpty)) {
            dest = const VehicleRegistrationScreen();
          } else {
            dest = const DriverHome();
          }
          break;
        case 'electrician':
        case 'plumber':
        case 'blacksmith':
        case 'ac_tech':
          if (me != null &&
              ((me['craftType'] == null) ||
                  (me['craftType'] as String).isEmpty)) {
            dest = const CraftRegistrationScreen();
          } else {
            final roleTitle = () {
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
            }();
            dest = CraftHomeBaseScreen(role: role!, title: roleTitle);
          }
          break;
        case 'admin':
          dest = const AdminHome();
          break;
        case 'owner':
          dest = const OwnerHome();
          break;
        case 'restaurant_owner':
          {
            final prefs = await SharedPreferences.getInstance();
            final localRegistered =
                prefs.getBool('restaurant_registered') ?? false;
            if (!localRegistered) {
              dest = const RestaurantRegistrationScreen();
            } else {
              dest = const RestaurantHome();
            }
          }
          break;
        default:
          dest = const PlaceholderHome();
      }
      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (_) => dest));
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const PhoneInputScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: const [
              Icon(
                Icons.directions_car_filled_outlined,
                size: 80,
                color: Color(0xFF0E6BA8),
              ),
              SizedBox(height: 24),
              Text(
                'تم إنشاء التطبيق من مجموعة الحسن للبرمجيات والتقنيات الدقيقة ومنظومات الطاقة المتجددة',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// First-run only: role/category selection screen
class OnboardingSelectRole extends StatelessWidget {
  const OnboardingSelectRole({super.key});

  Future<void> _completeFirstRun(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('seen_onboarding', true);
    if (!context.mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const PhoneInputScreen()),
    );
  }

  Future<void> _chooseDirect(BuildContext context, String role) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('intended_role', role);
    await prefs.setBool('seen_onboarding', true);
    if (!context.mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const PhoneInputScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('اختيار نوع المستخدم')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _RoleButton(
              label: 'مواطن',
              onTap: () => _chooseDirect(context, 'citizen'),
            ),
            _RoleButton(
              label: 'صاحب مركبة',
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const VehicleSelectScreen(),
                  ),
                );
              },
            ),
            _RoleButton(
              label: 'صاحب حرفة',
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const CraftSelectScreen()),
                );
              },
            ),
            _RoleButton(
              label: 'أدمن',
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const AdminSelectScreen()),
                );
              },
            ),
            _RoleButton(
              label: 'مالك',
              onTap: () => _chooseDirect(context, 'owner'),
            ),
            _RoleButton(
              label: 'صاحب مطعم',
              onTap: () => _chooseDirect(context, 'restaurant_owner'),
            ),
            const SizedBox(height: 12),
            const Text(
              'ملاحظة: تظهر هذه الواجهة عند فتح التطبيق لأول مرة فقط.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}

class _RoleButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _RoleButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 14),
        ),
        child: Text(label, style: const TextStyle(fontSize: 16)),
      ),
    );
  }
}

/// Temporary home placeholder; will be replaced by real role-based homes
class PlaceholderHome extends StatelessWidget {
  const PlaceholderHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('مسيباوي')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('الواجهة الرئيسية المؤقتة'),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () async {
                final prefs = await SharedPreferences.getInstance();
                await prefs.remove('seen_onboarding');
                if (!context.mounted) return;
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(
                    builder: (_) => const OnboardingSelectRole(),
                  ),
                  (route) => false,
                );
              },
              child: const Text('إعادة عرض واجهة الفرز (مرة واحدة)'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {
                Navigator.of(
                  context,
                ).push(MaterialPageRoute(builder: (_) => const AdminHome()));
              },
              child: const Text('فتح لوحة الأدمن'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {
                Navigator.of(
                  context,
                ).push(MaterialPageRoute(builder: (_) => const CitizenHome()));
              },
              child: const Text('واجهة المواطن'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {
                Navigator.of(
                  context,
                ).push(MaterialPageRoute(builder: (_) => const DriverHome()));
              },
              child: const Text('واجهة السائق'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {
                Navigator.of(
                  context,
                ).push(MaterialPageRoute(builder: (_) => const OrderScreen()));
              },
              child: const Text('طلب رحلة تجريبي'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {
                Navigator.of(
                  context,
                ).push(MaterialPageRoute(builder: (_) => const MapScreen()));
              },
              child: const Text('الخريطة (ORS)'),
            ),
          ],
        ),
      ),
    );
  }
}
