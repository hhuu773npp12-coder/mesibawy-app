import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/responsive.dart';
import '../auth/phone_screen.dart';
// تمت إزالة شاشة فرز أنواع المركبات
import 'craft_select_screen.dart';
import 'admin_select_screen.dart';
import '../registration/restaurant_registration_screen.dart';

class RoleSelectScreen extends StatefulWidget {
  const RoleSelectScreen({super.key});

  @override
  State<RoleSelectScreen> createState() => _RoleSelectScreenState();
}

class _RoleSelectScreenState extends State<RoleSelectScreen> {
  String? _selectedRole;
  bool _saving = false;

  final List<Map<String, String>> _roles = const [
    {'key': 'citizen', 'label': 'مواطن'},
    {'key': 'restaurant_owner', 'label': 'صاحب مطعم'},
  ];

  Future<void> _goCitizen() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('intended_role', 'citizen');
    await prefs.setBool('seen_onboarding', true);
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const PhoneInputScreen()),
      (route) => false,
    );
  }

  Future<void> _goVehicleOwner() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('intended_role', 'vehicle_owner');
    await prefs.setBool('seen_onboarding', true);
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const PhoneInputScreen()),
      (route) => false,
    );
  }

  Future<void> _goRestaurantOwner() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('intended_role', 'restaurant_owner');
    await prefs.setBool('seen_onboarding', true);
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const RestaurantRegistrationScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final items = <_Item>[
      _Item('مواطن', Icons.person, _goCitizen),
      _Item('صاحب مركبة', Icons.directions_car, _goVehicleOwner),
      _Item('صاحب حِرفة', Icons.handyman, () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const CraftSelectScreen()),
        );
      }),
      _Item('الأدمن', Icons.admin_panel_settings, () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const AdminSelectScreen()),
        );
      }),
      _Item('صاحب المطعم', Icons.restaurant, _goRestaurantOwner),
    ];

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: const Text('اختيار الدور')),
        body: GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: Responsive.gridMaxCrossAxisExtent(context),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: Responsive.gridChildAspectRatio(context),
          ),
          itemCount: items.length,
          itemBuilder: (_, i) => _Card(
            title: items[i].title,
            icon: items[i].icon,
            onTap: items[i].onTap,
          ),
        ),
      ),
    );
  }
}

class _Item {
  final String title;
  final IconData icon;
  final VoidCallback onTap;
  _Item(this.title, this.icon, this.onTap);
}

class _Card extends StatelessWidget {
  const _Card({required this.title, required this.icon, required this.onTap});
  final String title;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final iconSize = Responsive.cardIconSize(context);
    final fontSize = Responsive.cardFontSize(context);
    return InkWell(
      onTap: onTap,
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
              Icon(icon, size: iconSize, color: Theme.of(context).colorScheme.primary),
              const SizedBox(height: 8),
              Text(
                title,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
