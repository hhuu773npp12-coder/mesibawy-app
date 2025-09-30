import 'package:flutter/material.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MesibawyWebApp());
}

class MesibawyWebApp extends StatelessWidget {
  const MesibawyWebApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mesibawy (Web Preview)',
      debugShowCheckedModeBanner: false,
      locale: const Locale('ar'),
      supportedLocales: const [Locale('ar'), Locale('en')],
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0E6BA8)),
        useMaterial3: true,
      ),
      home: const _WebHome(),
    );
  }
}

class _WebHome extends StatelessWidget {
  const _WebHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: const Text('مسيباوي - نسخة الويب')), 
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(Icons.directions_car_filled_outlined, size: 72),
              SizedBox(height: 16),
              Text('تشغيل مبدئي لنسخة الويب ناجح'),
            ],
          ),
        ),
      ),
    );
  }
}
