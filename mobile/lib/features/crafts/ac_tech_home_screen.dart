import 'package:flutter/material.dart';
import 'craft_home_base_screen.dart';

class AcTechHomeScreen extends StatelessWidget {
  const AcTechHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const CraftHomeBaseScreen(role: 'ac_tech', title: 'فني التبريد');
  }
}
