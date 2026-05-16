import 'package:flutter/material.dart';

enum BadgeType {
  primary,
  success,
  warning,
  error,
  info,
}

class AppBadge extends StatelessWidget {
  final String text;
  final BadgeType type;
  final Color? customColor;
  final double fontSize;
  final EdgeInsets padding;

  const AppBadge({
    super.key,
    required this.text,
    this.type = BadgeType.primary,
    this.customColor,
    this.fontSize = 10,
    this.padding = const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
  });

  Color get backgroundColor {
    if (customColor != null) return customColor!;
    
    switch (type) {
      case BadgeType.primary:
        return Colors.orange;
      case BadgeType.success:
        return Colors.green;
      case BadgeType.warning:
        return Colors.amber;
      case BadgeType.error:
        return Colors.red;
      case BadgeType.info:
        return Colors.blue;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor.withOpacity(0.85),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        text.toUpperCase(),
        style: TextStyle(
          color: Colors.white,
          fontSize: fontSize,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.4,
        ),
      ),
    );
  }
}
