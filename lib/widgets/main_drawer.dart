import 'package:flutter/material.dart';
import '../screens/about/about_screen.dart';
import '../screens/help/help_screen.dart';
import '../theme/app_colors.dart';
import '../theme/design_system/app_spacing.dart';
import '../services/analytics_service.dart'; 

class MainDrawer extends StatelessWidget {
  final VoidCallback? onAboutTap;
  final VoidCallback? onHelpTap;

  // Change this to a static final (or static const) variable
  static final AnalyticsService _analyticsService = AnalyticsService();

  // Now you can restore the const keyword on the constructor
  const MainDrawer({
    super.key,
    this.onAboutTap,
    this.onHelpTap,
  });

  Widget _menuItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  color: Colors.grey.shade400,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Drawer(
      backgroundColor: const Color(0xFFF6F7FB),
      child: Column(
        children: [
          // HEADER
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              60,
              AppSpacing.lg,
              AppSpacing.lg,
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.mangoOrange,
                  AppColors.mangoLight,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Image.asset(
                    'assets/images/logo.png',
                    height: 40,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'MangoHub',
                      style: Theme.of(context)
                          .textTheme
                          .headlineSmall
                          ?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Everything Local.One Hub.',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: Colors.white70,
                          ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.lg),

          // =========================
          // MENU ITEMS
          // =========================
          _menuItem(
            context: context,
            icon: Icons.info,
            title: "About App",
            color: AppColors.mangoOrange,
            onTap: () {
              // Trigger analytics event safely in the background
              _analyticsService.logEvent('drawer_about_click');
              
              Navigator.pop(context);
              if (onAboutTap != null) {
                onAboutTap!();
              }
            },
          ),

          _menuItem(
            context: context,
            icon: Icons.help,
            title: "Help & Support",
            color: AppColors.leafGreen,
            onTap: () {
              // Trigger analytics event safely in the background
              _analyticsService.logEvent('drawer_help_click');
              
              Navigator.pop(context);
              if (onHelpTap != null) {
                onHelpTap!();
              }
            },
          ),

          const Spacer(),

          // VERSION FOOTER
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Text(
              "Version 1.0.0",
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: colorScheme.onSurface.withOpacity(0.5),
                  ),
            ),
          ),
        ],
      ),
    );
  }
}