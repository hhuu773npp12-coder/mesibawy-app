import 'package:flutter/material.dart';
import 'ride_request_base_screen.dart';

class KiaHamlRequestScreen extends StatelessWidget {
  const KiaHamlRequestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const RideRequestBaseScreen(role: 'kia_haml', title: 'طلب كيا حمل');
  }
}
