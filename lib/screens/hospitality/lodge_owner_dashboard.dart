// lib/screens/hospitality/lodge_owner_dashboard.dart

import 'package:flutter/material.dart';
import '../../widgets/web_footer.dart';
import '../../theme/design_system/app_spacing.dart';
import '../../theme/app_colors.dart';
import 'bookings_scanner_screen.dart';
import '../main_tabs_screen.dart';

class LodgeOwnerDashboard extends StatelessWidget {
  const LodgeOwnerDashboard({super.key});

  /// Calculates dynamic column distribution across screen breakpoints
  int _getCrossAxisCount(double width) {
    if (width > 1200) return 4;
    if (width > 750) return 3;
    return 2; // Flat 2-column layout default on standard mobile devices
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isLargeScreen = screenWidth > 900;
    final int crossAxisCount = _getCrossAxisCount(screenWidth);

    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: EdgeInsets.symmetric(
            vertical: AppSpacing.md,
            horizontal: isLargeScreen ? (screenWidth - 800) / 2 : AppSpacing.md,
          ),
          sliver: SliverGrid(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.1,
            ),
            delegate: SliverChildListDelegate(
              [
                _DashboardCard(
                  title: 'Bookings',
                  icon: Icons.book_online,
                  color: AppColors.mangoOrange,
                  onTap: () {
                    MainTabsScreen.of(context)?.navigateToOwnerBookings();
                  },
                ),
                _DashboardCard(
                  title: 'Scan QR',
                  icon: Icons.qr_code_scanner,
                  color: Colors.deepPurple,
                  onTap: () {
                    MainTabsScreen.of(context)?.navigateToBookingScanner();
                  },
                ),

                // ✅ CREATE LODGE MODULE LINK
                _DashboardCard(
                  title: 'Create Lodge',
                  icon: Icons.add_business,
                  color: AppColors.mangoOrange,
                  onTap: () {
                    MainTabsScreen.of(context)?.navigateToCreateLodge();
                  },
                ),

                // ✅ MY LODGES PROFILE COLLECTION
                _DashboardCard(
                  title: 'My Lodges',
                  icon: Icons.apartment,
                  color: AppColors.leafGreen,
                  onTap: () {
                    MainTabsScreen.of(context)?.navigateToMyLodges();
                  },
                ),
              ],
            ),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 40)),
        const SliverToBoxAdapter(child: WebFooter()),
      ],
    );
  }
}

class _DashboardCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback? onTap;
  final Color? color;

  const _DashboardCard({
    required this.title,
    required this.icon,
    this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final activeColor = color ?? (Theme.of(context).brightness == Brightness.dark 
        ? Colors.white70 
        : Colors.black87);

    return Container(
      decoration: BoxDecoration(
        color: activeColor.withOpacity(0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: activeColor.withOpacity(0.12),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          splashColor: activeColor.withOpacity(0.1),
          highlightColor: activeColor.withOpacity(0.05),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.sm),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: 38,
                  color: activeColor,
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: activeColor.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}