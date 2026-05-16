import 'package:flutter/material.dart';

class AppColors {
  AppColors._(); // prevents instantiation

  // 🌿 Brand Colors (from main.dart)
  static const Color mangoOrange = Color(0xFFFF8C00);
  static const Color mangoLight = Color(0xFFFFA726);
  static const Color leafGreen = Color(0xFF2E7D32);
  static const Color darkText = Color(0xFF212121);

  // 🧠 Semantic mapping (VERY IMPORTANT)
  static Color primary(BuildContext context) =>
      Theme.of(context).colorScheme.primary;

  static Color secondary(BuildContext context) =>
      Theme.of(context).colorScheme.secondary;

  static Color error(BuildContext context) =>
      Theme.of(context).colorScheme.error;

  static Color text(BuildContext context) =>
      Theme.of(context).colorScheme.onSurface;
}