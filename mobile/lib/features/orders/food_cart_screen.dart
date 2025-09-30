import 'dart:async';
import 'dart:math';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:maplibre_gl/mapbox_gl.dart';
import '../../core/api_client.dart';
import '../common/location_picker_screen.dart';
import 'food_cart.dart';
import 'delivery_pricing.dart';
import '../citizen/food_order_tracking_screen.dart';

class FoodCartScreen extends StatefulWidget {
  const FoodCartScreen({super.key});

  @override
  State<FoodCartScreen> createState() => _FoodCartScreenState();
}

class _FoodCartScreenState extends State<FoodCartScreen> {
  final cart = FoodCart.I;
  final dio = ApiClient.I.dio;

  LatLng? _origin; // المطعم (إن توفر)
  LatLng? _dest; // موقع المواطن
  double? _distanceKm;
  bool _busy = false;

  String? get _restaurantKey {
    // حاول استنتاج معرف المطعم من عناصر السلة
    String? key;
    for (final it in cart.items) {
      final m = it.offer;
      final rId = m['restaurantId']?.toString() ?? (m['restaurant']?['id']?.toString());
      if (rId == null) return null;
      key ??= rId;
      if (key != rId) return null; // سلة مختلطة من مطاعم مختلفة
    }
    return key;
  }

  LatLng? get _restaurantCoords {
    for (final it in cart.items) {
      final m = it.offer;
      final lat = (m['restaurant']?['lat'] as num?)?.toDouble();
      final lng = (m['restaurant']?['lng'] as num?)?.toDouble();
      if (lat != null && lng != null) return LatLng(lat, lng);
    }
    return null;
  }

  int get _itemsTotal => cart.itemsTotal;
  int get _serviceFee => kServiceFeeIqD;
  int get _deliveryFee => _distanceKm == null ? 0 : computeDeliveryFeeIqD(_distanceKm!);
  int get _grandTotal => _itemsTotal + _serviceFee + _deliveryFee;

  Future<void> _pickDest() async {
    final res = await Navigator.of(context).push<LocationPickerResult>(
      MaterialPageRoute(builder: (_) => const LocationPickerScreen()),
    );
    if (res != null) {
      setState(() => _dest = LatLng(res.lat, res.lng));
      await _computeDistance();
    }
  }

  Future<void> _pickOrigin() async {
    final res = await Navigator.of(context).push<LocationPickerResult>(
      MaterialPageRoute(builder: (_) => const LocationPickerScreen()),
    );
    if (res != null) {
      setState(() => _origin = LatLng(res.lat, res.lng));
      await _computeDistance();
    }
  }

  Future<void> _computeDistance() async {
    final origin = _origin ?? _restaurantCoords;
    if (origin == null || _dest == null) return;
    try {
      final url = 'https://router.project-osrm.org/route/v1/driving/${origin.longitude},${origin.latitude};${_dest!.longitude},${_dest!.latitude}?overview=false&alternatives=false&steps=false';
      final res = await dio.get(url, options: Options(responseType: ResponseType.json));
      final routes = (res.data['routes'] as List?);
      double km;
      if (routes != null && routes.isNotEmpty) {
        km = ((routes.first['distance'] as num).toDouble()) / 1000.0;
      } else {
        km = _haversineKm(origin, _dest!);
      }
      setState(() => _distanceKm = double.parse(km.toStringAsFixed(2)));
    } catch (_) {
      setState(() => _distanceKm = _haversineKm(origin, _dest!));
    }
  }

  double _haversineKm(LatLng a, LatLng b) {
    const R = 6371.0;
    final dLat = _deg2rad(b.latitude - a.latitude);
    final dLon = _deg2rad(b.longitude - a.longitude);
    final la1 = _deg2rad(a.latitude);
    final la2 = _deg2rad(b.latitude);
    final h = pow(sin(dLat / 2), 2) + cos(la1) * cos(la2) * pow(sin(dLon / 2), 2);
    return 2 * R * asin(min(1, sqrt(h)));
  }

  double _deg2rad(double deg) => deg * (pi / 180.0);

