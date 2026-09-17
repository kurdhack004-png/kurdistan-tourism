import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:maplibre_gl/maplibre_gl.dart';
import '../../../core/theme/app_colors.dart';
import '../models/tourist_location.dart';
import '../providers/locations_provider.dart';
import 'location_detail_screen.dart';

class LocationsMapScreen extends ConsumerStatefulWidget {
  const LocationsMapScreen({super.key, this.focusLocation});
  final TouristLocation? focusLocation;

  @override
  ConsumerState<LocationsMapScreen> createState() => _LocationsMapScreenState();
}

class _LocationsMapScreenState extends ConsumerState<LocationsMapScreen> {
  late LatLng _center;
  MapLibreMapController? _mapController;
  List<TouristLocation> _locations = const [];
  bool _mapFailed = false;

  @override
  void initState() {
    super.initState();
    final l = widget.focusLocation;
    _center = l == null ? const LatLng(36.1911, 44.0092) : LatLng(l.latitude, l.longitude);
    if (l == null) _resolveCurrentPosition();
  }

  Future<void> _resolveCurrentPosition() async {
    try {
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) return;
      final pos = await Geolocator.getCurrentPosition();
      if (!mounted) return;
      setState(() => _center = LatLng(pos.latitude, pos.longitude));
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final nearby = ref.watch(nearbyLocationsProvider(NearbyParams(_center.latitude, _center.longitude)));
    return Scaffold(
      appBar: AppBar(title: const Text('شوێنە گەشتیارییەکان')),
      body: nearby.when(
        data: (items) {
          _locations = items;
          return Stack(children: [
            if (!_mapFailed)
              MapLibreMap(
                styleString: 'https://demotiles.maplibre.org/style.json',
                initialCameraPosition: CameraPosition(target: _center, zoom: widget.focusLocation == null ? 8.5 : 12),
                onMapCreated: (c) => _mapController = c,
                onStyleLoadedCallback: _plotMarkers,
                onMapClick: (_, __) {},
              )
            else
              _MapFallback(locations: items, onTap: (l) => _openLocation(l)),
            if (!_mapFailed)
              Positioned(
                left: 16, right: 16, bottom: 16,
                child: Card(
                  margin: EdgeInsets.zero,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(children: [
                      const Icon(Icons.place_rounded, color: AppColors.saffron),
                      const SizedBox(width: 8),
                      Expanded(child: Text('${items.length} شوێنی گەشتیاری لەم ناوچەیەدا', maxLines: 1, overflow: TextOverflow.ellipsis)),
                      IconButton(onPressed: items.isEmpty ? null : () => _openLocation(items.first), icon: const Icon(Icons.chevron_left_rounded)),
                    ]),
                  ),
                ),
              ),
          ]);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => const Center(child: Text('نەتوانرا داتای شوێنەکان بخوێندرێتەوە.')),
      ),
    );
  }

  Future<void> _plotMarkers() async {
    final controller = _mapController;
    if (controller == null) return;
    try {
      await controller.clearSymbols();
      for (final location in _locations) {
        await controller.addSymbol(SymbolOptions(
          geometry: LatLng(location.latitude, location.longitude),
          textField: location.nameCkb,
          textSize: 11,
          textOffset: const Offset(0, 1.6),
          textColor: '#12452F',
          textHaloColor: '#FFFFFF',
          textHaloWidth: 1,
        ), {'id': location.id});
      }
      controller.onSymbolTapped.add((symbol) {
        final id = symbol.data?['id'] as String?;
        for (final location in _locations) {
          if (location.id == id) {
            _openLocation(location);
            break;
          }
        }
      });
    } catch (_) {
      if (mounted) setState(() => _mapFailed = true);
    }
  }

  void _openLocation(TouristLocation location) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => LocationDetailScreen(location: location)));
  }
}

class _MapFallback extends StatelessWidget {
  const _MapFallback({required this.locations, required this.onTap});
  final List<TouristLocation> locations;
  final ValueChanged<TouristLocation> onTap;

  @override
  Widget build(BuildContext context) => ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: locations.length,
        itemBuilder: (_, i) {
          final l = locations[i];
          return Card(child: ListTile(
            leading: const CircleAvatar(child: Icon(Icons.place_outlined)),
            title: Text(l.nameCkb),
            subtitle: Text('${l.latitude.toStringAsFixed(4)}, ${l.longitude.toStringAsFixed(4)}'),
            trailing: const Icon(Icons.chevron_left_rounded),
            onTap: () => onTap(l),
          ));
        },
      );
}
