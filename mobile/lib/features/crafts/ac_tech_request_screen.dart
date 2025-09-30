import 'package:flutter/material.dart';
import 'craft_request_base_screen.dart';

class AcTechRequestScreen extends StatelessWidget {
  const AcTechRequestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const CraftRequestBaseScreen(role: 'ac_tech', title: 'طلب فني تبريد');
  }
}
