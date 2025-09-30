import 'package:flutter/material.dart';
import 'ride_request_base_screen.dart';

class StutaRequestScreen extends StatelessWidget {
  const StutaRequestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const RideRequestBaseScreen(role: 'stuta', title: 'طلب ستوتة');
  }
}
