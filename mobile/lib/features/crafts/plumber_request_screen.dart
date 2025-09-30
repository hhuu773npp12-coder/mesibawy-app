import 'package:flutter/material.dart';
import 'craft_request_base_screen.dart';

class PlumberRequestScreen extends StatelessWidget {
  const PlumberRequestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const CraftRequestBaseScreen(role: 'plumber', title: 'طلب سباك');
  }
}
