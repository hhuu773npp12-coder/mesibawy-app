import 'dart:async';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:maplibre_gl/mapbox_gl.dart';
import '../../core/responsive.dart';
import '../common/profile_screen.dart';
import '../common/wallet_screen.dart';
import '../common/notifications_screen.dart';
import '../citizen/energy_offers_screen.dart';
import '../../core/api_client.dart';
import 'driver_api.dart';

class DriverHomeBaseScreen extends StatefulWidget {
  const DriverHomeBaseScreen({super.key, required this.role, required this.title});
  final String role; // taxi | tuk_tuk | kia_haml | stuta
  final String title;

  @override
  State<DriverHomeBaseScreen> createState() => _DriverHomeBaseScreenState();
}

class _DriverHomeBaseScreenState extends State<DriverHomeBaseScreen> {
  final _api = DriverApi();
  final _dio = ApiClient.I.dio;
  bool _active = true;
  bool _loading = false;
  List<dynamic> _jobs = [];
  Timer? _poll;
  Timer? _routeTicker;
  MaplibreMapController? _map;
  String? _routeJobId; // currently displayed route job id
  String? _driverName;

  @override
  void initState() {
    super.initState();
    _loadMe();
    _fetch();
    _poll = Timer.periodic(const Duration(seconds: 10), (_) => _fetch());
    _routeTicker = Timer.periodic(const Duration(seconds: 5), (_) => _updateRoute());
  }

  Future<void> _loadMe() async {
    try {
      final res = await ApiClient.I.dio.get('/users/me');
      final me = res.data;
      if (me is Map) {
        final name = (me['fullName'] ?? me['name'] ?? me['username'] ?? '').toString();
        if (mounted) setState(() => _driverName = name.isEmpty ? null : name);
      }
    } catch (_) {
      // ignore
    }
  }

  @override
  void dispose() {
    _poll?.cancel();
    _routeTicker?.cancel();
    super.dispose();
  }

