import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';

import '../../providers/geozone_provider.dart';
import '../../providers/location_provider.dart';
import '../../widgets/glass/glass_app_bar.dart';
import '../../widgets/glass/glass_card.dart';

class NewGeozoneScreen extends ConsumerStatefulWidget {
  const NewGeozoneScreen({super.key});

  @override
  ConsumerState<NewGeozoneScreen> createState() => _NewGeozoneScreenState();
}

class _NewGeozoneScreenState extends ConsumerState<NewGeozoneScreen> {
  final _nameCtrl = TextEditingController();
  final _mapController = MapController();
  String _kind = 'home';
  double _radius = 100;
  LatLng? _center;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    final own = ref.read(ownLocationProvider);
    _center = own ?? const LatLng(41.311081, 69.240562); // Tashkent fallback
    _autofillName('home');
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _mapController.dispose();
    super.dispose();
  }

  void _autofillName(String kind) {
    if (_nameCtrl.text.isEmpty) {
      _nameCtrl.text = switch (kind) {
        'home' => 'Uy',
        'study' => 'Maktab',
        'work' => 'Ish',
        _ => '',
      };
    }
  }

  Future<void> _save() async {
    if (_center == null) return;
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Nom kiriting')));
      return;
    }
    setState(() => _busy = true);
    try {
      await ref.read(geozonesProvider.notifier).create(
            name: name,
            kind: _kind,
            lat: _center!.latitude,
            lng: _center!.longitude,
            radiusMeters: _radius,
          );
      if (mounted) context.pop();
    } catch (e) {
      if (mounted) {
        setState(() => _busy = false);
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Xato: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_center == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: GlassAppBar(
        title: const Text('Yangi joy'),
        actions: [
          TextButton(
            onPressed: _busy ? null : _save,
            child: _busy
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Saqlash',
                    style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _center!,
              initialZoom: 16,
              onPositionChanged: (pos, _) {
                if (pos.center != null) {
                  _center = pos.center;
                }
              },
            ),
            children: [
              TileLayer(
                urlTemplate:
                    'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.blink',
              ),
              CircleLayer(
                circles: [
                  CircleMarker(
                    point: _center!,
                    radius: _radius,
                    useRadiusInMeter: true,
                    color: Colors.blue.withValues(alpha: 0.18),
                    borderColor: Colors.blue,
                    borderStrokeWidth: 2,
                  ),
                ],
              ),
            ],
          ),
          // Center pin (visual indicator that the map's center is the geozone center)
          IgnorePointer(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 24),
                child: Icon(Icons.location_pin,
                    size: 48, color: Colors.blue.shade700),
              ),
            ),
          ),

          // Bottom controls
          Positioned(
            left: 12,
            right: 12,
            bottom: 24,
            child: GlassCard(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      _kindChip('home', '🏠 Uy'),
                      const SizedBox(width: 8),
                      _kindChip('study', '📚 Maktab'),
                      const SizedBox(width: 8),
                      _kindChip('work', '💼 Ish'),
                      const SizedBox(width: 8),
                      _kindChip('custom', '📍 Maxsus'),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _nameCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Joy nomi',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Text('Radius:'),
                      Expanded(
                        child: Slider(
                          value: _radius,
                          min: 50,
                          max: 500,
                          divisions: 9,
                          label: '${_radius.round()}m',
                          onChanged: (v) => setState(() => _radius = v),
                        ),
                      ),
                      Text('${_radius.round()}m'),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _kindChip(String value, String label) {
    final selected = _kind == value;
    return Expanded(
      child: ChoiceChip(
        label: Text(label, style: const TextStyle(fontSize: 12)),
        selected: selected,
        onSelected: (s) {
          if (!s) return;
          setState(() {
            _kind = value;
            _autofillName(value);
          });
        },
      ),
    );
  }
}