  Future<void> _checkout() async {
    if (cart.items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('السلة فارغة')));
      return;
    }
    if (_dest == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('اختر موقع التوصيل')));
      return;
    }
    if (_restaurantKey == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('السلة تحتوي عروضاً من مطاعم مختلفة. اطلب من مطعم واحد.')));
      return;
    }
    setState(() => _busy = true);
    try {
      // محاولة إنشاء طلب موحد إن كان الخادم يدعمه، وإلا إرسال العناصر فردياً.
      String? firstOrderId;
      for (final it in cart.items) {
        final resp = await dio.post('/orders/food', data: {
          'offerId': it.offer['id'],
          'quantity': it.quantity,
          'destLat': _dest!.latitude,
          'destLng': _dest!.longitude,
          if (_origin != null) 'originLat': _origin!.latitude,
          if (_origin != null) 'originLng': _origin!.longitude,
          'paymentMethod': 'cod', // Cash on Delivery
          'clientBreakdown': {
            'itemsTotal': _itemsTotal,
            'serviceFee': _serviceFee,
            'deliveryFee': _deliveryFee,
            'grandTotal': _grandTotal,
            'distanceKm': _distanceKm,
            'paymentMethod': 'cod',
          },
        });
        final data = resp.data;
        if (firstOrderId == null && data is Map<String, dynamic>) {
          firstOrderId = data['id']?.toString() ?? (data['order']?['id']?.toString());
        }
      }
      cart.clear();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم إرسال الطلب إلى الإدارة')));
      if (firstOrderId != null) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => FoodOrderTrackingScreen(orderId: firstOrderId!)),
        );
      } else {
        Navigator.of(context).pop();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('تعذر إكمال الطلب: ${e.toString()}')));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final restaurantCoords = _restaurantCoords;
    final needsOriginPick = restaurantCoords == null;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: const Text('سلة الطعام')),
        body: SafeArea(
          child: Column(
          children: [
            Expanded(
              child: ListView.separated(
                itemBuilder: (_, i) {
                  final it = cart.items[i];
                  final id = it.offer['id']?.toString() ?? '';
                  final name = it.offer['name']?.toString() ?? 'عرض';
                  final price = (it.offer['price'] as num?)?.toInt() ?? 0;
                  return ListTile(
                    title: Text(name),
                    subtitle: Text('السعر: $price د.ع × ${it.quantity} = ${price * it.quantity} د.ع'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(onPressed: it.quantity > 1 ? () { setState(() => it.quantity--); } : null, icon: const Icon(Icons.remove_circle_outline)),
                        Text('${it.quantity}'),
                        IconButton(onPressed: () { setState(() => it.quantity++); }, icon: const Icon(Icons.add_circle_outline)),
                        IconButton(onPressed: () { setState(() { cart.remove(id); }); }, icon: const Icon(Icons.delete_outline)),
                      ],
                    ),
                  );
                },
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemCount: cart.items.length,
              ),
            ),
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (needsOriginPick) ...[
                    OutlinedButton.icon(onPressed: _pickOrigin, icon: const Icon(Icons.store_mall_directory_outlined), label: Text(_origin == null ? 'تحديد موقع المطعم (إن لزم)' : 'تم اختيار موقع المطعم')),
                    const SizedBox(height: 8),
                  ],
                  OutlinedButton.icon(onPressed: _pickDest, icon: const Icon(Icons.place_outlined), label: Text(_dest == null ? 'تحديد موقع التوصيل' : 'تم اختيار موقع التوصيل')),
                  const SizedBox(height: 8),
                  Text('مجموع العروض: $_itemsTotal د.ع'),
                  Text('خدمة: $_serviceFee د.ع'),
                  Text('المسافة: ${_distanceKm?.toStringAsFixed(2) ?? '—'} كم'),
                  Text('التوصيل: $_deliveryFee د.ع'),
                  const SizedBox(height: 4),
                  const Text('طريقة الدفع: عند الاستلام', style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  Text('الإجمالي: $_grandTotal د.ع', style: const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  FilledButton(onPressed: _busy ? null : _checkout, child: _busy ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('اتمام الطلب (الدفع عند الاستلام)')),
                ],
              ),
            ),
          ],
        ),
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: ListView.separated(
                  itemBuilder: (_, i) {
                    final it = cart.items[i];
                    final id = it.offer['id']?.toString() ?? '';
                    final name = it.offer['name']?.toString() ?? 'عرض';
                    final price = (it.offer['price'] as num?)?.toInt() ?? 0;
                    return ListTile(
                      title: Text(name),
                      subtitle: Text('السعر: $price د.ع × ${it.quantity} = ${price * it.quantity} د.ع'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(onPressed: it.quantity > 1 ? () { setState(() => it.quantity--); } : null, icon: const Icon(Icons.remove_circle_outline)),
                          Text('${it.quantity}'),
                          IconButton(onPressed: () { setState(() => it.quantity++); }, icon: const Icon(Icons.add_circle_outline)),
                          IconButton(onPressed: () { setState(() { cart.remove(id); }); }, icon: const Icon(Icons.delete_outline)),
                        ],
                      ),
                    );
                  },
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemCount: cart.items.length,
                ),
              ),
              const Divider(height: 1),
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (needsOriginPick) ...[
                      OutlinedButton.icon(onPressed: _pickOrigin, icon: const Icon(Icons.store_mall_directory_outlined), label: Text(_origin == null ? 'تحديد موقع المطعم (إن لزم)' : 'تم اختيار موقع المطعم')),
                      const SizedBox(height: 8),
                    ],
                    OutlinedButton.icon(onPressed: _pickDest, icon: const Icon(Icons.place_outlined), label: Text(_dest == null ? 'تحديد موقع التوصيل' : 'تم اختيار موقع التوصيل')),
                    const SizedBox(height: 8),
                    Text('مجموع العروض: $_itemsTotal د.ع'),
                    Text('خدمة: $_serviceFee د.ع'),
                    Text('المسافة: ${_distanceKm?.toStringAsFixed(2) ?? '—'} كم'),
                    Text('التوصيل: $_deliveryFee د.ع'),
                    const SizedBox(height: 4),
                    const Text('طريقة الدفع: عند الاستلام', style: TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    Text('الإجمالي: $_grandTotal د.ع', style: const TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    FilledButton(onPressed: _busy ? null : _checkout, child: _busy ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('اتمام الطلب (الدفع عند الاستلام)')),
                  ],
                ),
              ),
