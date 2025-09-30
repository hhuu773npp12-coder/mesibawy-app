import 'dart:math';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:maplibre_gl/mapbox_gl.dart';
import '../../core/api_client.dart';
import '../common/location_picker_screen.dart';
import 'student_lines_api.dart';

class StudentLineRequestScreen extends StatefulWidget {
  const StudentLineRequestScreen({super.key});

  @override
  State<StudentLineRequestScreen> createState() => _StudentLineRequestScreenState();
}

class _StudentLineRequestScreenState extends State<StudentLineRequestScreen> {
  final _api = StudentLinesApi();
  final _dio = ApiClient.I.dio;

  LatLng? _origin;
  LatLng? _dest;
  String _kind = 'school';
  int _count = 1;
  String? _userName;
  String? _userPhone;
  double? _distanceKm;
  int? _weeklyPrice;
  bool _busy = false;

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

  Future<void> _pickOrigin() async {
    final res = await Navigator.of(context).push<LocationPickerResult>(
      MaterialPageRoute(builder: (_) => const LocationPickerScreen()),
    );
    if (res != null) {
      setState(() => _origin = LatLng(res.lat, res.lng));
      await _computePrice();
    }
  }

  Future<void> _pickDest() async {
    final res = await Navigator.of(context).push<LocationPickerResult>(
      MaterialPageRoute(builder: (_) => const LocationPickerScreen()),
    );
    if (res != null) {
      setState(() => _dest = LatLng(res.lat, res.lng));
      await _computePrice();
    }
  }

  Future<void> _computePrice() async {
    if (_origin == null || _dest == null) return;
    try {
      final url = 'https://router.project-osrm.org/route/v1/driving/${_origin!.longitude},${_origin!.latitude};${_dest!.longitude},${_dest!.latitude}?overview=false&alternatives=false&steps=false';
      final res = await _dio.get(url, options: Options(responseType: ResponseType.json));
      final routes = (res.data['routes'] as List?);
      double km;
      if (routes != null && routes.isNotEmpty) {
        km = ((routes.first['distance'] as num).toDouble()) / 1000.0;
      } else {
        km = _haversineKm(_origin!, _dest!);
      }
      setState(() {
        _distanceKm = double.parse(km.toStringAsFixed(2));
      });
      // weekly price computed server-side on submission; here we show hint per brackets
      // Keeping UI price as informational; final comes from server
    } catch (_) {
      setState(() {
        _distanceKm = _haversineKm(_origin!, _dest!);
      });
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

  Future<void> _submit() async {
    if (_origin == null || _dest == null || _distanceKm == null || _userName == null || _userPhone == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('أكمل البيانات أولاً')));
      return;
    }
    setState(() => _busy = true);
    try {
      final resp = await _api.createPublicRequest(
        citizenName: _userName!,
        citizenPhone: _userPhone!,
        kind: _kind,
        count: _count,
        originLat: _origin!.latitude,
        originLng: _origin!.longitude,
        destLat: _dest!.latitude,
        destLng: _dest!.longitude,
        distanceKm: _distanceKm!,
      );
      final data = resp.data as Map<String, dynamic>;
      setState(() => _weeklyPrice = (data['weeklyPrice'] as num).toInt());
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم إرسال الطلب إلى الإدارة')));
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: const Text('التسجيل في خط الطلاب')),
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
                  Expanded(child: OutlinedButton.icon(onPressed: _pickOrigin, icon: const Icon(Icons.flag_outlined), label: Text(_origin == null ? 'تحديد موقع الانطلاق' : 'تم اختيار الانطلاق'))),
                  const SizedBox(width: 8),
                  Expanded(child: OutlinedButton.icon(onPressed: _pickDest, icon: const Icon(Icons.place_outlined), label: Text(_dest == null ? 'تحديد موقع المدرسة/الجامعة' : 'تم اختيار الوجهة'))),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Text('النوع:'),
                  const SizedBox(width: 8),
                  ChoiceChip(label: const Text('مدرسة'), selected: _kind == 'school', onSelected: (_) => setState(() => _kind = 'school')),
                  const SizedBox(width: 8),
                  ChoiceChip(label: const Text('جامعة'), selected: _kind == 'university', onSelected: (_) => setState(() => _kind = 'university')),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Text('العدد:'),
                  const SizedBox(width: 12),
                  IconButton(onPressed: _count > 1 ? () => setState(() => _count--) : null, icon: const Icon(Icons.remove_circle_outline)),
                  Text('$_count', style: const TextStyle(fontWeight: FontWeight.bold)),
                  IconButton(onPressed: () => setState(() => _count++), icon: const Icon(Icons.add_circle_outline)),
                ],
              ),
              const SizedBox(height: 12),
              if (_distanceKm != null) Text('المسافة التقديرية: ${_distanceKm!.toStringAsFixed(2)} كم'),
              if (_weeklyPrice != null) Text('السعر الأسبوعي المحسوب: $_weeklyPrice د.ع'),
              const Spacer(),
              FilledButton(onPressed: _busy ? null : _submit, child: _busy ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('الحجز الآن')),
            ],
          ),
        ),
      ),
    );
  }
}
