import 'package:flutter/material.dart';

abstract final class AppColors {
  static const Color notebook = Color(0xFFFDFBF7);
  static const Color paperBorder = Color(0xFFE4DFD5);
  static const Color paperWarm = Color(0xFFF7F4EE);
  static const Color notebookInk = Color(0xFF2C2C2C);
  static const Color pencil = Color(0xFF595753);
  static const Color paperDot = Color(0xFFDCD7CC);
  static const Color paper = Color(0xFFFAF6EE);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color ink = Color(0xFF1F1A17);
  static const Color honey = Color(0xFFF5C242);
  static const Color secondary = Color(0xFF8EAEC4);
  static const Color onSecondary = Color(0xFF163747);
  static const Color pastelBlue = Color(0xFFE0F0FA);
  static const Color tertiary = Color(0xFFA7C8B5);
  static const Color onTertiary = Color(0xFF244536);
  static const Color pastelHoney = Color(0xFFFDECC2);
  static const Color pastelSage = Color(0xFFE1EDDC);
  static const Color honeyLight = Color(0xFFF7C948);
  static const Color honeyDark = Color(0xFF7D6000);
  static const Color onHoney = Color(0xFF624B00);
  static const Color mutedInk = Color(0xFF433A36);
  static const Color progressTrack = Color(0xFFEFE8DD);
  static const Color success = Color(0xFF10B981);
  static const Color outline = Color(0xFF81756B);
}

abstract final class AppSpacing {
  static const double small = 8;
  static const double medium = 16;
  static const double large = 24;
  static const double extraLarge = 40;
}

abstract final class AppShape {
  static const double radius = 20;
  static const double fieldRadius = 12;
  static const double elevation = 1;
}

abstract final class AppLayout {
  // Logical widths: mobile < 600, tablet < 1200, and desktop >= 1200.
  // Web follows the window width, regardless of platform.
  static const double tablet = 600;
  static const double desktop = 1200;
  static const double formWidth = 440;
  static const double contentWidth = 1120;
  static const double minimumTapHeight = 48;
}

abstract final class AppTypography {
  static const String family = 'PlusJakartaSans';
  static const String typewriterFamily = 'CourierPrime';
  static const String brandFamily = 'Fredoka';
  static const String journalFamily = 'SpaceMono';
  static const TextStyle notebookBrand = TextStyle(
    fontFamily: family,
    fontSize: 54,
    fontWeight: FontWeight.w800,
    height: 1.1,
    letterSpacing: -2,
  );
  static const TextStyle splashBrand = TextStyle(
    fontFamily: brandFamily,
    fontSize: 42,
    fontWeight: FontWeight.w700,
    height: 1.1,
    letterSpacing: -1,
  );
  static const TextStyle notebookCaption = TextStyle(
    fontFamily: typewriterFamily,
    fontSize: 13,
    height: 1.4,
  );
  static const TextStyle loadingCaption = TextStyle(
    fontFamily: typewriterFamily,
    fontSize: 12,
    height: 1.5,
  );
  static const TextStyle smallCaption = TextStyle(
    fontFamily: typewriterFamily,
    fontSize: 10,
    height: 1.5,
    letterSpacing: .5,
  );
  static const TextTheme textTheme = TextTheme(
    headlineLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.w700),
    headlineSmall: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
    bodyLarge: TextStyle(fontSize: 16, height: 1.5),
    bodyMedium: TextStyle(fontSize: 14, height: 1.5),
  );
}
