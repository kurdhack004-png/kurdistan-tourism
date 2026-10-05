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
  @override ConsumerState<LocationsMapScreen> createState() => _LocationsMapScreenState();
}

class _LocationsMapScreenState extends ConsumerState<LocationsMapScreen> {
  static const _mapStyleUrl = String.fromEnvironment('MAP_STYLE_URL', defaultValue: 'https://demotiles.maplibre.org/style.json');
  late LatLng _center;
  MapLibreMapController? _mapController;
  List<TouristLocation> _locations = const [];
  bool _styleReady = false;
  bool _locating = false;

  @override
  void initState() {
    super.initState();
    final location = widget.focusLocation;
    _center = location == null ? const LatLng(36.1911, 44.0092) : LatLng(location.latitude, location.longitude);
    if (location == null) _resolveCurrentPosition();
  }

  Future<Position?> _getCurrentPosition() async {
    try {
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) return null;
      return await Geolocator.getCurrentPosition();
    } catch (_) { return null; }
  }

  Future<void> _resolveCurrentPosition() async {
    if (_locating) return;
    if (mounted) setState(() => _locating = true);
    final position = await _getCurrentPosition();
    if (!mounted) return;
    setState(() {
      _locating = false;
      if (position != null) _center = LatLng(position.latitude, position.longitude);
    });
    if (position != null && _mapController != null) {
      try { await _mapController!.animateCamera(CameraUpdate.newLatLngZoom(LatLng(position.latitude, position.longitude), 12)); } catch (_) {}
    }
  }

  Future<void> _openGoogleMaps(TouristLocation location) async {
    await _launchExternal(Uri.parse('https://www.google.com/maps/dir/?api=1&destination=${location.latitude},${location.longitude}'));
  }

  Future<void> _openWaze(TouristLocation location) async {
    await _launchExternal(Uri.parse('https://www.waze.com/ul?ll=${location.latitude}%2C${location.longitude}&navigate=yes'));
  }

  Future<void> _launchExternal(Uri uri) async {
    final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!opened && mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('map_open_failed'.tr())));
  }

  void _onMapCreated(MapLibreMapController controller) => _mapController = controller;

  Future<void> _onStyleLoaded() async {
    if (_mapController == null) return;
    if (mounted) setState(() => _styleReady = true);
    await _plotMarkers();
  }

  Future<void> _plotMarkers() async {
    final controller = _mapController;
    if (controller == null || !_styleReady || _locations.isEmpty) return;
    final languageCode = context.locale.languageCode;
    try { await controller.clearSymbols(); } catch (_) {}
    try {
      await controller.addSymbols(
        _locations.map((location) => SymbolOptions(
          geometry: LatLng(location.latitude, location.longitude),
          textField: location.localizedName(languageCode), textSize: 11,
          textOffset: const Offset(0, 1.6), textColor: '#12452F',
          textHaloColor: '#FFFFFF', textHaloWidth: 1.2,
        )).toList(),
        _locations.map((location) => <String, dynamic>{'location_id': location.id}).toList(),
      );
    } catch (_) { return; }
    if (!mounted || controller.onSymbolTapped.isNotEmpty) return;
    controller.onSymbolTapped.add((symbol) {
      final id = symbol.data?['location_id']?.toString();
      if (id == null) return;
      for (final location in _locations) {
        if (location.id == id) { _openLocation(location); break; }
      }
    });
  }

  void _openLocation(TouristLocation location) => Navigator.of(context).push(MaterialPageRoute(builder: (_) => LocationDetailScreen(location: location)));

  @override
  Widget build(BuildContext context) {
    final nearby = ref.watch(nearbyLocationsProvider(NearbyParams(_center.latitude, _center.longitude)));
    return Scaffold(
      appBar: AppBar(title: Text('tourism_places'.tr())),
      body: nearby.when(
        data: (items) {
          _locations = items;
          if (_styleReady) WidgetsBinding.instance.addPostFrameCallback((_) => _plotMarkers());
          return Stack(children: [
            MapLibreMap(
              styleString: _mapStyleUrl,
              initialCameraPosition: CameraPosition(target: _center, zoom: widget.focusLocation == null ? 8.5 : 12),
              myLocationEnabled: false, compassEnabled: true, rotateGesturesEnabled: true,
              scrollGesturesEnabled: true, zoomGesturesEnabled: true, tiltGesturesEnabled: true,
              onMapCreated: _onMapCreated, onStyleLoadedCallback: _onStyleLoaded,
            ),
            if (!_styleReady) const Positioned(top: 12, left: 12, child: Card(child: Padding(padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8), child: Row(mainAxisSize: MainAxisSize.min, children: [SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)), SizedBox(width: 8), Text('Loading map...')])))),
            Positioned(right: 12, top: 12, child: Column(children: [
              FloatingActionButton.small(heroTag: 'my-location', onPressed: _locating ? null : _resolveCurrentPosition, tooltip: 'my_location'.tr(), child: _locating ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.my_location_rounded)),
              const SizedBox(height: 8),
              if (widget.focusLocation != null) ...[
                FloatingActionButton.small(heroTag: 'google-map', onPressed: () => _openGoogleMaps(widget.focusLocation!), tooltip: 'directions'.tr(), child: const Icon(Icons.map_rounded)),
                const SizedBox(height: 8),
                FloatingActionButton.small(heroTag: 'waze', onPressed: () => _openWaze(widget.focusLocation!), tooltip: 'directions'.tr(), child: const Icon(Icons.navigation_rounded)),
              ],
            ])),
            Positioned(left: 12, right: 12, bottom: 12, child: Card(margin: EdgeInsets.zero, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)), child: Padding(padding: const EdgeInsets.all(12), child: Row(children: [
              Container(width: 38, height: 38, decoration: BoxDecoration(color: AppColors.saffron.withValues(alpha: .12), borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.place_rounded, color: AppColors.saffron)),
              const SizedBox(width: 9), Expanded(child: Text('places_on_map'.tr(namedArgs: {'count': items.length.toString()}), maxLines: 1, overflow: TextOverflow.ellipsis)),
              if (items.isNotEmpty) PopupMenuButton<String>(tooltip: 'directions'.tr(), onSelected: (value) => value == 'waze' ? _openWaze(items.first) : _openGoogleMaps(items.first), itemBuilder: (_) => [
                PopupMenuItem(value: 'google', child: Text('Google Maps')), PopupMenuItem(value: 'waze', child: Text('Waze')),
              ], child: const Icon(Icons.directions_rounded)),
            ]))))),
          ]);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => Center(child: Padding(padding: const EdgeInsets.all(24), child: Text('data_load_failed'.tr(), textAlign: TextAlign.center))),
      ),
    );
  }
}
