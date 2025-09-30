import 'dart:convert';
import 'dart:math' show Point;

import 'package:flutter/material.dart';
import 'package:maplibre_gl/maplibre_gl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'ors_client.dart';
import '../orders/order_screen.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  static const _styleUrl = 'https://demotiles.maplibre.org/style.json';
  final _orsKeyCtrl = TextEditingController();
  late final OrsClient _ors;
  MaplibreMapController? _map;

  List<double>? _start; // [lng, lat]
  List<double>? _end; // [lng, lat]
  bool _routing = false;
  double? _lastDistanceKm;
  double? _lastDurationMin;

  @override
  void initState() {
    super.initState();
    _ors = OrsClient('');
    _loadSavedKey();
  }

  @override
  void dispose() {
    _orsKeyCtrl.dispose();
    super.dispose();
  }

  void _onMapCreated(MaplibreMapController controller) {
    _map = controller;
  }

  Future<void> _loadSavedKey() async {
    final prefs = await SharedPreferences.getInstance();
    final k = prefs.getString('ors_api_key');
    if (k != null && k.isNotEmpty) {
      setState(() {
        _orsKeyCtrl.text = k;
      });
    }
  }

  Future<void> _saveKey() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('ors_api_key', _orsKeyCtrl.text.trim());
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم حفظ مفتاح ORS')));
  }

  Future<void> _onLongPress(Point<double> pnt, LatLng latLng) async {
    final lngLat = [latLng.longitude, latLng.latitude];
    if (_start == null) {
      setState(() => _start = lngLat);
      await _addMarker('start', latLng, Colors.green);
    } else if (_end == null) {
      setState(() => _end = lngLat);
      await _addMarker('end', latLng, Colors.red);
      await _route();
    } else {
      // reset and set new start
      await _clearRoute();
      setState(() => _start = lngLat);
      await _addMarker('start', latLng, Colors.green);
    }
  }

  Future<void> _addMarker(String id, LatLng latLng, Color color) async {
    if (_map == null) return;
    await _map!.addSymbol(SymbolOptions(
      geometry: latLng,
      iconImage: 'marker-15',
      iconColor: colorToRgbaString(color),
    ));
  }

  Future<void> _clearRoute() async {
    if (_map == null) return;
    setState(() {
      _start = null;
      _end = null;
      _routing = false;
    });
    try {
      await _map!.removeLayer('route-layer');
    } catch (_) {}
    try {
      await _map!.removeSource('route-source');
    } catch (_) {}
    try {
      await _map!.clearSymbols();
    } catch (_) {}
  }

  Future<void> _route() async {
    if (_start == null || _end == null || _map == null) return;
    final key = _orsKeyCtrl.text.trim();
    if (key.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('أدخل مفتاح ORS أولاً')));
      return;
    }
    setState(() => _routing = true);
    try {
      final client = OrsClient(key);
      final geo = await client.route(_start!, _end!);
      final feature = geo['features'][0] as Map<String, dynamic>;
      final geometry = feature['geometry'] as Map<String, dynamic>;
      final props = feature['properties'] as Map<String, dynamic>?;
      final summary = props != null ? props['summary'] as Map<String, dynamic>? : null;
      if (summary != null) {
        final distMeters = (summary['distance'] as num?) ?? 0;
        final durSeconds = (summary['duration'] as num?) ?? 0;
        _lastDistanceKm = (distMeters / 1000).toDouble();
        _lastDurationMin = (durSeconds / 60).toDouble();
      } else {
        _lastDistanceKm = null;
        _lastDurationMin = null;
      }

      // add geojson source
      await _map!.addSource('route-source', GeojsonSourceProperties(data: geometry));
      await _map!.addLineLayer(
        'route-source',
        'route-layer',
        const LineLayerProperties(
          lineColor: '#1e88e5',
          lineWidth: 4.0,
          lineOpacity: 0.9,
        ),
      );

      // fit bounds roughly by centering between points
      final sw = LatLng(_start![1], _start![0]);
      final ne = LatLng(_end![1], _end![0]);
      await _map!.animateCamera(CameraUpdate.newLatLngBounds(LatLngBounds(southwest: sw, northeast: ne), left: 40, right: 40, top: 80, bottom: 40));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('فشل جلب المسار')));
    } finally {
      if (mounted) setState(() => _routing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('الخريطة (MapLibre + ORS)'),
          actions: [
            IconButton(
              onPressed: _routing ? null : _clearRoute,
              icon: const Icon(Icons.refresh),
              tooltip: 'إعادة ضبط',
            ),
          ],
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _orsKeyCtrl,
                      decoration: const InputDecoration(
                        labelText: 'ORS API Key',
                        hintText: 'أدخل مفتاح OpenRouteService',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: _saveKey,
                    icon: const Icon(Icons.save),
                    tooltip: 'حفظ المفتاح',
                  ),
                  const SizedBox(width: 4),
                  ElevatedButton(
                    onPressed: (_start != null && _end != null && !_routing) ? _route : null,
                    child: _routing ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('مسار'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: (_lastDistanceKm != null && !_routing)
                        ? () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => OrderScreen(
                                  initialDistanceKm: _lastDistanceKm,
                                  initialDurationMin: _lastDurationMin,
                                  initialCategory: 'taxi',
                                ),
                              ),
                            );
                          }
                        : null,
                    child: const Text('إنشاء طلب'),
                  ),
                ],
              ),
            ),
            if (_lastDistanceKm != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: Row(
                  children: [
                    Chip(label: Text('المسافة: ${_lastDistanceKm!.toStringAsFixed(2)} كم')),
                    const SizedBox(width: 8),
                    if (_lastDurationMin != null) Chip(label: Text('المدة: ${_lastDurationMin!.toStringAsFixed(0)} دقيقة')),
                  ],
                ),
              ),
            Expanded(
              child: MaplibreMap(
                styleString: _styleUrl,
                myLocationEnabled: false,
                myLocationTrackingMode: MyLocationTrackingMode.None,
                onMapCreated: _onMapCreated,
                initialCameraPosition: CameraPosition(
                  target: LatLng(32.4637, 44.4196), // Babylon, Iraq approx
                  zoom: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
