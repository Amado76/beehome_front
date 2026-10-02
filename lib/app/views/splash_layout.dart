import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../design_system/theme/app_tokens.dart';

// Presentation values selected once, shared by the splash components.
class SplashLayout {
  const SplashLayout({
    this.frameInset = 0,
    this.frameRadius = 0,
    this.frameDecoration = const BoxDecoration(color: Colors.white),
    this.padding = 24,
    this.contentWidth = 320,
    this.progressWidth = 250,
    this.mascotWidth = 224,
    this.mascotHeight = 240,
    this.shadowWidth = 96,
    this.heroPadding = 40,
    this.monoFamily = AppTypography.typewriterFamily,
    this.captionSize = 12,
    this.taglineSize = 13,
    this.smallCaptionSize = 10,
    this.brandStyle = AppTypography.splashBrand,
    this.showFlightTrail = true,
  });

  static const SplashLayout compact = SplashLayout();
  static const SplashLayout notebook = SplashLayout(
    frameInset: 24,
    frameRadius: 36,
    frameDecoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.all(Radius.circular(36)),
      border: Border.fromBorderSide(BorderSide(color: Color(0x2E81756B))),
      boxShadow: [
        BoxShadow(
          color: Color(0x141F1A17),
          blurRadius: 32,
          offset: Offset(0, 12),
        ),
      ],
    ),
    padding: 40,
    contentWidth: 520,
    progressWidth: 420,
    mascotWidth: 240,
    mascotHeight: 220,
    shadowWidth: 128,
    heroPadding: 16,
    monoFamily: AppTypography.journalFamily,
    captionSize: 14,
    taglineSize: 16,
    smallCaptionSize: 12,
    brandStyle: AppTypography.notebookBrand,
    showFlightTrail: false,
  );

  static SplashLayout forWidth(double width) => switch (width) {
    < AppLayout.tablet => compact,
    _ => notebook,
  };

  final double frameInset;
  final double frameRadius;
  final BoxDecoration frameDecoration;
  final double padding;
  final double contentWidth;
  final double progressWidth;
  final double mascotWidth;
  final double mascotHeight;
  final double shadowWidth;
  final double heroPadding;
  final String monoFamily;
  final double captionSize;
  final double taglineSize;
  final double smallCaptionSize;
  final TextStyle brandStyle;
  final bool showFlightTrail;

  Size canvasSize(Size available) {
    // Keep notebook margins proportional without wasting space on wide screens.
    final double inset = frameInset == 0
        ? 0
        : (available.shortestSide * .04).clamp(frameInset, 64).toDouble();
    return Size(
      math.max(0, available.width - inset * 2),
      math.max(0, available.height - inset * 2),
    );
  }

  TextStyle get caption => AppTypography.loadingCaption.copyWith(
    fontFamily: monoFamily,
    fontSize: captionSize,
    color: AppColors.mutedInk,
  );

  TextStyle get tagline => AppTypography.notebookCaption.copyWith(
    fontFamily: monoFamily,
    fontSize: taglineSize,
    color: AppColors.mutedInk,
    letterSpacing: .8,
  );

  TextStyle get smallCaption => AppTypography.smallCaption.copyWith(
    fontFamily: monoFamily,
    fontSize: smallCaptionSize,
  );
}
