import 'package:flutter/material.dart';

class WaitingApprovalScreen extends StatelessWidget {
  const WaitingApprovalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('بانتظار الموافقة')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(Icons.watch_later_outlined, size: 64, color: Colors.orange),
              SizedBox(height: 16),
              Text(
                'طلبك قيد المراجعة من قِبل الأدمن. سيتم إشعارك عند الموافقة،'
                '\nوسوف نتواصل معك لتحديد موعد توقيع عقد مع الشركة.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
