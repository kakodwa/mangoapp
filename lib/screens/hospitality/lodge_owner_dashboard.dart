// lib/screens/hospitality/lodge_owner_dashboard.dart

import 'package:flutter/material.dart';
import '../../widgets/web_footer.dart';
import 'create_lodge_screen.dart';
import 'my_lodges_screen.dart';
import '../../theme/design_system/app_spacing.dart';
import '../../theme/app_colors.dart';
import 'owner_bookings_screen.dart';
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

    // Standalone root Scaffold containers and explicit top AppBar elements are removed 
    // to allow native continuous layout embedding in MainTabsScreen.
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
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const OwnerBookingsScreen(),
                      ),
                    );
                  },
                ),
                _DashboardCard(
                  title: 'Scan QR',
                  icon: Icons.qr_code_scanner,
                  color: Colors.deepPurple,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const BookingQrScannerScreen(),
                      ),
                    );
                  },
                ),
                _DashboardCard(
                  title: 'Revenue',
                  icon: Icons.payments,
                  color: AppColors.leafGreen,
                  onTap: () {
                    // TODO: revenue screen tracking metrics integration
                  },
                ),
                _DashboardCard(
                  title: 'Guests',
                  icon: Icons.people,
                  color: Colors.blue.shade700,
                  onTap: () {
                    // TODO: guests management list interface
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
    final defaultColor = Theme.of(context).brightness == Brightness.dark 
        ? Colors.white70 
        : Colors.black87;

    return Card(
      elevation: 1.5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: Colors.grey.withOpacity(0.15), width: 1),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 42,
              color: color ?? defaultColor,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: color ?? defaultColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}