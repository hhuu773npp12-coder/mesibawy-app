import 'package:flutter/material.dart';
import 'citizen_api.dart';
import 'energy_request_screen.dart';

class EnergyOffersScreen extends StatefulWidget {
  const EnergyOffersScreen({super.key});

  @override
  State<EnergyOffersScreen> createState() => _EnergyOffersScreenState();
}

class _EnergyOffersScreenState extends State<EnergyOffersScreen> {
  final _api = CitizenApi();
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
      final res = await _api.listEnergyOffers();
      setState(() => _items = (res.data as List));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('عروض الطاقة الشمسية'),
        actions: [IconButton(onPressed: _loading ? null : _fetch, icon: const Icon(Icons.refresh))],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : (_items.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.solar_power, size: 56, color: Colors.grey),
                        const SizedBox(height: 12),
                        const Text('لا توجد عروض طاقة متاحة حالياً', style: TextStyle(fontWeight: FontWeight.w600)),
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
                  padding: const EdgeInsets.all(12),
                  itemCount: _items.length,
                  itemBuilder: (_, i) {
                    final it = _items[i] as Map<String, dynamic>;
                    return Card(
                      child: ListTile(
                        leading: const Icon(Icons.solar_power),
                        title: Text(it['title']?.toString() ?? ''),
                        subtitle: Text('الماركة: ${it['brand'] ?? ''}\n${it['details'] ?? ''}'),
                        isThreeLine: true,
                        trailing: FilledButton(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => EnergyRequestScreen(offer: it),
                              ),
                            );
                          },
                          child: const Text('اطلب الآن'),
                        ),
                      ),
                    );
                  },
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                )),
    );
  }
}
