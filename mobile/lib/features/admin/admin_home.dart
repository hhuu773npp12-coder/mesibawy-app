import 'package:flutter/material.dart';
import 'approvals_tab.dart';
import 'users_tab.dart';
import 'codes_tab.dart';
import 'campaigns_tab.dart';
import 'student_lines_tab.dart';
import 'orders_tab.dart';
import 'notifications_tab.dart';
import '../common/profile_screen.dart';
import '../common/wallet_screen.dart';
import '../common/notifications_screen.dart';

class AdminHome extends StatefulWidget {
  const AdminHome({super.key});

  @override
  State<AdminHome> createState() => _AdminHomeState();
}

class _AdminHomeState extends State<AdminHome> with SingleTickerProviderStateMixin {
  late final TabController _tab;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 7, vsync: this);
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('مسيباوي - لوحة الأدمن'),
          actions: [
            IconButton(
              tooltip: 'الملف الشخصي',
              icon: const Icon(Icons.person_outline),
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen()));
              },
            ),
            IconButton(
              tooltip: 'المحفظة',
              icon: const Icon(Icons.account_balance_wallet_outlined),
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const WalletScreen()));
              },
            ),
            IconButton(
              tooltip: 'الإشعارات',
              icon: const Icon(Icons.notifications_none),
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationsScreen()));
              },
            ),
          ],
          bottom: TabBar(
            controller: _tab,
            isScrollable: true,
            tabs: const [
              Tab(text: 'الموافقات'),
              Tab(text: 'المستخدمون'),
              Tab(text: 'الأكواد'),
              Tab(text: 'الحملات'),
              Tab(text: 'خطوط الطلاب'),
              Tab(text: 'الطلبات'),
              Tab(text: 'الإشعارات'),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tab,
          children: const [
            ApprovalsTab(),
            UsersTab(),
            CodesTab(),
            CampaignsTab(),
            StudentLinesTab(),
            OrdersTab(),
            NotificationsTab(),
          ],
        ),
        bottomNavigationBar: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _tab.animateTo(3),
                    icon: const Icon(Icons.campaign_outlined),
                    label: const Text('إنشاء حملات'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _tab.animateTo(4),
                    icon: const Icon(Icons.route_outlined),
                    label: const Text('ضبط خطوط النقل'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
