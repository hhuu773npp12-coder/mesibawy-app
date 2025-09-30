import 'package:flutter/material.dart';
import '../../core/responsive.dart';
import '../../widgets/responsive_grid.dart';
import '../orders/order_screen.dart';
import '../map/map_screen.dart';
import 'food_offers_screen.dart';
import 'energy_offers_screen.dart';
import '../common/profile_screen.dart';
import '../common/wallet_screen.dart';
import '../common/notifications_screen.dart';
import '../crafts/electrician_request_screen.dart';
import '../crafts/plumber_request_screen.dart';
import '../crafts/blacksmith_request_screen.dart';
import '../crafts/ac_tech_request_screen.dart';
import '../rides/taxi_request_screen.dart';
import '../rides/tuk_tuk_request_screen.dart';
import '../rides/stuta_request_screen.dart';
import '../rides/kia_haml_request_screen.dart';
import '../student_lines/student_line_request_screen.dart';
import '../campaigns/campaigns_screen.dart';

class CitizenHome extends StatelessWidget {
  const CitizenHome({super.key});

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    int cols;
    if (w < 360) {
      cols = 2;
    } else if (w < 600) {
      cols = 3;
    } else {
      cols = 4;
    }
    final services = [
      _Service('طلب تاكسي', Icons.local_taxi, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TaxiRequestScreen()))),
      _Service('طلب تكتك', Icons.pedal_bike, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TukTukRequestScreen()))),
      _Service('طلب ستوتة', Icons.electric_moped, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const StutaRequestScreen()))),
      _Service('طلب كيا حمل', Icons.local_shipping, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const KiaHamlRequestScreen()))),
      _Service('طلب كيا ركاب', Icons.directions_bus, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const OrderScreen(initialCategory: 'kia_passenger')))),
      _Service('طلب كهربائي', Icons.electrical_services, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ElectricianRequestScreen()))),
      _Service('طلب سباك', Icons.plumbing, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PlumberRequestScreen()))),
      _Service('طلب حداد', Icons.build, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BlacksmithRequestScreen()))),
      _Service('طلب فني تبريد', Icons.ac_unit, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AcTechRequestScreen()))),
      _Service('التسجيل في خط الطلاب', Icons.school, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const StudentLineRequestScreen()))),
      _Service('حملات الزيارة', Icons.campaign, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CampaignsScreen()))),
      _Service('طلب طعام', Icons.restaurant, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FoodOffersScreen()))),
    ];
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('مسيباوي - المواطن'),
          actions: [
            IconButton(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen())),
              icon: const Icon(Icons.person_outline),
              tooltip: 'الملف الشخصي',
            ),
            IconButton(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const WalletScreen())),
              icon: const Icon(Icons.account_balance_wallet_outlined),
              tooltip: 'المحفظة',
            ),
            IconButton(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationsScreen())),
              icon: const Icon(Icons.notifications_none),
              tooltip: 'الإشعارات',
            ),
          ],
        ),
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
              child: ListTile(
                leading: const Icon(Icons.solar_power),
                title: const Text('عروض الطاقة الشمسية'),
                subtitle: const Text('استعرض أحدث العروض وقدّم طلبك مباشرةً'),
                trailing: FilledButton(
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const EnergyOffersScreen())),
                  child: const Text('عرض العروض'),
                ),
              ),
            ),
            const SizedBox(height: 12),
            ResponsiveGrid(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: services.length,
              itemBuilder: (_, i) => _ServiceCard(item: services[i]),
            ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Service {
  final String title;
  final IconData icon;
  final VoidCallback onTap;
  _Service(this.title, this.icon, this.onTap);
}

class _ServiceCard extends StatelessWidget {
  const _ServiceCard({required this.item});
  final _Service item;

  @override
  Widget build(BuildContext context) {
    final iconSize = Responsive.cardIconSize(context);
    final fontSize = Responsive.cardFontSize(context);
    return InkWell(
      onTap: item.onTap,
      borderRadius: BorderRadius.circular(12),
      child: Ink(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 4)),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(item.icon, size: iconSize, color: Theme.of(context).colorScheme.primary),
              const SizedBox(height: 8),
              Text(
                item.title,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                softWrap: true,
                style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
