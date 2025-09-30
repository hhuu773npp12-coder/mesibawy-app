import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/api_client.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  int? _balance;
  bool _loading = false;
  String? _error;
  final _codeCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  Future<void> _topup() async {
    final code = _codeCtrl.text.trim();
    if (code.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('أدخل كود التعبئة')));
      return;
    }
    setState(() => _loading = true);
    try {
      final Dio dio = ApiClient.I.dio;
      final res = await dio.post('/wallets/me/topup', data: { 'code': code });
      _codeCtrl.clear();
      await _fetch();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تمت إضافة 10,000 د.ع إلى رصيدك')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e is DioException ? (e.error?.toString() ?? 'فشل التعبئة') : 'فشل التعبئة')));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _fetch() async {
    setState(() { _loading = true; _error = null; });
    try {
      final prefs = await SharedPreferences.getInstance();
      final role = prefs.getString('user_role');
      final Dio dio = ApiClient.I.dio;
      if (role == 'owner') {
        final res = await dio.get('/owner/wallet');
        final m = res.data as Map<String, dynamic>;
        _balance = (m['balance'] as num).toInt();
      } else {
        final res = await dio.get('/users/me');
        final m = res.data as Map<String, dynamic>;
        _balance = (m['walletBalance'] as num?)?.toInt() ?? 0;
      }
      setState(() {});
    } catch (e) {
      setState(() { _error = 'تعذر جلب رصيد المحفظة'; });
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('المحفظة'),
        actions: [IconButton(onPressed: _loading ? null : _fetch, icon: const Icon(Icons.refresh))],
      ),
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : (_error != null
                ? Center(child: Text(_error!, style: const TextStyle(color: Colors.red)))
                : Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                      const Text('الرصيد الحالي', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 8),
                      Text('${_balance ?? 0} د.ع', style: const TextStyle(fontSize: 22)),
                      const SizedBox(height: 24),
                      const Text('تعبئة الرصيد بكارت'),
                      const SizedBox(height: 8),
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final narrow = constraints.maxWidth < 360;
                          final input = Expanded(
                            child: TextField(
                              controller: _codeCtrl,
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                hintText: 'أدخل كود التعبئة (8-32 محارف)'
                              ),
                            ),
                          );
                          final button = FilledButton(onPressed: _topup, child: const Text('تعبئة'));
                          if (narrow) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [input, const SizedBox(height: 8), button],
                            );
                          }
                          return Row(children: [input, const SizedBox(width: 8), button]);
                        },
                      ),
                      const SizedBox(height: 8),
                      const Text('يتم إضافة 10,000 د.ع عند قبول الكود الصحيح. الكود غير قابل للاستخدام أكثر من مرة.'),
                    ],
                  ),
                )),
      ),
    );
  }
}
