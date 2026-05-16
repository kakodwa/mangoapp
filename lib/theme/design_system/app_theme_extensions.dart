import 'package:flutter/material.dart';

class AppThemeExtensions {
  AppThemeExtensions._();

  // SHADOWS
  static final List<BoxShadow> shadowSmall = [
    BoxShadow(
      color: Colors.black.withOpacity(0.04),
      blurRadius: 8,
      offset: const Offset(0, 2),
    ),
  ];

  static final List<BoxShadow> shadowMedium = [
    BoxShadow(
      color: Colors.black.withOpacity(0.06),
      blurRadius: 14,
      offset: const Offset(0, 6),
    ),
  ];

  static final List<BoxShadow> shadowLarge = [
    BoxShadow(
      color: Colors.black.withOpacity(0.08),
      blurRadius: 24,
      offset: const Offset(0, 12),
    ),
  ];

  static final List<BoxShadow> shadowElevated = [
    BoxShadow(
      color: Colors.black.withOpacity(0.1),
      blurRadius: 32,
      offset: const Offset(0, 16),
    ),
  ];

  // BORDER RADIUS
  static const double radiusSmall = 8;
  static const double radiusMedium = 12;
  static const double radiusLarge = 16;
  static const double radiusXL = 20;
  static const double radiusCircle = 50;

  // DIVIDER
  static Color dividerColor = Colors.grey.shade200;
  static const double dividerThickness = 1;

  // GRADIENT OVERLAYS
  static final LinearGradient gradientOverlayLight = LinearGradient(
    colors: [
      Colors.black.withOpacity(0.0),
      Colors.black.withOpacity(0.15),
    ],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static final LinearGradient gradientOverlayDark = LinearGradient(
    colors: [
      Colors.black.withOpacity(0.2),
      Colors.black.withOpacity(0.4),
    ],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // HOVER & INTERACTIVE STATES
  static const Duration hoverDuration = Duration(milliseconds: 200);
  static const Duration pressDuration = Duration(milliseconds: 100);
  static const double pressScaleFactor = 0.95;
  static const double hoverOpacity = 0.8;
}
