import 'package:flutter/material.dart';
import 'driver_home_base_screen.dart';

class TukTukHomeScreen extends StatelessWidget {
  const TukTukHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const DriverHomeBaseScreen(role: 'tuk_tuk', title: 'التكتك');
  }
}