  Future<void> _fetch() async {
    if (!_active) return;
    setState(() => _loading = true);
    try {
      final res = await _api.listJobs(role: widget.role);
      setState(() => _jobs = (res.data as List));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _accept(String id) async {
    await _api.accept(id);
    await _fetch();
  }

  Future<void> _reject(String id) async {
    await _api.reject(id);
    await _api.notifyAdminReject(id);
    await _fetch();
  }

  Future<void> _arrived(String id) async {
    await _api.notifyArrived(id);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم إشعار المواطن: لقد وصل السائق إلى نقطة الانطلاق')));
  }

  Future<void> _complete(String id) async {
    await _api.complete(id);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تمت الرحلة (خصم 10%)')));
    await _fetch();
  }

  // Map logic
  void _onMapCreated(MaplibreMapController c) {
    _map = c;
    _updateRoute();
  }

  Future<void> _updateRoute() async {
    if (_map == null) return;
    if (_jobs.isEmpty) return;
    // Prefer the first ACCEPTED job to display route
    final job = (_jobs.cast<Map>()).firstWhere(
      (j) => j['status'] == 'ACCEPTED',
      orElse: () => _jobs.first as Map,
    ) as Map<String, dynamic>;
    final id = job['id']?.toString();
    if (id == null) return;

    if (_routeJobId != id) {
      // clear layers/sources when switching job
      await _clearMapLayers();
      _routeJobId = id;
    }

    final startLat = (job['startLat'] as num).toDouble();
    final startLng = (job['startLng'] as num).toDouble();
    final destLat = (job['destLat'] as num).toDouble();
    final destLng = (job['destLng'] as num).toDouble();

    // Center map (web-safe). Compute center between start and dest and set a reasonable zoom.
    final centerLat = (startLat + destLat) / 2;
    final centerLng = (startLng + destLng) / 2;
    await _map!.animateCamera(
      CameraUpdate.newLatLngZoom(LatLng(centerLat, centerLng), 12),
    );

    // Markers
    try { await _map!.clearSymbols(); } catch (_) {}
    await _map!.addSymbol(SymbolOptions(geometry: LatLng(startLat, startLng), iconImage: 'marker-15', textField: 'انطلاق'));
    await _map!.addSymbol(SymbolOptions(geometry: LatLng(destLat, destLng), iconImage: 'marker-15', textField: 'وجهة'));

    // Fetch route from OSRM free service
    try {
      final url = 'https://router.project-osrm.org/route/v1/driving/$startLng,$startLat;$destLng,$destLat?overview=full&geometries=geojson';
      final res = await _dio.get(url, options: Options(responseType: ResponseType.json));
      final routes = (res.data['routes'] as List?);
      if (routes != null && routes.isNotEmpty) {
        final coords = (routes.first['geometry']['coordinates'] as List).cast<List>().map<List<double>>((e) => [
              (e[0] as num).toDouble(),
              (e[1] as num).toDouble(),
            ]).toList();
        await _drawRouteLine(coords);
      }
    } catch (_) {
      // ignore network errors for route drawing
    }
  }

  Future<void> _clearMapLayers() async {
    if (_map == null) return;
    try { await _map!.removeLayer('route-line'); } catch (_) {}
    try { await _map!.removeSource('route-src'); } catch (_) {}
  }

  Future<void> _drawRouteLine(List<List<double>> coords) async {
    if (_map == null) return;
    // Add source
    try { await _map!.removeLayer('route-line'); } catch (_) {}
    try { await _map!.removeSource('route-src'); } catch (_) {}

    await _map!.addSource('route-src', GeojsonSourceProperties(
      data: jsonEncode({
        'type': 'FeatureCollection',
        'features': [
          {
            'type': 'Feature',
            'geometry': {
              'type': 'LineString',
              'coordinates': coords,
            },
          }
        ]
      }),
    ));

    await _map!.addLineLayer('route-src', 'route-line', LineLayerProperties(
      lineColor: '#2E86DE',
      lineWidth: 5,
    ));
  }

  void _openFollowUp(Map<String, dynamic> job) {
    final id = job['id']?.toString() ?? '';
    final startLat = (job['startLat'] as num?)?.toDouble();
    final startLng = (job['startLng'] as num?)?.toDouble();
    final destLat = (job['destLat'] as num?)?.toDouble();
    final destLng = (job['destLng'] as num?)?.toDouble();
    final destLink = (destLat != null && destLng != null)
        ? 'https://www.google.com/maps/dir/?api=1&destination=$destLat,$destLng'
        : null;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('متابعة الرحلة: ${job['citizenName'] ?? ''}', style: const TextStyle(fontWeight: FontWeight.bold)),
            if (widget.role == 'bike') ...[
              const SizedBox(height: 8),
              Builder(builder: (_) {
                final totalPrice = (job['totalPrice'] as num?)?.toInt();
                final deliveryPrice = (job['deliveryPrice'] as num?)?.toInt();
                final commission = (totalPrice != null && deliveryPrice != null)
                    ? (totalPrice - (deliveryPrice * 0.9)).round()
                    : null;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('السعر الكلي: ${totalPrice ?? '-'}'),
                    Text('سعر التوصيل: ${deliveryPrice ?? '-'}'),
                    if (commission != null) Text('نسبة المالك (معادلة): $commission'),
                  ],
                );
              }),
            ] else ...[
              const SizedBox(height: 8),
              Builder(builder: (_) {
                final fare = (job['price'] as num?)?.toInt();
                final ownerCut = fare != null ? (fare * 0.1).round() : null;
                final driverNet = fare != null ? (fare * 0.9).round() : null;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('الأجرة: ${fare ?? '-'}'),
                    if (ownerCut != null) Text('نسبة المالك (10%): $ownerCut'),
                    if (driverNet != null) Text('صافي السائق: $driverNet'),
                  ],
                );
              }),
            ],
            const SizedBox(height: 12),
            // Common actions (arrived at pickup + complete)
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                FilledButton(onPressed: () => _arrived(id), child: const Text('لقد وصل السائق إلى نقطة الانطلاق')),
                FilledButton(onPressed: () => _complete(id), child: const Text('تمت الرحلة')),
              ],
            ),
            const SizedBox(height: 12),
            // Bike-specific quick actions
            if (widget.role == 'bike') ...[
              const Text('إشعارات سريعة (الدراجة)'),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  OutlinedButton(onPressed: () => _api.notifyArrivedRestaurant(id), child: const Text('وصل السائق إلى المطعم')),
                  OutlinedButton(
                    onPressed: () => _api.notifyPickedUp(id, _driverName ?? 'السائق'),
                    child: const Text('تم استلام طلبك'),
                  ),
                  OutlinedButton(onPressed: () => _api.notifyArrivedCitizen(id), child: const Text('تم وصول السائق إلى موقعك')),
                ],
              ),
              const SizedBox(height: 8),
              if (destLink != null)
                Row(
                  children: [
                    Expanded(child: Text('رابط الوجهة: $destLink', maxLines: 2, overflow: TextOverflow.ellipsis)),
                    IconButton(
                      tooltip: 'نسخ الرابط',
                      onPressed: () async {
                        await Clipboard.setData(ClipboardData(text: destLink));
                        if (!mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم نسخ رابط الوجهة')));
                      },
                      icon: const Icon(Icons.copy),
                    ),
                  ],
                ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final mapHeight = Responsive.mapHeight(context);
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: Text('مسيباوي - ${widget.title}'),
          actions: [
            IconButton(
              tooltip: 'عروض الطاقة',
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const EnergyOffersScreen())),
              icon: const Icon(Icons.solar_power),
            ),
            IconButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen())), icon: const Icon(Icons.person_outline), tooltip: 'الملف الشخصي'),
            IconButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const WalletScreen())), icon: const Icon(Icons.account_balance_wallet_outlined), tooltip: 'المحفظة'),
            IconButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationsScreen())), icon: const Icon(Icons.notifications_none), tooltip: 'الإشعارات'),
          ],
        ),
        body: Column(
          children: [
            SwitchListTile(
              title: const Text('نشط لاستقبال الطلبات'),
              value: _active,
              onChanged: (v) {
                setState(() => _active = v);
                if (v) _fetch();
              },
            ),
            SizedBox(
              height: mapHeight,
              child: MaplibreMap(
                styleString: 'https://demotiles.maplibre.org/style.json',
                initialCameraPosition: const CameraPosition(target: LatLng(32.4637, 44.4196), zoom: 12),
                onMapCreated: _onMapCreated,
              ),
            ),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : (_jobs.isEmpty
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(24.0),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.local_taxi, size: 56, color: Colors.grey),
                                const SizedBox(height: 12),
                                const Text('لا توجد طلبات متاحة حالياً', style: TextStyle(fontWeight: FontWeight.w600)),
                                const SizedBox(height: 8),
                                OutlinedButton.icon(
                                  onPressed: _fetch,
                                  icon: const Icon(Icons.refresh),
                                  label: const Text('تحديث'),
                                ),
                              ],
                            ),
                          ),
                        )
                      : ListView.separated(
                          itemCount: _jobs.length,
                          itemBuilder: (_, i) {
                            final j = _jobs[i] as Map<String, dynamic>;
                            final id = j['id']?.toString() ?? '';
                            final status = j['status']?.toString() ?? '';
                        // Build subtitle with bike-specific pricing if applicable
                        String subtitle;
                        if (widget.role == 'bike') {
                          final totalPrice = (j['totalPrice'] as num?)?.toInt();
                          final deliveryPrice = (j['deliveryPrice'] as num?)?.toInt();
                          final commission = (totalPrice != null && deliveryPrice != null)
                              ? (totalPrice - (deliveryPrice * 0.9)).round()
                              : null;
                          final driverNet = (totalPrice != null && commission != null)
                              ? (totalPrice - commission)
                              : null;
                          subtitle = 'الهاتف: ${j['citizenPhone'] ?? ''}'
                              '\nالسعر الكلي: ${totalPrice ?? '-'} • سعر التوصيل: ${deliveryPrice ?? '-'}'
                              '${commission != null ? '\nنسبة المالك (معادلة): ${commission}' : ''}'
                              '${driverNet != null ? '\nصافي السائق: ${driverNet}' : ''}'
                              '\nمن: ${j['startLat']}, ${j['startLng']} → إلى: ${j['destLat']}, ${j['destLng']}';
                        } else {
                          final fare = (j['price'] as num?)?.toInt();
                          final driverNet = fare != null ? (fare * 0.9).round() : null;
                          subtitle = 'الهاتف: ${j['citizenPhone'] ?? ''} • السعر: ${fare ?? '-'}'
                              '${driverNet != null ? '\nصافي السائق (بعد 10%): ${driverNet}' : ''}'
                              '\nمن: ${j['startLat']}, ${j['startLng']} → إلى: ${j['destLat']}, ${j['destLng']}';
                        }
                            return Card(
                          child: ListTile(
                            title: Text(j['citizenName']?.toString() ?? 'مواطن'),
                            subtitle: Text(subtitle),
                            isThreeLine: true,
                            trailing: Wrap(
                              spacing: 6,
                              children: [
                                if (status == 'PENDING') ...[
                                  SizedBox(
                                    width: 44,
                                    height: 44,
                                    child: IconButton(
                                      tooltip: 'قبول',
                                      onPressed: () => _accept(id),
                                      icon: const Icon(Icons.check_circle, color: Colors.green),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 44,
                                    height: 44,
                                    child: IconButton(
                                      tooltip: 'رفض',
                                      onPressed: () => _reject(id),
                                      icon: const Icon(Icons.cancel, color: Colors.red),
                                    ),
                                  ),
                                ] else ...[
                                  Text(status, style: const TextStyle(fontSize: 12)),
                                  TextButton(onPressed: () => _openFollowUp(j), child: const Text('متابعة')),
                                ]
                              ],
                            ),
                            onTap: () { setState(() { _routeJobId = id; }); _updateRoute(); },
                          ),
                            );
                          },
                          separatorBuilder: (_, __) => const SizedBox(height: 8),
                        )),
            ),
          ],
        ),
      ),
    );
  }
}
