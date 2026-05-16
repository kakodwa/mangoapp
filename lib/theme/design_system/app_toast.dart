import 'package:flutter/material.dart';
import 'package:toastification/toastification.dart';
import '../app_colors.dart';
import 'app_spacing.dart';
import 'app_typography.dart';

/// Enum for toast notification types
enum ToastType { success, error, warning, info }

/// Professional toast notification system matching the design system
class AppToast {
  AppToast._();

  /// Success toast - green, checkmark icon, 4 second duration
  static void success(
    BuildContext context,
    String message, {
    String? title,
    Duration duration = const Duration(seconds: 4),
    bool dismissible = true,
  }) {
    _show(
      context,
      type: ToastType.success,
      title: title,
      message: message,
      duration: duration,
      dismissible: dismissible,
    );
  }

  /// Error toast - red, error icon, 5 second duration
  static void error(
    BuildContext context,
    String message, {
    String? title,
    Duration duration = const Duration(seconds: 5),
    bool dismissible = true,
  }) {
    _show(
      context,
      type: ToastType.error,
      title: title ?? 'Error',
      message: message,
      duration: duration,
      dismissible: dismissible,
    );
  }

  /// Warning toast - orange, warning icon, 4 second duration
  static void warning(
    BuildContext context,
    String message, {
    String? title,
    Duration duration = const Duration(seconds: 4),
    bool dismissible = true,
  }) {
    _show(
      context,
      type: ToastType.warning,
      title: title,
      message: message,
      duration: duration,
      dismissible: dismissible,
    );
  }

  /// Info toast - blue, info icon, 4 second duration
  static void info(
    BuildContext context,
    String message, {
    String? title,
    Duration duration = const Duration(seconds: 4),
    bool dismissible = true,
  }) {
    _show(
      context,
      type: ToastType.info,
      title: title,
      message: message,
      duration: duration,
      dismissible: dismissible,
    );
  }

  /// Custom toast with full control
  static void custom(
    BuildContext context, {
    required String message,
    String? title,
    required ToastType type,
    Duration duration = const Duration(seconds: 4),
    bool dismissible = true,
    Widget? leading,
    VoidCallback? onTap,
  }) {
    _show(
      context,
      type: type,
      title: title,
      message: message,
      duration: duration,
      dismissible: dismissible,
      leading: leading,
      onTap: onTap,
    );
  }

  /// Internal method to show toast
  static void _show(
    BuildContext context, {
    required ToastType type,
    String? title,
    required String message,
    Duration duration = const Duration(seconds: 4),
    bool dismissible = true,
    Widget? leading,
    VoidCallback? onTap,
  }) {
    final colors = _getToastColors(type);

    toastification.show(
      context: context,
      title: title != null
          ? Text(
              title,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colors['foreground'],
                  ),
            )
          : null,
      description: TextSpan(
        text: message,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: colors['foreground'],
              height: 1.4,
            ),
      ),
      type: _getToastificationType(type),
      style: ToastificationStyle.fillColored,
      backgroundColor: colors['background'] as Color,
      foregroundColor: colors['foreground'] as Color,
      autoCloseDuration: duration,
      showProgressBar: true,
      icon: _getToastIcon(type, colors['foreground'] as Color),
      leading: leading ?? _getDefaultIcon(type, colors['foreground'] as Color),
      trailing: dismissible
          ? GestureDetector(
              onTap: () => toastification.dismissAll(),
              child: Icon(
                Icons.close,
                color: colors['foreground'],
                size: 18,
              ),
            )
          : null,
      onTap: (_) => onTap?.call(),
      alignment: Alignment.topRight,
      margin: const EdgeInsets.all(AppSpacing.md),
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.12),
          blurRadius: 16,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  /// Get toast colors based on type
  static Map<String, dynamic> _getToastColors(ToastType type) {
    switch (type) {
      case ToastType.success:
        return {
          'background': const Color(0xFF10B981),
          'foreground': Colors.white,
        };
      case ToastType.error:
        return {
          'background': const Color(0xFFEF4444),
          'foreground': Colors.white,
        };
      case ToastType.warning:
        return {
          'background': const Color(0xFFF59E0B),
          'foreground': Colors.white,
        };
      case ToastType.info:
        return {
          'background': const Color(0xFF3B82F6),
          'foreground': Colors.white,
        };
    }
  }

  /// Get Toastification type based on our type
  static ToastificationType _getToastificationType(ToastType type) {
    switch (type) {
      case ToastType.success:
        return ToastificationType.success;
      case ToastType.error:
        return ToastificationType.error;
      case ToastType.warning:
        return ToastificationType.warning;
      case ToastType.info:
        return ToastificationType.info;
    }
  }

  /// Get icon for toast
  static Widget _getToastIcon(ToastType type, Color color) {
    switch (type) {
      case ToastType.success:
        return Icon(Icons.check_circle, color: color, size: 20);
      case ToastType.error:
        return Icon(Icons.error, color: color, size: 20);
      case ToastType.warning:
        return Icon(Icons.warning, color: color, size: 20);
      case ToastType.info:
        return Icon(Icons.info, color: color, size: 20);
    }
  }

  /// Get default leading icon
  static Widget _getDefaultIcon(ToastType type, Color color) {
    switch (type) {
      case ToastType.success:
        return Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.check, color: color, size: 18),
        );
      case ToastType.error:
        return Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.close, color: color, size: 18),
        );
      case ToastType.warning:
        return Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.warning, color: color, size: 18),
        );
      case ToastType.info:
        return Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.info, color: color, size: 18),
        );
    }
  }
}
