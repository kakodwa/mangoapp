import 'package:flutter/material.dart';
import '../screens/main_tabs_screen.dart';
import '../theme/app_colors.dart';
import '../theme/design_system/app_spacing.dart';
import '../services/analytics_service.dart';

class MainDrawer extends StatelessWidget {
  final VoidCallback? onAboutTap;
  final VoidCallback? onHelpTap;
  final VoidCallback? onDeliveryTap;

  static final AnalyticsService _analyticsService = AnalyticsService();

  const MainDrawer({
    super.key,
    this.onAboutTap,
    this.onHelpTap,
    this.onDeliveryTap,
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
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
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
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Image.asset(
                          'assets/images/logo.png',
                          height: 56,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: AppSpacing.md),

                  // =========================
                  // MENU ITEMS
                  // =========================
                  _menuItem(
                    context: context,
                    icon: Icons.map_outlined,
                    title: "Guide",
                    color: Colors.blue,
                    onTap: () {
                      _analyticsService.logEvent('drawer_guide_click');
                      Navigator.pop(context); // Close Drawer
                      MainTabsScreen.of(context)?.setSelectedIndex(43); // MangoHub / Guide
                    },
                  ),

                  _menuItem(
                    context: context,
                    icon: Icons.local_shipping,
                    title: "Delivery",
                    color: Colors.orange,
                    onTap: () {
                      _analyticsService.logEvent('drawer_delivery_click');
                      Navigator.pop(context); // Close Drawer
                      if (onDeliveryTap != null) {
                        onDeliveryTap!();
                      } else {
                        MainTabsScreen.of(context)?.setSelectedIndex(9); // Delivery Code Screen Index
                      }
                    },
                  ),

                  _menuItem(
                    context: context,
                    icon: Icons.qr_code_scanner,
                    title: "Scan Ticket",
                    color: Colors.purple,
                    onTap: () {
                      _analyticsService.logEvent('drawer_scan_ticket_click');
                      Navigator.pop(context); // Close Drawer
                      MainTabsScreen.of(context)?.setSelectedIndex(44); // Scan Ticket Panel Index
                    },
                  ),

                  const Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: 8,
                    ),
                    child: Divider(height: 1),
                  ),

                  _menuItem(
                    context: context,
                    icon: Icons.info,
                    title: "About App",
                    color: AppColors.mangoOrange,
                    onTap: () {
                      _analyticsService.logEvent('drawer_about_click');
                      Navigator.pop(context);
                      if (onAboutTap != null) {
                        onAboutTap!();
                      } else {
                        MainTabsScreen.of(context)?.setSelectedIndex(10);
                      }
                    },
                  ),

                  _menuItem(
                    context: context,
                    icon: Icons.help,
                    title: "Help & Support",
                    color: AppColors.leafGreen,
                    onTap: () {
                      _analyticsService.logEvent('drawer_help_click');
                      Navigator.pop(context);
                      if (onHelpTap != null) {
                        onHelpTap!();
                      } else {
                        MainTabsScreen.of(context)?.setSelectedIndex(11);
                      }
                    },
                  ),
                ],
              ),
            ),

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
      ),
    );
  }
}