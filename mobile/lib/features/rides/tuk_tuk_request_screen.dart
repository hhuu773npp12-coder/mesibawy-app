import 'package:flutter/material.dart';
import 'ride_request_base_screen.dart';

class TukTukRequestScreen extends StatelessWidget {
  const TukTukRequestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const RideRequestBaseScreen(role: 'tuk_tuk', title: 'طلب تكتك');
  }
}
