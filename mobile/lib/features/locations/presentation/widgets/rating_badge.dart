import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';

class RatingBadge extends StatelessWidget {
  const RatingBadge({super.key, required this.rating});
  final double rating;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(color: AppColors.saffron.withValues(alpha: 0.25), borderRadius: BorderRadius.circular(AppSpacing.xs + 2)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        const Icon(Icons.star_rounded, size: 13, color: AppColors.saffronDeep),
        const SizedBox(width: 3),
        Text(rating.toStringAsFixed(1), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.saffronDeep)),
      ]),
    );
  }
}
