import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:dio/dio.dart';
import '../../core/api_client.dart';
import '../common/waiting_approval_screen.dart';

class CraftRegistrationScreen extends StatefulWidget {
  const CraftRegistrationScreen({super.key});

  @override
  State<CraftRegistrationScreen> createState() => _CraftRegistrationScreenState();
}

class _CraftRegistrationScreenState extends State<CraftRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _craftType; // electrician | plumber | blacksmith | ac_tech
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  bool _loading = false;
  String? _error;
  bool _uploading = false;
  final List<String> _photoUrls = [];
  final List<String> _pickedPaths = [];

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await ApiClient.I.dio.post('/profile/craft', data: {
        'craftType': _craftType,
        'name': _nameCtrl.text.trim(),
        'phone': _phoneCtrl.text.trim(),
        if (_photoUrls.isNotEmpty) 'photos': _photoUrls,
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

  Future<void> _pickAndUpload() async {
    if (_photoUrls.length >= 3) {
      setState(() => _error = 'يمكن رفع 3 صور كحد أقصى');
      return;
    }
    setState(() => _error = null);
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
      if (picked == null) return;
      _pickedPaths.add(picked.path);
      setState(() {});

      setState(() => _uploading = true);
      final form = FormData.fromMap({
        'file': await MultipartFile.fromFile(picked.path, filename: p.basename(picked.path)),
      });
      final res = await ApiClient.I.dio.post('/files/upload', data: form);
      final data = res.data as Map<String, dynamic>;
      final url = data['url']?.toString();
      if (url != null && url.isNotEmpty) {
        _photoUrls.add(url);
        setState(() {});
      }
    } catch (_) {
      setState(() => _error = 'فشل رفع الصورة');
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('إكمال بيانات الحِرفة')),
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
                  hintText: 'اسم صاحب الحِرفة',
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
              const Text('نوع الحِرفة'),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _craftType,
                items: const [
                  DropdownMenuItem(value: 'electrician', child: Text('كهربائي')),
                  DropdownMenuItem(value: 'plumber', child: Text('سباك')),
                  DropdownMenuItem(value: 'blacksmith', child: Text('حداد')),
                  DropdownMenuItem(value: 'ac_tech', child: Text('فني تبريد')),
                ],
                onChanged: (v) => setState(() => _craftType = v),
                validator: (v) => (v == null || v.isEmpty) ? 'اختر نوع الحِرفة' : null,
              ),
              const SizedBox(height: 12),
              const Text('صور الحِرفة (حتى 3 صور)'),
              const SizedBox(height: 8),
              Row(
                children: [
                  ElevatedButton.icon(
                    onPressed: _uploading ? null : _pickAndUpload,
                    icon: _uploading
                        ? const SizedBox(height: 16, width: 16, child: CircularProgressIndicator(strokeWidth: 2))
                        : const Icon(Icons.upload),
                    label: const Text('إضافة صورة'),
                  ),
                  const SizedBox(width: 12),
                  Text('${_photoUrls.length}/3'),
                ],
              ),
              if (_pickedPaths.isNotEmpty) ...[
                const SizedBox(height: 8),
                SizedBox(
                  height: 100,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (_, i) => ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.file(File(_pickedPaths[i]), width: 100, height: 100, fit: BoxFit.cover),
                    ),
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemCount: _pickedPaths.length,
                  ),
                ),
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
