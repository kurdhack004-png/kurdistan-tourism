import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/mountain_ridge_divider.dart';
import '../../accommodations/presentation/nearby_stays_screen.dart';
import '../../trip/providers/trip_provider.dart';
import '../../../data/local/favorites_provider.dart';
import '../models/tourist_location.dart';
import 'locations_map_screen.dart';

class LocationDetailScreen extends ConsumerStatefulWidget {
  const LocationDetailScreen({super.key, required this.location});
  final TouristLocation location;

  @override
  ConsumerState<LocationDetailScreen> createState() => _LocationDetailScreenState();
}

class _LocationDetailScreenState extends ConsumerState<LocationDetailScreen> {
  Position? _position;
  bool _locating = false;

  TouristLocation get location => widget.location;

  Future<void> _loadDistance() async {
    if (_locating || _position != null) return;
    setState(() => _locating = true);
    try {
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return;
      }
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
      );
      if (mounted) setState(() => _position = position);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('location_unavailable'.tr())),
        );
      }
    } finally {
      if (mounted) setState(() => _locating = false);
    }
  }

  double? get _distanceKm {
    final p = _position;
    if (p == null) return null;
    return Geolocator.distanceBetween(
          p.latitude,
          p.longitude,
          location.latitude,
          location.longitude,
        ) /
        1000;
  }

  Future<void> _openDirections() async {
    final uri = Uri.parse(
      'https://www.google.com/maps/dir/?api=1&destination='
      '\${location.latitude},\${location.longitude}',
    );
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication) && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('map_open_failed'.tr())),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final languageCode = context.locale.languageCode;
    final inTrip = ref.watch(tripProvider).contains(location.id);
    final isFavorite = ref.watch(favoritesProvider).contains(location.id);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 260,
            actions: [
              IconButton(
                tooltip: 'favorites'.tr(),
                onPressed: () => ref.read(favoritesProvider.notifier).toggle(location.id),
                icon: Icon(
                  isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: isFavorite ? Colors.redAccent : null,
                ),
              ),
            ],
            backgroundColor: AppColors.ink,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                color: AppColors.clay,
                child: Center(
                  child: Icon(
                    Icons.landscape_rounded,
                    size: 64,
                    color: AppColors.limestoneWhite.withValues(alpha: 0.5),
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: MountainRidgeDivider(
              color: Theme.of(context).scaffoldBackgroundColor,
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            sliver: SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    location.localizedName(languageCode),
                    style: Theme.of(context).textTheme.displayLarge,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _InfoChip(icon: Icons.category_outlined, label: location.category),
                      if (location.elevationMeters != null)
                        _InfoChip(
                          icon: Icons.terrain_rounded,
                          label: '\${location.elevationMeters} m',
                        ),
                      _InfoChip(
                        icon: Icons.verified_outlined,
                        label: 'verified_place'.tr(),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.place_outlined, size: 20),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  '\${location.latitude.toStringAsFixed(5)}, '
                                  '\${location.longitude.toStringAsFixed(5)}',
                                ),
                              ),
                              IconButton(
                                tooltip: 'directions'.tr(),
                                onPressed: _openDirections,
                                icon: const Icon(Icons.directions_rounded),
                              ),
                            ],
                          ),
                          const Divider(height: 16),
                          Row(
                            children: [
                              const Icon(Icons.near_me_outlined, size: 20),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _distanceKm == null
                                      ? 'distance_not_loaded'.tr()
                                      : '\${_distanceKm!.toStringAsFixed(1)} km • \${'distance_from_me'.tr()}',
                                ),
                              ),
                              if (_distanceKm == null)
                                TextButton(
                                  onPressed: _locating ? null : _loadDistance,
                                  child: _locating
                                      ? const SizedBox(
                                          width: 16,
                                          height: 16,
                                          child: CircularProgressIndicator(strokeWidth: 2),
                                        )
                                      : Text('load_distance'.tr()),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  const Divider(),
                  const SizedBox(height: AppSpacing.md),
                  Text('about'.tr(), style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    location.localizedDescription(languageCode) ?? 'details'.tr(),
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => ref.read(tripProvider.notifier).toggle(location.id),
                          icon: Icon(
                            inTrip
                                ? Icons.playlist_add_check_rounded
                                : Icons.playlist_add_rounded,
                            size: 18,
                          ),
                          label: Text(inTrip ? 'on_trip'.tr() : 'add_to_trip'.tr()),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _openDirections,
                          icon: const Icon(Icons.directions_rounded, size: 18),
                          label: Text('directions'.tr()),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => LocationsMapScreen(focusLocation: location),
                        ),
                      ),
                      icon: const Icon(Icons.map_outlined, size: 18),
                      label: Text('view_on_map'.tr()),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => NearbyStaysScreen(
                            lat: location.latitude,
                            lng: location.longitude,
                          ),
                        ),
                      ),
                      icon: const Icon(Icons.hotel_outlined, size: 18),
                      label: Text('nearby_stays'.tr()),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) => Chip(
        avatar: Icon(icon, size: 17),
        label: Text(label),
      );
}
