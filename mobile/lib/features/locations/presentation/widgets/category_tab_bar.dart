import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';

/// Underline tabs instead of rounded pill chips — reads closer to a
/// section index than a filter toolbar, and avoids the identical-chip-row
/// look that shows up on every generic app.
class CategoryTabBar extends StatelessWidget {
  const CategoryTabBar({
    super.key,
    required this.categories,
    required this.selected,
    required this.onSelected,
  });

  final List<String> categories;
  final String selected;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: categories.map((c) {
          final isSelected = c == selected;
          return Padding(
            padding: const EdgeInsets.only(left: AppSpacing.lg),
            child: GestureDetector(
              onTap: () => onSelected(c),
              child: Container(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: isSelected ? AppColors.saffron : Colors.transparent,
                      width: 2,
                    ),
                  ),
                ),
                child: Text(
                  c.tr(),
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                    color: isSelected ? AppColors.charcoal : AppColors.riverstone,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
