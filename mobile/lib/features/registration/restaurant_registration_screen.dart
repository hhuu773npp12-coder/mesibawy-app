import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/api_client.dart';
import '../common/waiting_approval_screen.dart';

class RestaurantRegistrationScreen extends StatefulWidget {
  const RestaurantRegistrationScreen({super.key});

  @override
  State<RestaurantRegistrationScreen> createState() => _RestaurantRegistrationScreenState();
}

class _RestaurantRegistrationScreenState extends State<RestaurantRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  bool _loading = false;
  bool _uploading = false;
  String? _logoUrl;
  String? _pickedPath;
  String? _error;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickAndUploadLogo() async {
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
      if (url != null && url.isNotEmpty) setState(() => _logoUrl = url);
    } catch (e) {
      setState(() => _error = 'فشل رفع الشعار');
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
      // TODO: ربط مسار تسجيل صاحب المطعم في الباك-إند عند توفره.
      // مؤقتاً نحدّث حالة الجهاز بأن التسجيل مكتمل وننتقل لواجهة انتظار موافقة المشرف.
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('restaurant_registered', true);

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
      appBar: AppBar(title: const Text('تسجيل صاحب المطعم')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              const Text('اسم المطعم'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _nameCtrl,
                decoration: const InputDecoration(border: OutlineInputBorder(), hintText: 'مطعم ...'),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'أدخل اسم المطعم' : null,
              ),
              const SizedBox(height: 12),
              const Text('رقم الهاتف'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _phoneCtrl,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(border: OutlineInputBorder(), hintText: '07xxxxxxxx'),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'أدخل رقم الهاتف' : null,
              ),
              const SizedBox(height: 12),
              const Text('وصف مختصر (اختياري)'),
              const SizedBox(height: 8),
              TextField(
                controller: _descCtrl,
                maxLines: 3,
                decoration: const InputDecoration(border: OutlineInputBorder(), hintText: 'نوع المأكولات/ملاحظات...'),
              ),
              const SizedBox(height: 12),
              const Text('شعار المطعم (اختياري)'),
              const SizedBox(height: 8),
              Row(
                children: [
                  ElevatedButton.icon(
                    onPressed: _uploading ? null : _pickAndUploadLogo,
                    icon: _uploading
                        ? const SizedBox(height: 16, width: 16, child: CircularProgressIndicator(strokeWidth: 2))
                        : const Icon(Icons.upload),
                    label: const Text('اختيار ورفع شعار'),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _logoUrl ?? 'لم يتم الرفع بعد',
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              if (_pickedPath != null) ...[
                const SizedBox(height: 8),
                SizedBox(height: 120, child: Image.file(File(_pickedPath!), fit: BoxFit.cover)),
              ],
              const SizedBox(height: 16),
              if (_error != null) ...[
                Text(_error!, style: const TextStyle(color: Colors.red)),
                const SizedBox(height: 8),
              ],
              FilledButton(
                onPressed: _loading ? null : _submit,
                child: _loading
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Text('تسجيل وإرسال للموافقة'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
