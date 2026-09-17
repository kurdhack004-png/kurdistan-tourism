import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_typography.dart';
import 'app_spacing.dart';

class AppTheme {
  static ThemeData get light => ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        scaffoldBackgroundColor: AppColors.limestone,
        colorScheme: const ColorScheme.light(
          primary: AppColors.ink,
          secondary: AppColors.saffron,
          tertiary: AppColors.clay,
          surface: AppColors.limestoneWhite,
          error: AppColors.danger,
        ),
        textTheme: AppTypography.textTheme,
        appBarTheme: AppBarTheme(
          backgroundColor: AppColors.ink,
          foregroundColor: AppColors.limestoneWhite,
          elevation: 0,
          titleTextStyle: AppTypography.textTheme.titleMedium?.copyWith(
            color: AppColors.limestoneWhite,
          ),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.saffron,
            foregroundColor: AppColors.inkDeep,
            textStyle: const TextStyle(fontWeight: FontWeight.w600),
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.md, horizontal: AppSpacing.lg),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.chipRadius)),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.limestoneWhite,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSpacing.chipRadius),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.md),
        ),
        dividerTheme: const DividerThemeData(color: AppColors.divider, thickness: 0.5),
        switchTheme: SwitchThemeData(
          thumbColor: MaterialStateProperty.resolveWith(
            (states) => states.contains(MaterialState.selected) ? AppColors.saffron : null),
          trackColor: MaterialStateProperty.resolveWith(
            (states) => states.contains(MaterialState.selected) ? AppColors.saffron.withOpacity(0.4) : null),
        ),
      );

  /// Same brand identity, inverted for low-light viewing (a real user
  /// need for an outdoor/hiking app used at dawn or after dusk) — not a
  /// generic Material dark scheme swap.
  static ThemeData get dark => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.inkDeep,
        colorScheme: const ColorScheme.dark(
          primary: AppColors.saffron,
          secondary: AppColors.saffron,
          tertiary: AppColors.clay,
          surface: AppColors.ink,
          error: Color(0xFFE38E7E),
        ),
        textTheme: AppTypography.textTheme.apply(
          bodyColor: AppColors.limestoneWhite,
          displayColor: AppColors.limestoneWhite,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.inkDeep,
          foregroundColor: AppColors.limestoneWhite,
          elevation: 0,
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.saffron,
            foregroundColor: AppColors.inkDeep,
            textStyle: const TextStyle(fontWeight: FontWeight.w600),
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.md, horizontal: AppSpacing.lg),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.chipRadius)),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white.withValues(alpha: 0.06),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSpacing.chipRadius),
            borderSide: BorderSide.none,
          ),
        ),
        dividerTheme: const DividerThemeData(color: Color(0xFF3A4A40), thickness: 0.5),
      );
}
