import 'package:flutter/material.dart';
import 'craft_home_base_screen.dart';

class BlacksmithHomeScreen extends StatelessWidget {
  const BlacksmithHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const CraftHomeBaseScreen(role: 'blacksmith', title: 'الحداد');
  }
}
