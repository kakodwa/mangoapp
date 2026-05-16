// lib/theme/design_system/app_spacing.dart

class AppSpacing {
  AppSpacing._();

  // Minimal Spacing
  static const double xxs = 4;
  static const double xs = 8;
  static const double sm = 12;
  
  // Standard Spacing
  static const double md = 16;
  static const double lg = 24;
  
  // Large Spacing
  static const double xl = 32;
  static const double xxl = 48;

  // Common Padding Patterns
  static const EdgeInsets paddingXs = EdgeInsets.all(xs);
  static const EdgeInsets paddingSm = EdgeInsets.all(sm);
  static const EdgeInsets paddingMd = EdgeInsets.all(md);
  static const EdgeInsets paddingLg = EdgeInsets.all(lg);
  
  // Horizontal Padding
  static const EdgeInsets paddingHorizontalSm = EdgeInsets.symmetric(horizontal: sm);
  static const EdgeInsets paddingHorizontalMd = EdgeInsets.symmetric(horizontal: md);
  static const EdgeInsets paddingHorizontalLg = EdgeInsets.symmetric(horizontal: lg);
  
  // Vertical Padding
  static const EdgeInsets paddingVerticalSm = EdgeInsets.symmetric(vertical: sm);
  static const EdgeInsets paddingVerticalMd = EdgeInsets.symmetric(vertical: md);
  static const EdgeInsets paddingVerticalLg = EdgeInsets.symmetric(vertical: lg);
}
