import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:dio/dio.dart';
import '../../core/api_client.dart';
import 'owner_api.dart';
import '../admin/admin_api.dart';

class AddEnergyOfferScreen extends StatefulWidget {
  const AddEnergyOfferScreen({super.key});

  @override
  State<AddEnergyOfferScreen> createState() => _AddEnergyOfferScreenState();
}

class _AddEnergyOfferScreenState extends State<AddEnergyOfferScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _brandCtrl = TextEditingController();
  final _detailsCtrl = TextEditingController();
  // Multiple images support
  final List<String> _imageUrls = [];
  final List<String> _pickedPaths = [];
  bool _loading = false;
  bool _uploading = false;
  final _api = OwnerApi();

  @override
  void dispose() {
    _titleCtrl.dispose();
    _brandCtrl.dispose();
    _detailsCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickAndUpload() async {
    try {
      if (_imageUrls.length >= 5) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('يمكن رفع حتى 5 صور')));
        return;
      }
      final picker = ImagePicker();
      final pickedList = await picker.pickMultiImage(imageQuality: 85);
      if (pickedList.isEmpty) return;
      // Limit to 5 total
      final toProcess = pickedList.take(5 - _imageUrls.length).toList();
      setState(() {
        _pickedPaths.addAll(toProcess.map((e) => e.path));
        _uploading = true;
      });
      for (final picked in toProcess) {
        final form = FormData.fromMap({
          'file': await MultipartFile.fromFile(picked.path, filename: p.basename(picked.path)),
        });
        final res = await ApiClient.I.dio.post('/files/upload', data: form);
        final data = res.data as Map<String, dynamic>;
        final url = data['url']?.toString();
        if (url != null && url.isNotEmpty) {
          _imageUrls.add(url);
        }
      }
      if (mounted) setState(() {});
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('فشل رفع الصورة')));
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  void _removeImage(int index) {
    if (index < 0 || index >= _imageUrls.length) return;
    setState(() {
      _imageUrls.removeAt(index);
      if (index < _pickedPaths.length) {
        _pickedPaths.removeAt(index);
      }
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      await _api.createEnergyOffer(
        title: _titleCtrl.text.trim(),
        brand: _brandCtrl.text.trim(),
        details: _detailsCtrl.text.trim(),
        imageUrls: _imageUrls,
        imageUrl: _imageUrls.isNotEmpty ? _imageUrls.first : null,
      );
      // Notify all non-admin/owner roles
      try {
        final adminApi = AdminApi();
        const roles = [
          'citizen', 'taxi', 'tuk_tuk', 'kia_haml', 'kia_passenger', 'stuta', 'bike',
          'electrician', 'plumber', 'blacksmith', 'ac_tech', 'restaurant_owner',
        ];
        for (final r in roles) {
          await adminApi.notifyByTags(
            tags: [
              { 'key': 'role', 'relation': '=', 'value': r },
            ],
            title: 'عرض طاقة جديد',
            message: _titleCtrl.text.trim(),
            data: { 'kind': 'energy_offer' },
          );
        }
      } catch (_) {}
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم إنشاء عرض الطاقة')));
      Navigator.of(context).pop();
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تعذر إنشاء العرض')));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('إضافة عرض طاقة')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              const Text('الصور (اختياري، حتى 5 صور)'),
              const SizedBox(height: 8),
              Row(
                children: [
                  ElevatedButton.icon(
                    onPressed: _uploading ? null : _pickAndUpload,
                    icon: _uploading
                        ? const SizedBox(height: 16, width: 16, child: CircularProgressIndicator(strokeWidth: 2))
                        : const Icon(Icons.upload),
                    label: const Text('اختيار ورفع صور'),
                  ),
                  const SizedBox(width: 12),
                  Expanded(child: Text(_imageUrls.isEmpty ? 'لم يتم الرفع بعد' : '${_imageUrls.length} صور', overflow: TextOverflow.ellipsis)),
                ],
              ),
              if (_pickedPaths.isNotEmpty) ...[
                const SizedBox(height: 8),
                SizedBox(
                  height: 120,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (_, i) => Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.file(File(_pickedPaths[i]), width: 120, height: 120, fit: BoxFit.cover),
                        ),
                        Positioned(
                          top: 4,
                          right: 4,
                          child: InkWell(
                            onTap: () => _removeImage(i),
                            child: Container(
                              decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(12)),
                              padding: const EdgeInsets.all(4),
                              child: const Icon(Icons.close, color: Colors.white, size: 16),
                            ),
                          ),
                        ),
                      ],
                    ),
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemCount: _pickedPaths.length,
                  ),
                ),
              ],
              const SizedBox(height: 12),
              const Text('العنوان'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _titleCtrl,
                decoration: const InputDecoration(border: OutlineInputBorder(), hintText: 'عنوان العرض'),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'أدخل العنوان' : null,
              ),
              const SizedBox(height: 12),
              const Text('الماركة'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _brandCtrl,
                decoration: const InputDecoration(border: OutlineInputBorder(), hintText: 'اسم الماركة'),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'أدخل الماركة' : null,
              ),
              const SizedBox(height: 12),
              const Text('التفاصيل'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _detailsCtrl,
                maxLines: 6,
                decoration: const InputDecoration(border: OutlineInputBorder(), hintText: 'عدد الألواح والتفاصيل الأخرى...'),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'أدخل التفاصيل' : null,
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: _loading ? null : _submit,
                child: _loading
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Text('إنشاء'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
