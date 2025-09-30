import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../../core/api_client.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  bool _loading = false;
  String? _error;
  List<dynamic> _items = [];

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  Future<void> _fetch() async {
    setState(() { _loading = true; _error = null; });
    try {
      final Dio dio = ApiClient.I.dio;
      final res = await dio.get('/notifications/me');
      setState(() => _items = (res.data as List));
    } catch (e) {
      setState(() => _error = 'تعذر جلب الإشعارات');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _markAllRead() async {
    setState(() => _loading = true);
    try {
      final Dio dio = ApiClient.I.dio;
      await dio.post('/notifications/read-all');
      await _fetch();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم تعيين الكل كمقروء')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تعذر تنفيذ العملية')));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  int get _unreadCount => _items.where((e) => !(e['read'] as bool? ?? false)).length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الإشعارات'),
        actions: [
          IconButton(onPressed: _loading ? null : _fetch, icon: const Icon(Icons.refresh)),
          TextButton(
            onPressed: (_loading || _unreadCount == 0) ? null : _markAllRead,
            child: const Text('تعيين الكل كمقروء'),
          ),
        ],
      ),
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : (_error != null
                ? Center(child: Text(_error!, style: const TextStyle(color: Colors.red)))
                : ListView.separated(
                    padding: const EdgeInsets.all(12),
                    itemBuilder: (_, i) {
                    final it = _items[i] as Map<String, dynamic>;
                    final title = it['title']?.toString() ?? 'بدون عنوان';
                    final body = it['body']?.toString() ?? '';
                    final read = it['read'] as bool? ?? false;
                    return ListTile(
                      leading: Icon(read ? Icons.notifications_none : Icons.notifications_active_outlined,
                          color: read ? Colors.grey : Theme.of(context).colorScheme.primary),
                      title: Text(title, style: TextStyle(fontWeight: read ? FontWeight.normal : FontWeight.bold)),
                      subtitle: body.isNotEmpty ? Text(body) : null,
                      trailing: read ? null : const Text('غير مقروء', style: TextStyle(color: Colors.redAccent)),
                    );
                  },
                  separatorBuilder: (_, __) => const Divider(height: 1),
                    itemCount: _items.length,
                  )),
      ),
    );
  }
}
