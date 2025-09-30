import 'package:flutter/material.dart';
import 'ride_request_base_screen.dart';

class TaxiRequestScreen extends StatelessWidget {
  const TaxiRequestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const RideRequestBaseScreen(role: 'taxi', title: 'طلب تكسي');
  }
}
