import 'dart:async';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../../core/api_client.dart';

class FoodOrderTrackingScreen extends StatefulWidget {
  const FoodOrderTrackingScreen({super.key, required this.orderId});
  final String orderId;

  @override
  State<FoodOrderTrackingScreen> createState() => _FoodOfferTrackingScreenState();
}

class _FoodOfferTrackingScreenState extends State<FoodOrderTrackingScreen> {
  Timer? _timer;
  Map<String, dynamic>? _order;
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetch();
    _timer = Timer.periodic(const Duration(seconds: 5), (_) => _fetch());
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _fetch() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final Dio dio = ApiClient.I.dio;
      final res = await dio.get('/orders/${widget.orderId}');
      setState(() => _order = (res.data is Map<String, dynamic>) ? res.data as Map<String, dynamic> : null);
    } catch (e) {
      setState(() => _error = 'تعذر جلب حالة الطلب');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final stage = _order?['breakdown']?['stage']?.toString() ?? 'pending';
    final status = _order?['status']?.toString() ?? 'CREATED';
    final total = _order?['priceTotal']?.toString() ?? '';

    return Scaffold(
      appBar: AppBar(
        title: const Text('تتبع الطلب'),
        actions: [IconButton(onPressed: _loading ? null : _fetch, icon: const Icon(Icons.refresh))],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_error != null) ...[
              Text(_error!, style: const TextStyle(color: Colors.red)),
              const SizedBox(height: 8),
            ],
            Text('إجمالي: $total د.ع', style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            _StageItem(label: 'قيد الانتظار', active: true, done: _isReached(stage, 'pending')),
            _Divider(),
            _StageItem(label: 'مقبول', active: _isActive(stage, ['accepted', 'preparing', 'delivering', 'completed']), done: _isReached(stage, 'accepted')),
            _Divider(),
            _StageItem(label: 'تحضير', active: _isActive(stage, ['preparing', 'delivering', 'completed']), done: _isReached(stage, 'preparing')),
            _Divider(),
            _StageItem(label: 'توصيل', active: _isActive(stage, ['delivering', 'completed']), done: _isReached(stage, 'delivering')),
            _Divider(),
            _StageItem(label: 'مكتمل', active: stage == 'completed', done: stage == 'completed' || status == 'COMPLETED'),
            const SizedBox(height: 16),
            if (stage == 'rejected' || status == 'CANCELLED')
              const Text('تم رفض الطلب', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  bool _isReached(String stage, String target) {
    const order = ['pending', 'accepted', 'preparing', 'delivering', 'completed'];
    return order.indexOf(stage) >= order.indexOf(target);
  }

  bool _isActive(String stage, List<String> stages) => stages.contains(stage);
}

class _StageItem extends StatelessWidget {
  const _StageItem({required this.label, required this.active, required this.done});
  final String label;
  final bool active;
  final bool done;

  @override
  Widget build(BuildContext context) {
    final color = done ? Colors.green : (active ? Theme.of(context).colorScheme.primary : Colors.grey);
    return Row(
      children: [
        Icon(done ? Icons.check_circle : Icons.radio_button_unchecked, color: color),
        const SizedBox(width: 8),
        Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w600)),
      ],
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) => const Padding(
        padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16),
        child: SizedBox(height: 12, child: VerticalDivider(thickness: 2)),
      );
}
