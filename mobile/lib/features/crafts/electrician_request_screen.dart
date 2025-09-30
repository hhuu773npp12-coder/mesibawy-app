import 'package:flutter/material.dart';
import 'craft_request_base_screen.dart';

class ElectricianRequestScreen extends StatelessWidget {
  const ElectricianRequestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const CraftRequestBaseScreen(role: 'electrician', title: 'طلب كهربائي');
  }
}
