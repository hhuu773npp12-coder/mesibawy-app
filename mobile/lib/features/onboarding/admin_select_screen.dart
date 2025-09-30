import 'package:flutter/material.dart';
import '../../core/responsive.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../auth/admin_owner_login_screen.dart';

class AdminSelectScreen extends StatelessWidget {
  const AdminSelectScreen({super.key});

  Future<void> _choose(BuildContext context, String role) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('intended_role', role);
    await prefs.setBool('seen_onboarding', true);
    if (!context.mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => AdminOwnerLoginScreen(role: role)),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final items = <_Item>[
      _Item('الأدمن', Icons.admin_panel_settings, 'admin'),
      _Item('المالك', Icons.workspace_premium, 'owner'),
    ];
    return Scaffold(
      appBar: AppBar(title: const Text('فرز الأدمن')),
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
          onTap: () => _choose(context, items[i].role),
        ),
      ),
    );
  }
}

class _Item {
  final String title;
  final IconData icon;
  final String role;
  _Item(this.title, this.icon, this.role);
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
