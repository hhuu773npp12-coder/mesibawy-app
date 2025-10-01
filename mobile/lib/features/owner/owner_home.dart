import 'package:flutter/material.dart';
import 'owner_api.dart';
import '../common/profile_screen.dart';
import '../common/wallet_screen.dart';
import '../common/notifications_screen.dart';
import 'topup_cards_screen.dart';
import 'restaurant_settlements_screen.dart';
import 'add_energy_offer_screen.dart';

class OwnerHome extends StatefulWidget {
  const OwnerHome({super.key});

  @override
  State<OwnerHome> createState() => _OwnerHomeState();
}

class _OwnerHomeState extends State<OwnerHome> {
  bool _loading = false;
  int _wallet = 100000000; // 100M IQD default display
  final _api = OwnerApi();
  List<dynamic> _energyRequests = [];

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  Future<void> _refresh() async {
    setState(() => _loading = true);
    try {
      try {
        final res = await _api.getWallet();
        final w = (res.data as Map<String, dynamic>)['balance'] as int?;
        if (w != null) _wallet = w;
      } catch (_) {}
      try {
        final r = await _api.listEnergyRequests();
        _energyRequests = (r.data as List);
      } catch (_) {
        _energyRequests = [];
      }
      setState(() {});
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('مسيباوي - واجهة المالك'),
        actions: [
          IconButton(
            tooltip: 'المحفظة',
            icon: const Icon(Icons.account_balance_wallet_outlined),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const WalletScreen()),
            ),
          ),
          IconButton(
            tooltip: 'الملف الشخصي',
            icon: const Icon(Icons.person_outline),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ProfileScreen()),
            ),
          ),
          IconButton(
            tooltip: 'الإشعارات',
            icon: const Icon(Icons.notifications_none),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const NotificationsScreen()),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                child: ListTile(
                  leading: const Icon(Icons.account_balance_wallet_outlined),
                  title: const Text('المحفظة'),
                  subtitle: Text('$_wallet د.ع'),
                  trailing: IconButton(
                    tooltip: 'تحديث',
                    icon: const Icon(Icons.refresh),
                    onPressed: _loading ? null : _refresh,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  FilledButton.icon(
                    onPressed: _loading
                        ? null
                        : () async {
                            await Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const TopupCardsScreen(),
                              ),
                            );
                            if (!mounted) return;
                            _refresh();
                          },
                    icon: const Icon(Icons.credit_card),
                    label: const Text('إنشاء كروت تعبئة'),
                  ),
                  FilledButton.icon(
                    onPressed: _loading
                        ? null
                        : () async {
                            await Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) =>
                                    const RestaurantSettlementsScreen(),
                              ),
                            );
                            if (!mounted) return;
                            _refresh();
                          },
                    icon: const Icon(Icons.restaurant),
                    label: const Text('تسويات المطاعم (10%)'),
                  ),
                  FilledButton.icon(
                    onPressed: _loading
                        ? null
                        : () async {
                            await Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const AddEnergyOfferScreen(),
                              ),
                            );
                            if (!mounted) return;
                            _refresh();
                          },
                    icon: const Icon(Icons.solar_power),
                    label: const Text('إضافة عرض طاقة'),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Text('طلبات عروض الطاقة'),
              const SizedBox(height: 8),
              Expanded(
                child: _loading
                    ? const Center(child: CircularProgressIndicator())
                    : (_energyRequests.isEmpty
                          ? const Center(child: Text('لا توجد طلبات'))
                          : ListView.separated(
                              itemBuilder: (_, i) {
                                final it =
                                    _energyRequests[i] as Map<String, dynamic>;
                                return Card(
                                  child: ListTile(
                                    leading: const Icon(Icons.person_outline),
                                    title: Text(
                                      it['name']?.toString() ?? 'مستخدم',
                                    ),
                                    subtitle: Text(
                                      'الهاتف: ${it['phone'] ?? ''}\nالموقع: ${it['location'] ?? ''}',
                                    ),
                                  ),
                                );
                              },
                              separatorBuilder: (_, __) =>
                                  const Divider(height: 1),
                              itemCount: _energyRequests.length,
                            )),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
