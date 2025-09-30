import 'dart:math';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:maplibre_gl/mapbox_gl.dart';
import '../../core/api_client.dart';
import '../common/location_picker_screen.dart';
import 'ride_pricing.dart';

class RideRequestBaseScreen extends StatefulWidget {
  const RideRequestBaseScreen({super.key, required this.role, required this.title});
  final String role; // taxi | tuk_tuk | stuta | kia_haml
  final String title;

  @override
  State<RideRequestBaseScreen> createState() => _RideRequestBaseScreenState();
}

class _RideRequestBaseScreenState extends State<RideRequestBaseScreen> {
  final _dio = ApiClient.I.dio;
  LatLng? _start;
  LatLng? _dest;
  String? _userName;
  String? _userPhone;
  double? _distanceKm;
  int? _price;
  bool _loadingDistance = false;

  @override
  void initState() {
    super.initState();
    _loadMe();
  }

  Future<void> _loadMe() async {
    try {
      final res = await _dio.get('/users/me');
      final m = res.data as Map<String, dynamic>;
      setState(() {
        _userName = m['name']?.toString();
        _userPhone = m['phone']?.toString();
      });
    } catch (_) {}
  }

  Future<void> _pickStart() async {
    final res = await Navigator.of(context).push<LocationPickerResult>(
      MaterialPageRoute(builder: (_) => const LocationPickerScreen()),
    );
    if (res != null) {
      setState(() => _start = LatLng(res.lat, res.lng));
      await _tryComputePrice();
    }
  }

  Future<void> _pickDest() async {
    final res = await Navigator.of(context).push<LocationPickerResult>(
      MaterialPageRoute(builder: (_) => const LocationPickerScreen()),
    );
    if (res != null) {
      setState(() => _dest = LatLng(res.lat, res.lng));
      await _tryComputePrice();
    }
  }

  Future<void> _tryComputePrice() async {
    if (_start == null || _dest == null) return;
    setState(() { _loadingDistance = true; });
    try {
      // Prefer OSRM distance for route-based distance
      final url = 'https://router.project-osrm.org/route/v1/driving/${_start!.longitude},${_start!.latitude};${_dest!.longitude},${_dest!.latitude}?overview=false&alternatives=false&steps=false';
      final res = await _dio.get(url, options: Options(responseType: ResponseType.json));
      final routes = (res.data['routes'] as List?);
      double km;
      if (routes != null && routes.isNotEmpty) {
        final meters = (routes.first['distance'] as num).toDouble();
        km = meters / 1000.0;
      } else {
        // Fallback to haversine
        km = _haversineKm(_start!, _dest!);
      }
      final price = computeRidePrice(role: widget.role, distanceKm: km);
      setState(() {
        _distanceKm = double.parse(km.toStringAsFixed(2));
        _price = price;
      });
    } catch (_) {
      final km = _haversineKm(_start!, _dest!);
      final price = computeRidePrice(role: widget.role, distanceKm: km);
      setState(() {
        _distanceKm = double.parse(km.toStringAsFixed(2));
        _price = price;
      });
    } finally {
      if (mounted) setState(() { _loadingDistance = false; });
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

  void _submit() {
    if (_start == null || _dest == null || _price == null || _userName == null || _userPhone == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('أكمل البيانات أولاً')));
      return;
    }
    // TODO: POST to backend /rides (not implemented yet). For now, show a confirmation.
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('تم إرسال الطلب • السعر: ${_price} د.ع • المسافة: ${_distanceKm ?? '-'} كم')));
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: Text('مسيباوي - ${widget.title}')),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                child: ListTile(
                  leading: const Icon(Icons.person_outline),
                  title: Text(_userName ?? '—'),
                  subtitle: Text(_userPhone ?? '—'),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: OutlinedButton.icon(onPressed: _pickStart, icon: const Icon(Icons.flag_outlined), label: Text(_start == null ? 'تحديد الانطلاق' : 'تم اختيار الانطلاق'))),
                  const SizedBox(width: 8),
                  Expanded(child: OutlinedButton.icon(onPressed: _pickDest, icon: const Icon(Icons.place_outlined), label: Text(_dest == null ? 'تحديد الوجهة' : 'تم اختيار الوجهة'))),
                ],
              ),
              const SizedBox(height: 12),
              if (_loadingDistance) const LinearProgressIndicator(),
              if (_distanceKm != null || _price != null)
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.straighten),
                    title: Text('المسافة: ${_distanceKm?.toStringAsFixed(2) ?? '-'} كم'),
                    subtitle: Text('السعر: ${_price ?? '-'} د.ع'),
                  ),
                ),
              const Spacer(),
              FilledButton(
                onPressed: _submit,
                child: const Text('اطلب الآن'),
              )
            ],
          ),
        ),
      ),
    );
  }
}
