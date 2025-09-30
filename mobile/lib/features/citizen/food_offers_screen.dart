import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import 'package:dio/dio.dart';
import '../../core/api_client.dart';
import 'food_offer_details_screen.dart';
import '../orders/food_cart.dart';
import '../orders/food_cart_screen.dart';

class FoodOffersScreen extends StatefulWidget {
  const FoodOffersScreen({super.key});

  @override
  State<FoodOffersScreen> createState() => _FoodOffersScreenState();
}

class _ShimmerBox extends StatelessWidget {
  const _ShimmerBox({required this.width, required this.height});
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Container(
        width: width,
        height: height,
        color: Colors.white,
      ),
    );
  }
}

class _ShimmerTile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: const _ShimmerBox(width: 64, height: 64),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              _ShimmerBox(width: double.infinity, height: 14),
              SizedBox(height: 8),
              _ShimmerBox(width: 140, height: 12),
            ],
          ),
        ),
        const SizedBox(width: 12),
        const _ShimmerBox(width: 88, height: 36),
      ],
    );
  }
}

class _FoodOffersScreenState extends State<FoodOffersScreen> {
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
      final Dio dio = ApiClient.I.dio;
      final res = await dio.get('/public/restaurant/offers');
      setState(() => _items = (res.data as List));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final base = ApiClient.I.dio.options.baseUrl;
    return Scaffold(
      appBar: AppBar(
        title: const Text('عروض الطعام'),
        actions: [
          IconButton(onPressed: _loading ? null : _fetch, icon: const Icon(Icons.refresh)),
          IconButton(
            icon: const Icon(Icons.shopping_cart_outlined),
            tooltip: 'السلة',
            onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const FoodCartScreen())),
          ),
        ],
      ),
      body: SafeArea(
        child: _loading
            ? ListView.separated(
                padding: const EdgeInsets.all(12),
                itemCount: 6,
                itemBuilder: (_, __) => _ShimmerTile(),
                separatorBuilder: (_, __) => const Divider(height: 1),
              )
            : (_items.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.restaurant, size: 56, color: Colors.grey),
                          const SizedBox(height: 12),
                          const Text('لا توجد عروض طعام متاحة حالياً', style: TextStyle(fontWeight: FontWeight.w600)),
                          const SizedBox(height: 8),
                          OutlinedButton.icon(
                            onPressed: _fetch,
                            icon: const Icon(Icons.refresh),
                            label: const Text('تحديث'),
                          ),
                        ],
                      ),
                    ),
                  )
                : ListView.separated(
                    itemBuilder: (_, i) {
                      final it = _items[i] as Map<String, dynamic>;
                      final img = it['imageUrl']?.toString() ?? '';
                      final restaurant = it['restaurant'] as Map<String, dynamic>?;
                      final restName = it['restaurantName']?.toString() ?? restaurant?['name']?.toString();
                      final isOpen = (it['isOpen'] as bool?) ?? (restaurant?['open'] as bool?) ?? (restaurant?['isOpen'] as bool?);
                      final statusText = isOpen == null ? null : (isOpen ? 'مفتوح' : 'مغلق');
                      final statusColor = (isOpen ?? false) ? Colors.green : Colors.redAccent;
                      return ListTile(
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: (img.isNotEmpty)
                              ? CachedNetworkImage(
                                  imageUrl: img.startsWith('http') ? img : '$base$img',
                                  width: 64,
                                  height: 64,
                                  fit: BoxFit.cover,
                                  placeholder: (context, url) => _ShimmerBox(width: 64, height: 64),
                                  errorWidget: (context, url, error) => const Icon(Icons.broken_image),
                                )
                              : const Icon(Icons.image_not_supported),
                        ),
                        title: Text(it['name']?.toString() ?? ''),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('${it['price']} د.ع'),
                            if (restName != null)
                              Row(
                                children: [
                                  Text(restName),
                                  if (statusText != null) ...[
                                    const SizedBox(width: 6),
                                    Text('•'),
                                    const SizedBox(width: 6),
                                    Text(statusText, style: TextStyle(color: statusColor, fontWeight: FontWeight.w600)),
                                  ],
                                ],
                              ),
                          ],
                        ),
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => FoodOfferDetailsScreen(offer: it)),
                          );
                        },
                        trailing: FilledButton(
                          onPressed: () {
                            FoodCart.I.add(it, qty: 1);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('تمت الإضافة إلى السلة')),
                            );
                          },
                          child: const Text('إضافة للسلة'),
                        ),
                      );
                    },
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemCount: _items.length,
                  )),
      ),
    );
  }
}
