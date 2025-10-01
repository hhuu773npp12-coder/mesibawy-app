import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
    {'key': 'owner', 'label': 'مالك النظام'},
  ];

  Future<void> _continue() async {
    if (_selectedRole == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى اختيار دور للمتابعة')),
      );
      return;
    }
    setState(() => _saving = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('first_run_done', true);
      await prefs.setString('selected_role', _selectedRole!);
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const _OnboardingDoneScreen()),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: const Text('اختيار الدور')),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('اختر الدور المناسب لك للمتابعة:'),
              const SizedBox(height: 12),
              ..._roles.map((r) => RadioListTile<String>(
                    title: Text(r['label']!),
                    value: r['key']!,
                    groupValue: _selectedRole,
                    onChanged: (v) => setState(() => _selectedRole = v),
                  )),
              const Spacer(),
              FilledButton(
                onPressed: _saving ? null : _continue,
                child: _saving
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Text('متابعة'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OnboardingDoneScreen extends StatelessWidget {
  const _OnboardingDoneScreen();

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.check_circle_outline, size: 64, color: Colors.green),
              const SizedBox(height: 12),
              const Text('تم إكمال الإعداد الأولي'),
              const SizedBox(height: 8),
              OutlinedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('رجوع'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
