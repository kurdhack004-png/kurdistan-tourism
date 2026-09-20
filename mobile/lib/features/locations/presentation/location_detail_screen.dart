import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/mountain_ridge_divider.dart';
import '../../accommodations/presentation/nearby_stays_screen.dart';
import '../../reviews/presentation/reviews_screen.dart';
import '../../trip/providers/trip_provider.dart';
import '../../../data/local/favorites_provider.dart';
import '../models/tourist_location.dart';
import 'widgets/rating_badge.dart';
import 'locations_map_screen.dart';

class LocationDetailScreen extends ConsumerWidget {
  const LocationDetailScreen({super.key, required this.location});

  final TouristLocation location;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
                tooltip: 'دڵخواز',
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          location.localizedName(languageCode),
                          style: Theme.of(context).textTheme.displayLarge,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => ReviewsScreen(
                              reviewableType: 'location',
                              reviewableId: location.id,
                              title: location.nameCkb,
                            ),
                          ),
                        ),
                        child: const RatingBadge(rating: 4.8),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Row(
                    children: [
                      const Icon(
                        Icons.terrain_rounded,
                        size: 15,
                        color: AppColors.riverstone,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        location.elevationMeters != null
                            ? '${location.elevationMeters} م بەرزی'
                            : location.category,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  const Divider(),
                  const SizedBox(height: AppSpacing.md),
                  Text('دەربارە', style: Theme.of(context).textTheme.titleMedium),
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
                          label: Text(
                            inTrip
                                ? 'لە پلانی گەشتدایە'
                                : 'زیادکردن بۆ پلانی گەشتم',
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => LocationsMapScreen(
                                focusLocation: location,
                              ),
                            ),
                          ),
                          icon: const Icon(Icons.map_outlined, size: 18),
                          label: const Text('لەسەر نەخشە'),
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
                          builder: (_) => NearbyStaysScreen(
                            lat: location.latitude,
                            lng: location.longitude,
                          ),
                        ),
                      ),
                      icon: const Icon(Icons.hotel_outlined, size: 18),
                      label: const Text('بینینی شوێنی مانەوەی نزیک'),
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
