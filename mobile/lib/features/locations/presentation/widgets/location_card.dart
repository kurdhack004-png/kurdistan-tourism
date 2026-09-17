import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../models/tourist_location.dart';
import 'rating_badge.dart';

/// Image-led row card. Deliberately not the "SaaS card kit" (uniform
/// rounded-rect + soft grey shadow on everything) — no shadow at all, no
/// border; separation between cards comes purely from spacing, and the
/// only color is the image itself plus the saffron rating stamp.
class LocationCard extends StatelessWidget {
  const LocationCard({
    super.key,
    required this.location,
    this.rating,
    this.imageUrl,
    this.onTap,
  });

  final TouristLocation location;
  final double? rating;
  final String? imageUrl;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
              child: SizedBox(
                width: 84,
                height: 84,
                child: imageUrl != null
                    ? CachedNetworkImage(imageUrl: imageUrl!, fit: BoxFit.cover)
                    : Container(color: AppColors.clay), // placeholder tone until media loads
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(location.nameCkb,
                      style: Theme.of(context).textTheme.titleMedium,
                      maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 3),
                  Text(
                    location.elevationMeters != null
                        ? '${location.elevationMeters} م'
                        : location.category,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 6),
                  if (rating != null) RatingBadge(rating: rating!),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
