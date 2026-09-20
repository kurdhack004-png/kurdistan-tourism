import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:maplibre_gl/maplibre_gl.dart';
import 'package:url_launcher/url_launcher.dart';
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
  bool _locating = false;
  Position? _currentPosition;

  @override
  void initState() {
    super.initState();
    final l = widget.focusLocation;
    _center = l == null
        ? const LatLng(36.1911, 44.0092)
        : LatLng(l.latitude, l.longitude);
    if (l == null) _resolveCurrentPosition();
  }

  Future<Position?> _getCurrentPosition() async {
    try {
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return null;
      }
      return await Geolocator.getCurrentPosition();
    } catch (_) {
      return null;
    }
  }

  Future<void> _resolveCurrentPosition() async {
    if (_locating) return;
    setState(() => _locating = true);
    final pos = await _getCurrentPosition();
    if (!mounted) return;
    setState(() {
      _locating = false;
      if (pos != null) {
        _currentPosition = pos;
        _center = LatLng(pos.latitude, pos.longitude);
      }
    });
    if (pos != null && _mapController != null) {
      await _mapController!.animateCamera(
        CameraUpdate.newLatLngZoom(
          LatLng(pos.latitude, pos.longitude),
          12,
        ),
      );
    }
  }

  Future<void> _openDirections(TouristLocation location) async {
    final uri = Uri.parse(
      'https://www.google.com/maps/dir/?api=1&destination='
      '${location.latitude},${location.longitude}',
    );
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('map_open_failed'.tr())),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final nearby = ref.watch(
      nearbyLocationsProvider(
        NearbyParams(_center.latitude, _center.longitude),
      ),
    );

    return Scaffold(
      appBar: AppBar(title: Text('tourism_places'.tr())),
      body: nearby.when(
        data: (items) {
          _locations = items;
          return Stack(
            children: [
              if (!_mapFailed)
                MapLibreMap(
                  styleString: 'https://demotiles.maplibre.org/style.json',
                  initialCameraPosition: CameraPosition(
                    target: _center,
                    zoom: widget.focusLocation == null ? 8.5 : 12,
                  ),
                  myLocationEnabled: true,
                  onMapCreated: (c) => _mapController = c,
                  onStyleLoadedCallback: _plotMarkers,
                  onMapClick: (_, __) {},
                )
              else
                _MapFallback(
                  locations: items,
                  onTap: (l) => _openLocation(l),
                ),
              if (!_mapFailed)
                Positioned(
                  right: 12,
                  top: 12,
                  child: Column(
                    children: [
                      FloatingActionButton.small(
                        heroTag: 'my-location',
                        onPressed: _locating ? null : _resolveCurrentPosition,
                        tooltip: 'my_location'.tr(),
                        child: _locating
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.my_location_rounded),
                      ),
                      const SizedBox(height: 8),
                      if (widget.focusLocation != null)
                        FloatingActionButton.small(
                          heroTag: 'directions',
                          onPressed: () => _openDirections(widget.focusLocation!),
                          tooltip: 'directions'.tr(),
                          child: const Icon(Icons.directions_rounded),
                        ),
                    ],
                  ),
                ),
              if (!_mapFailed)
                Positioned(
                  left: 16,
                  right: 16,
                  bottom: 16,
                  child: Card(
                    margin: EdgeInsets.zero,
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.place_rounded,
                            color: AppColors.saffron,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _currentPosition != null && items.isNotEmpty
                                  ? '${'places_on_map'.tr(namedArgs: {'count': items.length.toString()})} • ${_distanceKm(items.first).toStringAsFixed(1)} km'
                                  : 'places_on_map'.tr(namedArgs: {'count': items.length.toString()}),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (items.isNotEmpty)
                            IconButton(
                              tooltip: 'directions'.tr(),
                              onPressed: () => _openDirections(items.first),
                              icon: const Icon(Icons.directions_rounded),
                            ),
                          IconButton(
                            tooltip: 'details'.tr(),
                            onPressed: items.isEmpty
                                ? null
                                : () => _openLocation(items.first),
                            icon: const Icon(Icons.chevron_left_rounded),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => Center(child: Text('data_load_failed'.tr())),
      ),
    );
  }

  Future<void> _plotMarkers() async {
    final controller = _mapController;
    if (controller == null) return;
    final languageCode = context.locale.languageCode;
    try {
      await controller.clearSymbols();
      for (final location in _locations) {
        await controller.addSymbol(
          SymbolOptions(
            geometry: LatLng(location.latitude, location.longitude),
            textField: location.localizedName(languageCode),
            textSize: 11,
            textOffset: const Offset(0, 1.6),
            textColor: '#12452F',
            textHaloColor: '#FFFFFF',
            textHaloWidth: 1,
          ),
          {'id': location.id},
        );
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

  double _distanceKm(TouristLocation location) {
    final p = _currentPosition;
    if (p == null) return 0;
    return Geolocator.distanceBetween(
          p.latitude,
          p.longitude,
          location.latitude,
          location.longitude,
        ) /
        1000;
  }

  void _openLocation(TouristLocation location) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => LocationDetailScreen(location: location),
      ),
    );
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
          return Card(
            child: ListTile(
              leading: const CircleAvatar(
                child: Icon(Icons.place_outlined),
              ),
              title: Text(l.localizedName(context.locale.languageCode)),
              subtitle: Text(
                '${l.latitude.toStringAsFixed(4)}, '
                '${l.longitude.toStringAsFixed(4)}',
              ),
              trailing: const Icon(Icons.chevron_left_rounded),
              onTap: () => onTap(l),
            ),
          );
        },
      );
}
