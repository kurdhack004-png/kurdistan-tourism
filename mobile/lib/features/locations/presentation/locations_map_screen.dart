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
  ConsumerState<LocationsMapScreen> createState() =>
      _LocationsMapScreenState();
}

class _LocationsMapScreenState
    extends ConsumerState<LocationsMapScreen> {
  static const _mapStyleUrl = String.fromEnvironment(
    'MAP_STYLE_URL',
    defaultValue: 'https://demotiles.maplibre.org/style.json',
  );

  late LatLng _center;

  MapLibreMapController? _mapController;

  List<TouristLocation> _locations = const [];

  bool _styleReady = false;
  bool _locating = false;

  Position? _currentPosition;

  @override
  void initState() {
    super.initState();

    final location = widget.focusLocation;

    _center = location == null
        ? const LatLng(36.1911, 44.0092)
        : LatLng(
            location.latitude,
            location.longitude,
          );

    if (location == null) {
      _resolveCurrentPosition();
    }
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

    if (mounted) {
      setState(() {
        _locating = true;
      });
    }

    final position = await _getCurrentPosition();

    if (!mounted) return;

    setState(() {
      _locating = false;

      if (position != null) {
        _currentPosition = position;
        _center = LatLng(
          position.latitude,
          position.longitude,
        );
      }
    });

    if (position != null && _mapController != null) {
      try {
        await _mapController!.animateCamera(
          CameraUpdate.newLatLngZoom(
            LatLng(
              position.latitude,
              position.longitude,
            ),
            12,
          ),
        );
      } catch (_) {}
    }
  }

  Future<void> _openDirections(
    TouristLocation location,
  ) async {
    final uri = Uri.parse(
      'https://www.google.com/maps/dir/?api=1'
      '&destination=${location.latitude},${location.longitude}',
    );

    if (!await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    )) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('map_open_failed'.tr()),
        ),
      );
    }
  }

  void _onMapCreated(MapLibreMapController controller) {
    _mapController = controller;
  }

  Future<void> _onStyleLoaded() async {
    final controller = _mapController;

    if (controller == null) return;

    if (mounted) {
      setState(() {
        _styleReady = true;
      });
    }

    await _plotMarkers();
  }

  Future<void> _plotMarkers() async {
    final controller = _mapController;

    if (controller == null || !_styleReady) {
      return;
    }

    try {
      await controller.clearSymbols();
    } catch (_) {}

    if (_locations.isEmpty) {
      return;
    }

    final symbols = <SymbolOptions>[];

    final languageCode = context.locale.languageCode;

    for (final location in _locations) {
      symbols.add(
        SymbolOptions(
          geometry: LatLng(
            location.latitude,
            location.longitude,
          ),
          textField: location.localizedName(languageCode),
          textSize: 11,
          textOffset: const Offset(0, 1.6),
          textColor: '#12452F',
          textHaloColor: '#FFFFFF',
          textHaloWidth: 1.2,
        ),
      );
    }

    try {
      await controller.addSymbols(
        symbols,
        _locations
            .map(
              (location) => <String, dynamic>{
                'location_id': location.id,
              },
            )
            .toList(),
      );
    } catch (_) {
      // Keep the map visible even if annotation rendering fails.
      // The list/detail UI remains usable.
      return;
    }

    if (controller.onSymbolTapped.isEmpty) {
      controller.onSymbolTapped.add(
        (symbol) {
          final data = symbol.data;

          if (data == null) return;

          final locationId = data['location_id']?.toString();

          if (locationId == null) return;

          for (final location in _locations) {
            if (location.id == locationId) {
              _openLocation(location);
              return;
            }
          }
        },
      );
    }
  }

  double _distanceKm(TouristLocation location) {
    final position = _currentPosition;

    if (position == null) {
      return 0;
    }

    return Geolocator.distanceBetween(
          position.latitude,
          position.longitude,
          location.latitude,
          location.longitude,
        ) /
        1000;
  }

  void _openLocation(TouristLocation location) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => LocationDetailScreen(
          location: location,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final nearby = ref.watch(
      nearbyLocationsProvider(
        NearbyParams(
          _center.latitude,
          _center.longitude,
        ),
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text('tourism_places'.tr()),
      ),
      body: nearby.when(
        data: (items) {
          _locations = items;

          if (_styleReady) {
            WidgetsBinding.instance.addPostFrameCallback(
              (_) => _plotMarkers(),
            );
          }

          return Stack(
            children: [
              MapLibreMap(
                styleString: _mapStyleUrl,
                initialCameraPosition: CameraPosition(
                  target: _center,
                  zoom:
                      widget.focusLocation == null ? 8.5 : 12,
                ),
                myLocationEnabled: false,
                compassEnabled: true,
                rotateGesturesEnabled: true,
                scrollGesturesEnabled: true,
                zoomGesturesEnabled: true,
                tiltGesturesEnabled: true,
                onMapCreated: _onMapCreated,
                onStyleLoadedCallback: _onStyleLoaded,
              ),

              if (!_styleReady)
                const Positioned(
                  top: 12,
                  left: 12,
                  child: Card(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          ),
                          SizedBox(width: 8),
                          Text('Loading map...'),
                        ],
                      ),
                    ),
                  ),
                ),

              Positioned(
                right: 12,
                top: 12,
                child: Column(
                  children: [
                    FloatingActionButton.small(
                      heroTag: 'my-location',
                      onPressed:
                          _locating ? null : _resolveCurrentPosition,
                      tooltip: 'my_location'.tr(),
                      child: _locating
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                              ),
                            )
                          : const Icon(
                              Icons.my_location_rounded,
                            ),
                    ),
                    const SizedBox(height: 8),
                    if (widget.focusLocation != null)
                      FloatingActionButton.small(
                        heroTag: 'directions',
                        onPressed: () =>
                            _openDirections(
                          widget.focusLocation!,
                        ),
                        tooltip: 'directions'.tr(),
                        child: const Icon(
                          Icons.directions_rounded,
                        ),
                      ),
                  ],
                ),
              ),

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
                            _currentPosition != null &&
                                    items.isNotEmpty
                                ? '${'places_on_map'.tr(
                                    namedArgs: {
                                      'count':
                                          items.length.toString(),
                                    },
                                  )} • ${_distanceKm(items.first).toStringAsFixed(1)} km'
                                : 'places_on_map'.tr(
                                    namedArgs: {
                                      'count':
                                          items.length.toString(),
                                    },
                                  ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (items.isNotEmpty)
                          IconButton(
                            tooltip: 'directions'.tr(),
                            onPressed: () =>
                                _openDirections(items.first),
                            icon: const Icon(
                              Icons.directions_rounded,
                            ),
                          ),
                        IconButton(
                          tooltip: 'details'.tr(),
                          onPressed: items.isEmpty
                              ? null
                              : () => _openLocation(items.first),
                          icon: const Icon(
                            Icons.chevron_left_rounded,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, stack) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              'data_load_failed'.tr(),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}
