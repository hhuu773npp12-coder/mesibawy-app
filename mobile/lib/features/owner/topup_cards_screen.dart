import 'package:flutter/material.dart';
import 'owner_api.dart';

class TopupCardsScreen extends StatefulWidget {
  const TopupCardsScreen({super.key});

  @override
  State<TopupCardsScreen> createState() => _TopupCardsScreenState();
}

class _TopupCardsScreenState extends State<TopupCardsScreen> {
  final _api = OwnerApi();
  final _countCtrl = TextEditingController(text: '10');
  bool _loading = false;
  List<dynamic> _items = [];

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  @override
  void dispose() {
    _countCtrl.dispose();
    super.dispose();
  }

  Future<void> _fetch() async {
    setState(() => _loading = true);
    try {
      final res = await _api.listTopupCards();
      setState(() => _items = (res.data as List));
    } catch (_) {
      setState(() => _items = []);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _generate() async {
    final n = int.tryParse(_countCtrl.text.trim());
    if (n == null || n <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('أدخل عدداً صحيحاً')));
      return;
    }
    setState(() => _loading = true);
    try {
      await _api.generateTopupCards(count: n);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم إنشاء الكروت (يخصم 10,000 د.ع لكل كارت)')),
      );
      await _fetch();
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('فشل إنشاء الكروت')));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('إنشاء كروت التعبئة')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                SizedBox(
                  width: 140,
                  child: TextField(
                    controller: _countCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'عدد الكروت'),
                  ),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: _loading ? null : _generate,
                  child: _loading
                      ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Text('إنشاء الكروت'),
                ),
                const SizedBox(width: 8),
                OutlinedButton(onPressed: _loading ? null : _fetch, child: const Text('تحديث')),
              ],
            ),
            const SizedBox(height: 12),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        columns: const [
                          DataColumn(label: Text('رقم الكارت')),
                          DataColumn(label: Text('رمز التعبئة (10 أرقام)')),
                          DataColumn(label: Text('الحالة')),
                        ],
                        rows: _items.map((e) {
                          final m = e as Map<String, dynamic>;
                          return DataRow(cells: [
                            DataCell(Text(m['cardNumber']?.toString() ?? '')),
                            DataCell(Text(m['rechargeCode']?.toString() ?? '')),
                            DataCell(Text((m['used'] == true) ? 'مستخدم' : 'متاح')),
                          ]);
                        }).toList(),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
