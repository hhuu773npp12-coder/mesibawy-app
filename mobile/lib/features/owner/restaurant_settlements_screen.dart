import 'package:flutter/material.dart';
import 'owner_api.dart';

class RestaurantSettlementsScreen extends StatefulWidget {
  const RestaurantSettlementsScreen({super.key});

  @override
  State<RestaurantSettlementsScreen> createState() => _RestaurantSettlementsScreenState();
}

class _RestaurantSettlementsScreenState extends State<RestaurantSettlementsScreen> {
  final _api = OwnerApi();
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
      final res = await _api.listRestaurantSettlements();
      setState(() => _items = (res.data as List));
    } catch (_) {
      setState(() => _items = []);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _markPaid(String id) async {
    setState(() => _loading = true);
    try {
      await _api.markSettlementPaid(id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم تأكيد الدفع')));
      await _fetch();
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('فشل الإجراء')));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('تسويات المطاعم (10%)')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.separated(
              padding: const EdgeInsets.all(12),
              itemBuilder: (_, i) {
                final m = _items[i] as Map<String, dynamic>;
                final name = m['restaurantName']?.toString() ?? 'مطعم';
                final total = (m['totalAmount'] ?? 0).toString();
                final tax = (m['taxAmount'] ?? 0).toString();
                final due = (m['dueAmount'] ?? 0).toString();
                final count = (m['ordersCount'] ?? 0).toString();
                final id = m['id']?.toString() ?? '';
                return Card(
                  child: ListTile(
                    title: Text(name),
                    subtitle: Text('عدد الطلبات: $count\nالإجمالي: $total • الضريبة (10%): $tax\nالمطلوب دفعه: $due'),
                    trailing: FilledButton(
                      onPressed: due == '0' ? null : () => _markPaid(id),
                      child: const Text('تم الدفع'),
                    ),
                  ),
                );
              },
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemCount: _items.length,
            ),
    );
  }
}
