import 'package:flutter/material.dart';

class DriverHome extends StatefulWidget {
  const DriverHome({super.key});

  @override
  State<DriverHome> createState() => _DriverHomeState();
}

class _DriverHomeState extends State<DriverHome> {
  bool _online = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('واجهة السائق')),
      body: SafeArea(
        child: Column(
          children: [
          SwitchListTile(
            title: const Text('الحالة: متصل/غير متصل'),
            value: _online,
            onChanged: (v) => setState(() => _online = v),
          ),
          const Divider(height: 1),
          Expanded(
            child: DefaultTabController(
              length: 3,
              child: Column(
                children: const [
                  TabBar(tabs: [
                    Tab(text: 'قيد الانتظار'),
                    Tab(text: 'نشطة'),
                    Tab(text: 'مكتملة'),
                  ]),
                  Expanded(
                    child: TabBarView(children: [
                      _TripsPlaceholder(label: 'طلبات قيد الانتظار'),
                      _TripsPlaceholder(label: 'طلبات نشطة'),
                      _TripsPlaceholder(label: 'طلبات مكتملة'),
                    ]),
                  ),
                ],
              ),
            ),
          )
        ],
        ),
      ),
    );
  }
}

class _TripsPlaceholder extends StatelessWidget {
  const _TripsPlaceholder({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemBuilder: (_, i) => ListTile(
        leading: const Icon(Icons.directions_car),
        title: Text('$label #${i + 1}'),
        subtitle: const Text('تفاصيل مختصرة ستستبدل لاحقاً ببيانات حقيقية'),
        trailing: Wrap(
          spacing: 8,
          children: const [
            Icon(Icons.check_circle_outline),
            Icon(Icons.cancel_outlined),
          ],
        ),
      ),
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemCount: 8,
    );
  }
}
