import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

enum AppInfoType {
  info,
  success,
  warning,
  error,
}

class AppInfoBox extends StatelessWidget {
  final String message;
  final IconData icon;
  final AppInfoType type;

  const AppInfoBox({
    super.key,
    required this.message,
    this.icon = Icons.info_outline,
    this.type = AppInfoType.info,
  });

  Color _getColor(BuildContext context) {
    switch (type) {
      case AppInfoType.success:
        return Colors.green;
      case AppInfoType.warning:
        return Colors.orange;
      case AppInfoType.error:
        return Colors.red;
      case AppInfoType.info:
      default:
        return AppColors.mangoOrange;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _getColor(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.10),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: color.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }
}


// ==========================================================
// 🔔 APP INFO BOX - USAGE EXAMPLES
// ==========================================================

/// ✅ BASIC INFO MESSAGE
/*
AppInfoBox(
  message: "Please enter the delivery code you received from the shop owner.",
)
*/

/// ℹ️ INFO TYPE (DEFAULT)
/*
AppInfoBox(
  type: AppInfoType.info,
  icon: Icons.info_outline,
  message: "This is an information message.",
)
*/

/// ✅ SUCCESS MESSAGE
/*
AppInfoBox(
  type: AppInfoType.success,
  icon: Icons.check_circle,
  message: "Payment completed successfully.",
)
*/

/// ⚠️ WARNING MESSAGE
/*
AppInfoBox(
  type: AppInfoType.warning,
  icon: Icons.warning_amber,
  message: "Please double-check your order details.",
)
*/

/// ❌ ERROR MESSAGE
/*
AppInfoBox(
  type: AppInfoType.error,
  icon: Icons.error_outline,
  message: "Something went wrong. Please try again.",
)
*/

/// 🚚 DELIVERY EXAMPLE (YOUR CASE)
/*
AppInfoBox(
  message: "Please enter the delivery code you received from the shop owner you are delivering for.",
)
*/