import 'package:flutter/material.dart';

import 'app_tokens.dart';

abstract final class AppTheme {
  static ThemeData get light {
    final ColorScheme scheme = ColorScheme.fromSeed(seedColor: AppColors.honey)
        .copyWith(
          primary: AppColors.honey,
          onPrimary: AppColors.onHoney,
          onPrimaryContainer: AppColors.onHoney,
          primaryContainer: AppColors.pastelHoney,
          secondaryContainer: AppColors.pastelSage,
          surface: AppColors.surface,
          onSurface: AppColors.ink,
          outline: AppColors.outline,
        );
    final RoundedRectangleBorder shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppShape.radius),
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: AppColors.paper,
      fontFamily: AppTypography.family,
      textTheme: AppTypography.textTheme.apply(
        bodyColor: AppColors.ink,
        displayColor: AppColors.ink,
      ),
      cardTheme: CardThemeData(
        elevation: AppShape.elevation,
        shape: shape,
        margin: EdgeInsets.zero,
        color: scheme.surface,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(0, AppLayout.minimumTapHeight),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.large,
            vertical: AppSpacing.medium,
          ),
          shape: shape,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppShape.fieldRadius),
        ),
        contentPadding: const EdgeInsets.all(AppSpacing.medium),
      ),
    );
  }
}
