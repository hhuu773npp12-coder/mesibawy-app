import 'dart:async';
import 'dart:math' show Point;
import 'package:flutter/material.dart';
import 'package:maplibre_gl/maplibre_gl.dart';

class LocationPickerResult {
  final double lat;
  final double lng;
  final String? note;
  LocationPickerResult(this.lat, this.lng, {this.note});
}

class LocationPickerScreen extends StatefulWidget {
  const LocationPickerScreen({super.key});

  @override
  State<LocationPickerScreen> createState() => _LocationPickerScreenState();
}

class _LocationPickerScreenState extends State<LocationPickerScreen> {
  static const _styleUrl = 'https://demotiles.maplibre.org/style.json';
  static final _center = LatLng(32.4637, 44.4196); // Babylon approx
  MaplibreMapController? _map;
  LatLng? _picked;
  final _noteCtrl = TextEditingController();

  void _onMapCreated(MaplibreMapController c) {
    _map = c;
  }

  Future<void> _onTap(Point<double> p, LatLng ll) async {
    setState(() => _picked = ll);
    try {
      await _map?.clearSymbols();
    } catch (_) {}
    await _map?.addSymbol(SymbolOptions(geometry: ll, iconImage: 'marker-15'));
  }

  void _confirm() {
    if (_picked == null) return;
    Navigator.of(context).pop(LocationPickerResult(_picked!.latitude, _picked!.longitude, note: _noteCtrl.text.trim().isEmpty ? null : _noteCtrl.text.trim()));
  }
  @override
  void dispose() {
    _noteCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('تحديد الموقع على الخريطة')),
      body: Column(
        children: [
          Expanded(
            child: MaplibreMap(
              styleString: _styleUrl,
              initialCameraPosition: CameraPosition(target: _center, zoom: 12),
              onMapCreated: _onMapCreated,
              onMapClick: _onTap,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(_picked == null
                          ? 'انقر على الخريطة لاختيار موقع'
                          : 'الموقع: ${_picked!.latitude.toStringAsFixed(5)}, ${_picked!.longitude.toStringAsFixed(5)}'),
                    ),
                    FilledButton(onPressed: _picked == null ? null : _confirm, child: const Text('تأكيد')),
                  ],
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _noteCtrl,
                  decoration: const InputDecoration(hintText: 'وصف اختياري للموقع', border: OutlineInputBorder()),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
