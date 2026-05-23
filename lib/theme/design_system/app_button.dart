import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

enum AppButtonType {
  primary,
  secondary,
  outline,
}

class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool loading;
  final bool fullWidth;
  final double? width;
  final double height;
  final IconData? icon;

  final Color? backgroundColor;
  final Color? textColor;
  final AppButtonType type;

  const AppButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.loading = false,
    this.fullWidth = false,
    this.width,
    this.height = 52,
    this.icon,
    this.backgroundColor,
    this.textColor,
    this.type = AppButtonType.primary,
  });

  @override
  Widget build(BuildContext context) {
    final bool isPrimary = type == AppButtonType.primary;
    final bool isSecondary = type == AppButtonType.secondary;
    final bool isOutline = type == AppButtonType.outline;

    final Color bgColor = backgroundColor ??
        (isPrimary
            ? AppColors.primary(context)
            : isSecondary
                ? AppColors.primary(context).withOpacity(0.08)
                : Colors.transparent);

    final Color fgColor = textColor ??
        (isPrimary
            ? Colors.white
            : AppColors.primary(context));

    return SizedBox(
      width: fullWidth ? double.infinity : width,
      height: height,
      child: ElevatedButton(
        onPressed: loading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          elevation: isPrimary ? 1 : 0,
          backgroundColor: bgColor,
          foregroundColor: fgColor,
          shadowColor: Colors.black12,
          padding: const EdgeInsets.symmetric(
            horizontal: 18,
            vertical: 14,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: isOutline
                ? BorderSide(
                    color: AppColors.primary(context),
                    width: 1.4,
                  )
                : BorderSide.none,
          ),
        ),
        child: loading
            ? SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.4,
                  color: fgColor,
                ),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null) ...[
                    Icon(
                      icon,
                      size: 18,
                      color: fgColor,
                    ),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    text,
                    style: TextStyle(
                      color: fgColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

// ==========================================================
// 🔥 APP BUTTON EXAMPLES
// ==========================================================

/// ✅ PRIMARY BUTTON
/*
AppButton(
  text: "Checkout",
  fullWidth: true,
  onPressed: () {},
)
*/

/// ✅ SECONDARY BUTTON
/*
AppButton(
  text: "Cancel",
  type: AppButtonType.secondary,
  fullWidth: true,
  onPressed: () {},
)
*/

/// ✅ OUTLINE BUTTON
/*
AppButton(
  text: "View Details",
  type: AppButtonType.outline,
  onPressed: () {},
)
*/

/// ✅ LOADING BUTTON
/*
AppButton(
  text: "Saving...",
  loading: true,
  fullWidth: true,
  onPressed: () {},
)
*/

/// ✅ BUTTON WITH ICON
/*
AppButton(
  text: "Add to Cart",
  icon: Icons.shopping_cart,
  fullWidth: true,
  onPressed: () {},
)
*/

/// ✅ CUSTOM WIDTH BUTTON
/*
AppButton(
  text: "Continue",
  width: 220,
  onPressed: () {},
)
*/

/// ✅ SMALL BUTTON
/*
AppButton(
  text: "Small Button",
  height: 42,
  width: 160,
  onPressed: () {},
)
*/

/// ✅ CUSTOM COLOR BUTTON
/*
AppButton(
  text: "Delete",
  backgroundColor: Colors.red,
  textColor: Colors.white,
  onPressed: () {},
)
*/