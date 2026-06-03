import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../../utils/app_snackbar.dart';

class AppFab extends StatelessWidget {
  final String heroTag;
  final IconData icon;
  final VoidCallback onPressed;
  final String? tooltip;
  final String? toastMessage;
  final bool mini;

  const AppFab({
    super.key,
    required this.heroTag,
    required this.icon,
    required this.onPressed,
    this.tooltip,
    this.toastMessage,
    this.mini = true,
  });

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      heroTag: heroTag,
      mini: mini,
      backgroundColor:AppColors.mangoOrange,
      foregroundColor:Colors.white,
      elevation: 4,
      tooltip: tooltip,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: AppColors.mangoOrange.withOpacity(0.15),
        ),
      ),
      onPressed: () {
        if (toastMessage != null) {
          showInfoToast(context, toastMessage!);
        }
        onPressed();
      },
      child: Icon(icon, size: 20),
    );
  }
}