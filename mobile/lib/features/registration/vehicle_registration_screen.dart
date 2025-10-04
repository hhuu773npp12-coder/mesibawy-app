import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';
import '../../core/api_client.dart';
import '../common/waiting_approval_screen.dart';

class VehicleRegistrationScreen extends StatefulWidget {
  const VehicleRegistrationScreen({super.key});

  @override
  State<VehicleRegistrationScreen> createState() => _VehicleRegistrationScreenState();
}

class _VehicleRegistrationScreenState extends State<VehicleRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  // تمت إزالة اختيار نوع المركبة حسب المتطلبات
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _colorCtrl = TextEditingController();
  final _plateCtrl = TextEditingController();
  final _plateUrlCtrl = TextEditingController(); // مؤقتاً كرابط نصي
  bool _loading = false;
  String? _error;
  String? _pickedPath;
  bool _uploading = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _colorCtrl.dispose();
    _plateCtrl.dispose();
    _plateUrlCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickAndUpload() async {
    setState(() => _error = null);
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
      if (picked == null) return;
      setState(() => _pickedPath = picked.path);

      setState(() => _uploading = true);
      final form = FormData.fromMap({
        'file': await MultipartFile.fromFile(picked.path, filename: p.basename(picked.path)),
      });
      final res = await ApiClient.I.dio.post('/files/upload', data: form);
      final data = res.data as Map<String, dynamic>;
      final url = data['url']?.toString();
      if (url != null && url.isNotEmpty) {
        setState(() => _plateUrlCtrl.text = url);
      }
    } catch (e) {
      setState(() => _error = 'فشل رفع الصورة');
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await ApiClient.I.dio.post('/profile/vehicle', data: {
        'name': _nameCtrl.text.trim(),
        'phone': _phoneCtrl.text.trim(),
        if (_colorCtrl.text.trim().isNotEmpty) 'vehicleColor': _colorCtrl.text.trim(),
        if (_plateCtrl.text.trim().isNotEmpty) 'plateNumber': _plateCtrl.text.trim(),
        if (_plateUrlCtrl.text.trim().isNotEmpty) 'plateImageUrl': _plateUrlCtrl.text.trim(),
      });
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const WaitingApprovalScreen()),
        (route) => false,
      );
    } catch (e) {
      setState(() => _error = 'تعذر حفظ البيانات. حاول مجدداً.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('إكمال بيانات المركبة')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              const Text('الاسم'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _nameCtrl,
                textDirection: TextDirection.rtl,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'اسم المالك',
                ),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'يرجى إدخال الاسم' : null,
              ),
              const SizedBox(height: 12),
              const Text('رقم الهاتف'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _phoneCtrl,
                keyboardType: TextInputType.phone,
                textDirection: TextDirection.ltr,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: '07XXXXXXXXX',
                ),
                validator: (v) {
                  final s = (v ?? '').trim();
                  if (s.isEmpty) return 'الرجاء إدخال رقم الهاتف';
                  if (s.length < 7) return 'رقم الهاتف غير صحيح';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              const Text('لون المركبة (اختياري)'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _colorCtrl,
                decoration: const InputDecoration(border: OutlineInputBorder(), hintText: 'أبيض/أسود..'),
              ),
              const SizedBox(height: 12),
              const Text('رقم اللوحة (اختياري)'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _plateCtrl,
                decoration: const InputDecoration(border: OutlineInputBorder(), hintText: 'رقم اللوحة'),
              ),
              const SizedBox(height: 12),
              const Text('صورة اللوحة (اختياري)'),
              const SizedBox(height: 8),
              Row(
                children: [
                  ElevatedButton.icon(
                    onPressed: _uploading ? null : _pickAndUpload,
                    icon: _uploading
                        ? const SizedBox(height: 16, width: 16, child: CircularProgressIndicator(strokeWidth: 2))
                        : const Icon(Icons.upload_file),
                    label: const Text('اختيار ورفع صورة'),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _plateUrlCtrl,
                      readOnly: true,
                      decoration: const InputDecoration(border: OutlineInputBorder(), hintText: 'URL'),
                    ),
                  ),
                ],
              ),
              if (_pickedPath != null) ...[
                const SizedBox(height: 8),
                SizedBox(height: 120, child: Image.file(File(_pickedPath!), fit: BoxFit.cover)),
              ],
              const SizedBox(height: 12),
              if (_error != null) ...[
                Text(_error!, style: const TextStyle(color: Colors.red)),
                const SizedBox(height: 8),
              ],
              FilledButton(
                onPressed: _loading ? null : _submit,
                child: _loading
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Text('حفظ وإرسال للموافقة'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
