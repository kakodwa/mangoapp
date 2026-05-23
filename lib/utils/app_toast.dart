<<<<<<< HEAD
// Re-export the professional AppToast from design system
export '../theme/design_system/app_toast.dart';
=======
import 'package:flutter/material.dart';
import 'package:toastification/toastification.dart';
import '../theme/app_colors.dart';

class AppToast {
  static void success(BuildContext context, String message) {
    toastification.show(
      context: context,
      title: Text(message),
      type: ToastificationType.success,
      style: ToastificationStyle.fillColored,
      backgroundColor: AppColors.mangoOrange,
      foregroundColor: Colors.white,
      autoCloseDuration: const Duration(seconds: 4),
    );
  }

  static void error(BuildContext context, String message) {
    toastification.show(
      context: context,
      title: Text(message),
      type: ToastificationType.error,
      style: ToastificationStyle.fillColored,
      backgroundColor: Colors.red,
      foregroundColor: Colors.white,
      autoCloseDuration: const Duration(seconds: 5),
    );
  }

  static void info(BuildContext context, String message) {
    toastification.show(
      context: context,
      title: Text(message),
      type: ToastificationType.info,
      style: ToastificationStyle.fillColored,
      backgroundColor: AppColors.leafGreen,
      foregroundColor: Colors.white,
      autoCloseDuration: const Duration(seconds: 4),
    );
  }
}
>>>>>>> 0cfc4702230a362924a138a5e87e31febed75a63
