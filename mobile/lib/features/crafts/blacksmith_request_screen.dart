import 'package:flutter/material.dart';
import 'craft_request_base_screen.dart';

class BlacksmithRequestScreen extends StatelessWidget {
  const BlacksmithRequestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const CraftRequestBaseScreen(role: 'blacksmith', title: 'طلب حداد');
  }
}
