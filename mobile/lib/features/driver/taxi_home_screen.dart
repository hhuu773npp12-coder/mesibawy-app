import 'package:flutter/material.dart';
import 'driver_home_base_screen.dart';

class TaxiHomeScreen extends StatelessWidget {
  const TaxiHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const DriverHomeBaseScreen(role: 'taxi', title: 'التكسي');
  }
}
