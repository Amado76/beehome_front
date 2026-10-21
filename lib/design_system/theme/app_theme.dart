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
          secondary: AppColors.secondary,
          onSecondary: AppColors.onSecondary,
          secondaryContainer: AppColors.pastelBlue,
          onSecondaryContainer: AppColors.onSecondary,
          tertiary: AppColors.tertiary,
          onTertiary: AppColors.onTertiary,
          tertiaryContainer: AppColors.pastelSage,
          onTertiaryContainer: AppColors.onTertiary,
          surface: AppColors.surface,
          onSurface: AppColors.ink,
          outline: AppColors.outline,
        );
    final RoundedRectangleBorder shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppShape.radius),
    );
    final RoundedRectangleBorder controlShape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppShape.controlRadius),
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
          shape: controlShape,
          backgroundColor: AppColors.honey,
          foregroundColor: AppColors.onHoney,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.notebookInk,
          backgroundColor: AppColors.notebook,
          side: const BorderSide(color: AppColors.paperBorder),
          minimumSize: const Size(0, AppLayout.minimumTapHeight),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          shape: controlShape,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: Colors.black,
          minimumSize: const Size(0, AppLayout.minimumTapHeight),
          shape: controlShape,
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.notebook,
        selectedColor: AppColors.pastelHoney,
        disabledColor: AppColors.paperWarm,
        checkmarkColor: AppColors.notebookInk,
        labelStyle: AppTypography.notebookCaption.copyWith(
          color: AppColors.notebookInk,
        ),
        side: const BorderSide(color: AppColors.paperBorder),
        shape: controlShape,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.notebook,
        titleTextStyle: AppTypography.dialogTitle,
        surfaceTintColor: Colors.transparent,
        shape: shape,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: false,
        fillColor: Colors.transparent,
        isDense: true,
        hintStyle: AppTypography.input.copyWith(
          color: AppColors.pencil.withValues(alpha: .65),
          fontSize: 14,
          fontStyle: FontStyle.italic,
        ),
        border: const UnderlineInputBorder(
          borderSide: BorderSide(color: AppColors.paperBorder),
        ),
        enabledBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: AppColors.paperBorder),
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: AppColors.notebookInk, width: 2),
        ),
        disabledBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: AppColors.paperBorder),
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 8),
      ),
    );
  }
}
