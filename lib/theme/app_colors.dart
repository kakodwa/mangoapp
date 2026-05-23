import 'package:flutter/material.dart';

class AppColors {
  AppColors._(); // prevents instantiation

<<<<<<< HEAD
  //Brand Colors (from main.dart)
=======
  // 🌿 Brand Colors (from main.dart)
>>>>>>> 0cfc4702230a362924a138a5e87e31febed75a63
  static const Color mangoOrange = Color(0xFFFF8C00);
  static const Color mangoLight = Color(0xFFFFA726);
  static const Color leafGreen = Color(0xFF2E7D32);
  static const Color darkText = Color(0xFF212121);

<<<<<<< HEAD
  //Semantic mapping (VERY IMPORTANT)
=======
  // 🧠 Semantic mapping (VERY IMPORTANT)
>>>>>>> 0cfc4702230a362924a138a5e87e31febed75a63
  static Color primary(BuildContext context) =>
      Theme.of(context).colorScheme.primary;

  static Color secondary(BuildContext context) =>
      Theme.of(context).colorScheme.secondary;

  static Color error(BuildContext context) =>
      Theme.of(context).colorScheme.error;

  static Color text(BuildContext context) =>
      Theme.of(context).colorScheme.onSurface;
}