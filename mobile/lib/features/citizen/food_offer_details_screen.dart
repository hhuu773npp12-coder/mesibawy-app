import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../../core/api_client.dart';
import 'food_order_tracking_screen.dart';

class FoodOfferDetailsScreen extends StatefulWidget {
  const FoodOfferDetailsScreen({super.key, required this.offer});
  final Map<String, dynamic> offer;

  @override
  State<FoodOfferDetailsScreen> createState() => _FoodOfferDetailsScreenState();
}

class _FoodOfferDetailsScreenState extends State<FoodOfferDetailsScreen> {
  int _qty = 1;
  final _notesCtrl = TextEditingController();
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _createOrder() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final Dio dio = ApiClient.I.dio;
      final res = await dio.post('/orders/food', data: {
        'offerId': widget.offer['id'],
        'quantity': _qty,
        if (_notesCtrl.text.trim().isNotEmpty) 'notes': _notesCtrl.text.trim(),
      });
      if (!mounted) return;
      final data = res.data;
      String? orderId;
      if (data is Map<String, dynamic>) {
        // could be full order or wrapper {order: {...}}
        if (data['id'] != null) orderId = data['id'] as String;
        if (orderId == null && data['order'] is Map<String, dynamic>) {
          orderId = (data['order'] as Map<String, dynamic>)['id']?.toString();
        }
      }
      if (orderId != null) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => FoodOrderTrackingScreen(orderId: orderId!)),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم إنشاء الطلب')));
      }
    } catch (e) {
      setState(() => _error = 'تعذر إنشاء الطلب. تأكد من تسجيل الدخول كمواطن.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final offer = widget.offer;
    final name = offer['name']?.toString() ?? '';
    final price = (offer['price'] ?? 0) as int;

    return Scaffold(
      appBar: AppBar(title: const Text('تفاصيل العرض')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('السعر: $price د.ع'),
            const SizedBox(height: 16),
            const Text('الكمية'),
            const SizedBox(height: 8),
            Row(
              children: [
                IconButton(
                  onPressed: _qty > 1 ? () => setState(() => _qty--) : null,
                  icon: const Icon(Icons.remove_circle_outline),
                ),
                Text('$_qty', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                IconButton(
                  onPressed: () => setState(() => _qty++),
                  icon: const Icon(Icons.add_circle_outline),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text('ملاحظات (اختياري)'),
            const SizedBox(height: 8),
            TextField(
              controller: _notesCtrl,
              maxLines: 3,
              decoration: const InputDecoration(border: OutlineInputBorder(), hintText: 'تعليمات إضافية...'),
            ),
            const SizedBox(height: 12),
            if (_error != null) ...[
              Text(_error!, style: const TextStyle(color: Colors.red)),
              const SizedBox(height: 8),
            ],
            FilledButton(
              onPressed: _loading ? null : _createOrder,
              child: _loading
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Text('اطلب الآن'),
            ),
          ],
        ),
      ),
    );
  }
}
