import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Maps a location's category to an icon + tint so placeholders (cards,
/// the hero carousel, failed network images) all read as "this is a
/// mountain / lake / cave / waterfall / historical site" consistently
/// across the app, instead of each screen inventing its own mapping.
(IconData, Color) categoryVisual(String category) {
  switch (category) {
    case 'mountain':
      return (Icons.terrain_rounded, AppColors.clay);
    case 'lake':
      return (Icons.water_rounded, const Color(0xFF3D6E8C));
    case 'cave':
      return (Icons.landscape_rounded, AppColors.riverstone);
    case 'waterfall':
      return (Icons.water_drop_rounded, const Color(0xFF2E7D6B));
    case 'history':
      return (Icons.account_balance_rounded, AppColors.saffronDeep);
    default:
      return (Icons.place_rounded, AppColors.clay);
  }
}
