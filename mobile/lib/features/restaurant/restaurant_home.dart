import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import '../../core/api_client.dart';
import 'restaurant_api.dart';
import 'restaurant_orders_screen.dart';
import '../common/profile_screen.dart';
import '../common/wallet_screen.dart';
import '../common/notifications_screen.dart';
import '../citizen/energy_offers_screen.dart';

class RestaurantHome extends StatefulWidget {
  const RestaurantHome({super.key});

  @override
  State<RestaurantHome> createState() => _RestaurantHomeState();
}

class _RestaurantHomeState extends State<RestaurantHome> {
  bool _open = true;
  bool _loading = false;
  bool _uploading = false;
  final _api = RestaurantApi();
  List<dynamic> _offers = [];
  List<dynamic> _orders = [];

  int get _approvedCount => _orders.where((o) => (o['stage'] == 'APPROVED' || o['stage'] == 'COMPLETED')).length;
  int get _approvedTotal {
    int sum = 0;
    for (final o in _orders) {
      final stage = o['stage']?.toString();
      if (stage == 'APPROVED' || stage == 'COMPLETED') {
        // assume order has 'itemsTotal' excluding commission and delivery
        final t = (o['itemsTotal'] as num?)?.toInt() ?? 0;
        sum += t;
      }
    }
    return sum;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('مسيباوي - صاحب المطعم'),
        actions: [
          IconButton(
            tooltip: 'عروض الطاقة',
            icon: const Icon(Icons.solar_power),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const EnergyOffersScreen())),
          ),
          IconButton(
            tooltip: 'الملف الشخصي',
            icon: const Icon(Icons.person_outline),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen())),
          ),
          IconButton(
            tooltip: 'المحفظة',
            icon: const Icon(Icons.account_balance_wallet_outlined),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const WalletScreen())),
          ),
          IconButton(
            tooltip: 'الإشعارات',
            icon: const Icon(Icons.notifications_none),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationsScreen())),
          ),
          IconButton(
            tooltip: 'الطلبات',
            icon: const Icon(Icons.receipt_long),
            onPressed: _loading
                ? null
                : () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const RestaurantOrdersScreen())),
          ),
          Row(
            children: [
              const Text('مفتوح'),
              Switch(value: _open, onChanged: (v) => setState(() => _open = v)),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _loading ? null : () => _showAddOfferSheet(),
        icon: const Icon(Icons.add_photo_alternate),
        label: const Text('إضافة عرض'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('عروضي', style: TextStyle(fontWeight: FontWeight.bold)),
                FilledButton.icon(
                  onPressed: _loading ? null : _fetchOffers,
                  icon: const Icon(Icons.refresh),
                  label: const Text('تحديث'),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: Card(
              child: ListTile(
                leading: const Icon(Icons.insights_outlined),
                title: Text('طلبات العروض المقبولة: $_approvedCount'),
                subtitle: Text('إجمالي الأسعار (بدون عمولة/توصيل): $_approvedTotal د.ع'),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text('الطلبات الواردة', style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          SizedBox(
            height: 180,
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : ListView.separated(
                    padding: const EdgeInsets.all(12),
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (_, i) {
                      final it = _orders[i] as Map<String, dynamic>;
                      return SizedBox(
                        width: 280,
                        child: Card(
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Text(it['customerName']?.toString() ?? 'مواطن'),
                                const SizedBox(height: 4),
                                Text('السعر: ${(it['itemsTotal'] as num?)?.toInt() ?? 0} د.ع'),
                                const Spacer(),
                                Row(
                                  children: [
                                    Expanded(
                                      child: OutlinedButton(
                                        onPressed: () => _updateOrder(it['id'].toString(), 'REJECTED_BY_RESTAURANT'),
                                        child: const Text('رفض'),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: FilledButton(
                                        onPressed: () => _updateOrder(it['id'].toString(), 'APPROVED'),
                                        child: const Text('موافقة'),
                                      ),
                                    ),
                                  ],
                                )
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                    separatorBuilder: (_, __) => const SizedBox(width: 12),
                    itemCount: _orders.length,
                  ),
          ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : ListView.separated(
                    itemBuilder: (_, i) {
                      final it = _offers[i] as Map<String, dynamic>;
                      final img = it['imageUrl']?.toString();
                      final base = ApiClient.I.dio.options.baseUrl;
                      return ListTile(
                        leading: (img != null && img.isNotEmpty)
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(6),
                                child: Image.network(
                                  img.startsWith('http') ? img : '$base$img',
                                  width: 56,
                                  height: 56,
                                  fit: BoxFit.cover,
                                ),
                              )
                            : const Icon(Icons.image_not_supported),
                        title: Text(it['name']?.toString() ?? ''),
                        subtitle: Text('${it['price']} د.ع'),
                      );
                    },
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemCount: _offers.length,
                  ),
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _fetchOffers();
    _fetchOrders();
  }

  Future<void> _fetchOffers() async {
    setState(() => _loading = true);
    try {
      final res = await _api.listOffers();
      setState(() => _offers = (res.data as List));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _fetchOrders() async {
    setState(() => _loading = true);
    try {
      final res = await _api.listOrders();
      setState(() => _orders = (res.data as List));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _updateOrder(String id, String stage) async {
    setState(() => _loading = true);
    try {
      await _api.updateOrderStage(id: id, stage: stage);
      await _fetchOrders();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(stage == 'APPROVED' ? 'تمت الموافقة على الطلب' : 'تم رفض الطلب')),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _showAddOfferSheet() async {
    final formKey = GlobalKey<FormState>();
    final nameCtrl = TextEditingController();
    final priceCtrl = TextEditingController();
    String? pickedPath;
    String? imageUrl;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
          child: StatefulBuilder(
            builder: (ctx, setSt) {
              Future<void> pickUpload() async {
                final picker = ImagePicker();
                final picked = await picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
                if (picked == null) return;
                setSt(() => pickedPath = picked.path);
                setSt(() => _uploading = true);
                try {
                  final form = FormData.fromMap({
                    'file': await MultipartFile.fromFile(picked.path, filename: p.basename(picked.path)),
                  });
                  final res = await ApiClient.I.dio.post('/files/upload', data: form);
                  final data = res.data as Map<String, dynamic>;
                  imageUrl = data['url']?.toString();
                } finally {
                  setSt(() => _uploading = false);
                }
              }

              Future<void> submit() async {
                if (!formKey.currentState!.validate()) return;
                if (imageUrl == null || imageUrl!.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('ارفع صورة للعرض')));
                  return;
                }
                Navigator.of(ctx).pop();
                setState(() => _loading = true);
                try {
                  await _api.createOffer(
                    name: nameCtrl.text.trim(),
                    price: int.tryParse(priceCtrl.text.trim()) ?? 0,
                    imageUrl: imageUrl!,
                  );
                  await _fetchOffers();
                } finally {
                  if (mounted) setState(() => _loading = false);
                }
              }

              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: formKey,
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text('إضافة عرض جديد', style: TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: nameCtrl,
                          decoration: const InputDecoration(border: OutlineInputBorder(), labelText: 'اسم العرض'),
                          validator: (v) => (v == null || v.trim().isEmpty) ? 'أدخل اسم العرض' : null,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: priceCtrl,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(border: OutlineInputBorder(), labelText: 'السعر (د.ع)'),
                          validator: (v) => (int.tryParse(v ?? '') == null) ? 'أدخل سعراً صحيحاً' : null,
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            ElevatedButton.icon(
                              onPressed: _uploading ? null : pickUpload,
                              icon: _uploading
                                  ? const SizedBox(height: 16, width: 16, child: CircularProgressIndicator(strokeWidth: 2))
                                  : const Icon(Icons.upload),
                              label: const Text('اختيار ورفع صورة'),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                imageUrl ?? 'لم يتم الرفع بعد',
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        if (pickedPath != null) ...[
                          const SizedBox(height: 8),
                          SizedBox(height: 120, child: Image.file(File(pickedPath!), fit: BoxFit.cover)),
                        ],
                        const SizedBox(height: 16),
                        FilledButton(onPressed: submit, child: const Text('حفظ')),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
