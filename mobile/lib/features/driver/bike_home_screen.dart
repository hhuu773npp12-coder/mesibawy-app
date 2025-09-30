import 'package:flutter/material.dart';
import 'driver_home_base_screen.dart';

class BikeHomeScreen extends StatelessWidget {
  const BikeHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const DriverHomeBaseScreen(role: 'bike', title: 'الدراجة');
  }
}
