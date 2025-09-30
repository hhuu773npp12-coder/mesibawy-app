import 'package:flutter/material.dart';
import 'order_api.dart';

class OrderScreen extends StatefulWidget {
  const OrderScreen({super.key, this.initialDistanceKm, this.initialDurationMin, this.initialCategory});

  final double? initialDistanceKm;
  final double? initialDurationMin;
  final String? initialCategory;

  @override
  State<OrderScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  final _api = OrderApi();
  final _userIdCtrl = TextEditingController();
  late final TextEditingController _distanceCtrl;
  late final TextEditingController _durationCtrl;
  late String _category;
  bool _loading = false;
  Map<String, dynamic>? _result;

  @override
  void initState() {
    super.initState();
    _distanceCtrl = TextEditingController(text: (widget.initialDistanceKm ?? 5.0).toStringAsFixed(2));
    _durationCtrl = TextEditingController(text: widget.initialDurationMin != null ? widget.initialDurationMin!.toStringAsFixed(0) : '');
    _category = widget.initialCategory ?? 'taxi';
  }

  @override
  void dispose() {
    _userIdCtrl.dispose();
    _distanceCtrl.dispose();
    _durationCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() {
      _loading = true;
      _result = null;
    });
    try {
      final distance = double.tryParse(_distanceCtrl.text.trim()) ?? 0;
      final duration = _durationCtrl.text.trim().isEmpty ? null : double.tryParse(_durationCtrl.text.trim());
      final res = await _api.estimateAndCreate(
        userId: _userIdCtrl.text.trim().isEmpty ? null : _userIdCtrl.text.trim(),
        category: _category,
        distanceKm: distance,
        durationMin: duration,
      );
      setState(() => _result = (res.data as Map<String, dynamic>));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('فشل إنشاء الطلب')));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: const Text('طلب رحلة تجريبي')),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            DropdownButtonFormField<String>(
              value: _category,
              decoration: const InputDecoration(labelText: 'الفئة'),
              items: const [
                DropdownMenuItem(value: 'taxi', child: Text('تاكسي')),
                DropdownMenuItem(value: 'tuk_tuk', child: Text('ستوتة')),
                DropdownMenuItem(value: 'kia_passenger', child: Text('كيا ركاب')),
                DropdownMenuItem(value: 'kia_haml', child: Text('كيا حمل')),
                DropdownMenuItem(value: 'stuta', child: Text('ستوتة (Alias)')),
                DropdownMenuItem(value: 'bike', child: Text('دراجة')),
              ],
              onChanged: (v) => setState(() => _category = v ?? 'taxi'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _distanceCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'المسافة (كم)'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _durationCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'المدة (دقائق) - اختياري'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _userIdCtrl,
              decoration: const InputDecoration(labelText: 'userId (اختياري)'),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: _loading ? null : _submit,
              child: _loading ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('احسب وأنشئ'),
            ),
            const SizedBox(height: 16),
            if (_result != null)
              _ResultCard(data: _result!),
          ],
        ),
      ),
    );
  }
}

class _ResultCard extends StatelessWidget {
  const _ResultCard({required this.data});
  final Map<String, dynamic> data;

  @override
  Widget build(BuildContext context) {
    final order = (data['order'] ?? {}) as Map<String, dynamic>;
    final est = (data['estimate'] ?? {}) as Map<String, dynamic>;
    final breakdown = (est['breakdown'] ?? {}) as Map<String, dynamic>;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('نتيجة إنشاء الطلب', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ListTile(
              dense: true,
              title: const Text('رقم الطلب'),
              subtitle: Text(order['id']?.toString() ?? '-'),
            ),
            ListTile(
              dense: true,
              title: const Text('الفئة والمسافة'),
              subtitle: Text('${order['category']} • ${order['distanceKm']} كم'),
            ),
            ListTile(
              dense: true,
              title: const Text('السعر الكلي'),
              subtitle: Text('${order['priceTotal']} ${order['currency'] ?? 'IQD'}'),
            ),
            const Divider(),
            const Text('التسعير التفصيلي', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 4),
            Wrap(
              spacing: 12,
              runSpacing: 8,
              children: [
                _ChipPair(label: 'أساسي', value: breakdown['base']?.toString() ?? '-'),
                _ChipPair(label: 'لكل كم', value: breakdown['perKm']?.toString() ?? '-'),
                _ChipPair(label: 'تكلفة المسافة', value: breakdown['distanceCost']?.toString() ?? '-'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ChipPair extends StatelessWidget {
  const _ChipPair({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Chip(label: Text('$label: $value'));
  }
}
