import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';

// Imports
import 'features/auth/phone_screen.dart';
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
import 'features/onboarding/splash_screen.dart';
import 'features/onboarding/role_select_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
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
      routes: {
        '/': (_) => const SplashScreen(),
        '/roles': (_) => const RoleSelectScreen(),
        '/phone': (_) => const PhoneInputScreen(),
        '/admin/select': (_) => const AdminSelectScreen(),
        '/vehicles/select': (_) => const VehicleSelectScreen(),
        '/crafts/select': (_) => const CraftSelectScreen(),
        '/waiting': (_) => const WaitingApprovalScreen(),
      },
      home: const SplashScreen(),
    );
  }
}
