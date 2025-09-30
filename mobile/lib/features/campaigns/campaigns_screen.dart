import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:maplibre_gl/mapbox_gl.dart';
import '../../core/api_client.dart';
import '../common/location_picker_screen.dart';
import '../auth/auth_api.dart';
import 'campaigns_api.dart';

class CampaignsScreen extends StatefulWidget {
  const CampaignsScreen({super.key});

  @override
  State<CampaignsScreen> createState() => _CampaignsScreenState();
}

class _CampaignsScreenState extends State<CampaignsScreen> {
  final _api = CampaignsApi();
  bool _loading = false;
  List<dynamic> _items = [];

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  Future<void> _fetch() async {
    setState(() => _loading = true);
    try {
      final res = await _api.list();
      setState(() => _items = (res.data as List));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _book(Map<String, dynamic> c) async {
    final pick = await showDialog<_BookingInput>(
      context: context,
      builder: (ctx) => _BookingDialog(campaign: c),
    );
    if (pick == null) return;

    try {
      final auth = AuthApi(ApiClient.I.dio);
      final me = await auth.me();
      final m = me.data as Map<String, dynamic>;
      final userId = m['id']?.toString();
      if (userId == null) throw Exception('no user');

      await _api.book(
        campaignId: c['id'].toString(),
        userId: userId,
        count: pick.count,
        originLat: pick.origin?.latitude,
        originLng: pick.origin?.longitude,
        destLat: pick.dest?.latitude,
        destLng: pick.dest?.longitude,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم إرسال الحجز إلى الإدارة')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('تعذر الحجز: ${e.toString()}')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('حملات الزيارة'),
          actions: [IconButton(onPressed: _loading ? null : _fetch, icon: const Icon(Icons.refresh))],
        ),
        body: SafeArea(
          child: _loading
              ? const Center(child: CircularProgressIndicator())
              : ListView.separated(
                itemBuilder: (_, i) {
                  final it = _items[i] as Map<String, dynamic>;
                  final remaining = (it['seatsTotal'] as int) - (it['seatsBooked'] as int);
                  return ListTile(
                    leading: const Icon(Icons.campaign_outlined),
                    title: Text(it['title']?.toString() ?? ''),
                    subtitle: Text('الموقع: ${it['originArea']} • المقاعد المتاحة: $remaining • السعر/مقعد: ${it['pricePerSeat']} د.ع'),
                    trailing: FilledButton(onPressed: remaining > 0 ? () => _book(it) : null, child: const Text('حجز')),
                  );
                },
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemCount: _items.length,
              ),
        ),
      ),
    );
  }
}

class _BookingInput {
  _BookingInput({this.origin, this.dest, required this.count});
  final LatLng? origin;
  final LatLng? dest;
  final int count;
}

class _BookingDialog extends StatefulWidget {
  const _BookingDialog({required this.campaign});
  final Map<String, dynamic> campaign;

  @override
  State<_BookingDialog> createState() => _BookingDialogState();
}

class _BookingDialogState extends State<_BookingDialog> {
  LatLng? _origin;
  LatLng? _dest;
  int _count = 1;

  Future<void> _pickOrigin() async {
    final res = await Navigator.of(context).push<LocationPickerResult>(
      MaterialPageRoute(builder: (_) => const LocationPickerScreen()),
    );
    if (res != null) setState(() => _origin = LatLng(res.lat, res.lng));
  }

  Future<void> _pickDest() async {
    final res = await Navigator.of(context).push<LocationPickerResult>(
      MaterialPageRoute(builder: (_) => const LocationPickerScreen()),
    );
    if (res != null) setState(() => _dest = LatLng(res.lat, res.lng));
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('حجز حملة'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          OutlinedButton.icon(onPressed: _pickOrigin, icon: const Icon(Icons.flag_outlined), label: Text(_origin == null ? 'تحديد موقع الانطلاق' : 'تم اختيار الانطلاق')),
          const SizedBox(height: 8),
          OutlinedButton.icon(onPressed: _pickDest, icon: const Icon(Icons.place_outlined), label: Text(_dest == null ? 'تحديد موقع الوصول' : 'تم اختيار الوجهة')),
          const SizedBox(height: 8),
          Row(
            children: [
              const Text('العدد:'),
              const SizedBox(width: 12),
              IconButton(onPressed: _count > 1 ? () => setState(() => _count--) : null, icon: const Icon(Icons.remove_circle_outline)),
              Text('$_count'),
              IconButton(onPressed: () => setState(() => _count++), icon: const Icon(Icons.add_circle_outline)),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('إلغاء')),
        FilledButton(onPressed: () => Navigator.pop(context, _BookingInput(origin: _origin, dest: _dest, count: _count)), child: const Text('حجز الآن')),
      ],
    );
  }
}
