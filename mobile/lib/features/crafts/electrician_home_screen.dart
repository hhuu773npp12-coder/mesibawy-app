import 'package:flutter/material.dart';
import 'craft_home_base_screen.dart';

class ElectricianHomeScreen extends StatelessWidget {
  const ElectricianHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const CraftHomeBaseScreen(role: 'electrician', title: 'الكهربائي');
  }
}
