import 'package:flutter/material.dart';
import 'citizen_api.dart';
import '../map/map_screen.dart';
import '../common/location_picker_screen.dart';

class EnergyRequestScreen extends StatefulWidget {
  const EnergyRequestScreen({super.key, required this.offer});
  final Map<String, dynamic> offer;

  @override
  State<EnergyRequestScreen> createState() => _EnergyRequestScreenState();
}

class _EnergyRequestScreenState extends State<EnergyRequestScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();
  double? _lat;
  double? _lng;
  bool _loading = false;
  final _api = CitizenApi();

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _locationCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickOnMap() async {
    final res = await Navigator.of(context).push<LocationPickerResult>(
      MaterialPageRoute(builder: (_) => const LocationPickerScreen()),
    );
    if (res != null) {
      setState(() {
        _lat = res.lat;
        _lng = res.lng;
        if ((res.note ?? '').isNotEmpty) {
          _locationCtrl.text = res.note!;
        }
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('تم اختيار الموقع: ${res.lat.toStringAsFixed(5)}, ${res.lng.toStringAsFixed(5)}')),
      );
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      await _api.createEnergyRequest(
        name: _nameCtrl.text.trim(),
        phone: _phoneCtrl.text.trim(),
        location: _locationCtrl.text.trim().isEmpty ? null : _locationCtrl.text.trim(),
        lat: _lat,
        lng: _lng,
        offerId: widget.offer['id']?.toString(),
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم إرسال الطلب إلى المالك')));
      Navigator.of(context).pop();
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تعذر إرسال الطلب')));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final offer = widget.offer;
    return Scaffold(
      appBar: AppBar(title: Text('طلب عرض: ${offer['title'] ?? ''}')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Text('الماركة: ${offer['brand'] ?? ''}'),
              const SizedBox(height: 8),
              Text(offer['details']?.toString() ?? ''),
              const Divider(height: 24),
              const Text('الاسم'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _nameCtrl,
                decoration: const InputDecoration(border: OutlineInputBorder(), hintText: 'اسمك'),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'أدخل الاسم' : null,
              ),
              const SizedBox(height: 12),
              const Text('رقم الهاتف'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _phoneCtrl,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(border: OutlineInputBorder(), hintText: '07XXXXXXXXX'),
                validator: (v) {
                  final s = (v ?? '').trim();
                  if (s.isEmpty) return 'أدخل رقم الهاتف';
                  if (s.length < 7) return 'رقم الهاتف غير صحيح';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              const Text('الموقع (وصف نصي)'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _locationCtrl,
                decoration: const InputDecoration(border: OutlineInputBorder(), hintText: 'المحافظة/المنطقة/الوصف...'),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: _pickOnMap,
                icon: const Icon(Icons.map_outlined),
                label: const Text('تحديد على الخريطة (محافظة بابل)'),
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: _loading ? null : _submit,
                child: _loading
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Text('طلب الآن'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
