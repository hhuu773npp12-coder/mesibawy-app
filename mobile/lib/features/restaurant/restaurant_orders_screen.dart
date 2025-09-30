import 'package:flutter/material.dart';
import 'restaurant_api.dart';

class RestaurantOrdersScreen extends StatefulWidget {
  const RestaurantOrdersScreen({super.key});

  @override
  State<RestaurantOrdersScreen> createState() => _RestaurantOrdersScreenState();
}

class _RestaurantOrdersScreenState extends State<RestaurantOrdersScreen> {
  final _api = RestaurantApi();
  bool _loading = false;
  String? _stageFilter;
  List<dynamic> _items = [];

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  Future<void> _fetch() async {
    setState(() => _loading = true);
    try {
      final res = await _api.listOrders(stage: _stageFilter);
      setState(() => _items = (res.data as List));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _updateStage(String id, String stage) async {
    setState(() => _loading = true);
    try {
      await _api.updateOrderStage(id: id, stage: stage);
      await _fetch();
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  List<Widget> _stageButtons(Map<String, dynamic> it) {
    final stage = (it['breakdown']?['stage'] ?? 'pending').toString();
    final id = it['id']?.toString() ?? '';
    switch (stage) {
      case 'pending':
        return [
          TextButton(onPressed: () => _updateStage(id, 'accepted'), child: const Text('قبول')),
          TextButton(onPressed: () => _updateStage(id, 'rejected'), child: const Text('رفض')),
        ];
      case 'accepted':
        return [TextButton(onPressed: () => _updateStage(id, 'preparing'), child: const Text('تحضير'))];
      case 'preparing':
        return [TextButton(onPressed: () => _updateStage(id, 'delivering'), child: const Text('توصيل'))];
      case 'delivering':
        return [TextButton(onPressed: () => _updateStage(id, 'completed'), child: const Text('إكمال'))];
      case 'completed':
        return [const Text('مكتمل', style: TextStyle(color: Colors.green))];
      case 'rejected':
        return [const Text('مرفوض', style: TextStyle(color: Colors.red))];
      default:
        return [Text(stage)];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('طلبات المطعم'),
        actions: [
          DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _stageFilter,
              hint: const Text('المرحلة', style: TextStyle(color: Colors.white)),
              items: const [
                DropdownMenuItem(value: 'pending', child: Text('قيد الانتظار')),
                DropdownMenuItem(value: 'accepted', child: Text('مقبول')),
                DropdownMenuItem(value: 'preparing', child: Text('تحضير')),
                DropdownMenuItem(value: 'delivering', child: Text('توصيل')),
                DropdownMenuItem(value: 'completed', child: Text('مكتمل')),
                DropdownMenuItem(value: 'rejected', child: Text('مرفوض')),
              ],
              onChanged: (v) {
                setState(() => _stageFilter = v);
                _fetch();
              },
            ),
          ),
          IconButton(onPressed: _loading ? null : _fetch, icon: const Icon(Icons.refresh)),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.separated(
              itemBuilder: (_, i) {
                final it = _items[i] as Map<String, dynamic>;
                final name = it['breakdown']?['offerName']?.toString() ?? '';
                final qty = it['breakdown']?['quantity']?.toString() ?? '1';
                final stage = it['breakdown']?['stage']?.toString() ?? 'pending';
                final total = it['priceTotal']?.toString() ?? '';
                return ListTile(
                  title: Text('$name × $qty'),
                  subtitle: Text('المرحلة: $stage • الإجمالي: $total د.ع'),
                  trailing: Wrap(spacing: 4, children: _stageButtons(it)),
                );
              },
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemCount: _items.length,
            ),
    );
  }
}
