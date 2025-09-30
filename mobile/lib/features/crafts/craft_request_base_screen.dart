import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../../core/api_client.dart';
import '../common/location_picker_screen.dart';
import 'citizen_craft_api.dart';
import 'craft_request_follow_up_screen.dart';

enum WorkerOption { single, withOneAssistant, withTwoAssistants }

class CraftRequestBaseScreen extends StatefulWidget {
  const CraftRequestBaseScreen({super.key, required this.role, required this.title});
  final String role; // electrician | plumber | ac_tech | blacksmith
  final String title;

  @override
  State<CraftRequestBaseScreen> createState() => _CraftRequestBaseScreenState();
}

class _CraftRequestBaseScreenState extends State<CraftRequestBaseScreen> {
  final _api = CitizenCraftApi();
  final _dio = ApiClient.I.dio;
  final _formKey = GlobalKey<FormState>();

  final _addressCtrl = TextEditingController();
  final _detailCtrl = TextEditingController();
  WorkerOption _opt = WorkerOption.single;
  int _hours = 1;
  double? _lat;
  double? _lng;

  String? _userName;
  String? _userPhone;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _loadMe();
  }

  @override
  void dispose() {
    _addressCtrl.dispose();
    _detailCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadMe() async {
    try {
      final res = await _dio.get('/users/me');
      final m = (res.data as Map<String, dynamic>);
      setState(() {
        _userName = m['name']?.toString();
        _userPhone = m['phone']?.toString();
      });
    } catch (_) {}
  }

  int get _pricePerHour {
    switch (_opt) {
      case WorkerOption.single:
        return 10000;
      case WorkerOption.withOneAssistant:
        return 15000;
      case WorkerOption.withTwoAssistants:
        return 20000;
    }
  }

  int get _totalPrice => _pricePerHour * _hours;

  Future<void> _pickLocation() async {
    final res = await Navigator.of(context).push<LocationPickerResult>(
      MaterialPageRoute(builder: (_) => const LocationPickerScreen()),
    );
    if (res != null) {
      setState(() {
        _lat = res.lat;
        _lng = res.lng;
        if ((res.note ?? '').isNotEmpty) _addressCtrl.text = res.note!;
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_userName == null || _userPhone == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تعذر جلب بيانات المستخدم')));
      return;
    }
    setState(() => _submitting = true);
    try {
      final Response res = await _api.create(
        role: widget.role,
        citizenName: _userName!,
        citizenPhone: _userPhone!,
        address: _addressCtrl.text.trim(),
        detail: _detailCtrl.text.trim().isEmpty ? null : _detailCtrl.text.trim(),
        lat: _lat,
        lng: _lng,
        hours: _hours,
        pricePerHour: _pricePerHour,
      );
      final job = res.data as Map<String, dynamic>;
      if (!mounted) return;
      Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => CraftRequestFollowUpScreen(jobId: job['id'].toString(), role: widget.role, title: widget.title),
      ));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: Text('مسيباوي - ${widget.title}')),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _addressCtrl,
                        decoration: const InputDecoration(labelText: 'العنوان (اختياري)', border: OutlineInputBorder()),
                      ),
                    ),
                    const SizedBox(width: 8),
                    FilledButton.icon(onPressed: _pickLocation, icon: const Icon(Icons.place_outlined), label: const Text('تحديد الموقع')),
                  ],
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _detailCtrl,
                  maxLines: 4,
                  decoration: const InputDecoration(labelText: 'تفاصيل العمل', border: OutlineInputBorder()),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'أدخل تفاصيل العمل' : null,
                ),
                const SizedBox(height: 12),
                const Text('اختيار نوع الحِرفة'),
                Wrap(
                  spacing: 8,
                  children: [
                    ChoiceChip(
                      label: const Text('صاحب مهنة فقط'),
                      selected: _opt == WorkerOption.single,
                      onSelected: (_) => setState(() => _opt = WorkerOption.single),
                    ),
                    ChoiceChip(
                      label: const Text('صاحب مهنة + عامل'),
                      selected: _opt == WorkerOption.withOneAssistant,
                      onSelected: (_) => setState(() => _opt = WorkerOption.withOneAssistant),
                    ),
                    ChoiceChip(
                      label: const Text('صاحب مهنة + عاملان'),
                      selected: _opt == WorkerOption.withTwoAssistants,
                      onSelected: (_) => setState(() => _opt = WorkerOption.withTwoAssistants),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Text('عدد الساعات:'),
                    const SizedBox(width: 12),
                    IconButton(onPressed: _hours > 1 ? () => setState(() => _hours--) : null, icon: const Icon(Icons.remove_circle_outline)),
                    Text('$_hours', style: const TextStyle(fontWeight: FontWeight.bold)),
                    IconButton(onPressed: () => setState(() => _hours++), icon: const Icon(Icons.add_circle_outline)),
                    const Spacer(),
                    Text('السعر/ساعة: $_pricePerHour د.ع')
                  ],
                ),
                const SizedBox(height: 8),
                Text('الإجمالي: $_totalPrice د.ع', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: _submitting ? null : _submit,
                  child: _submitting ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('اطلب الآن'),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
