import 'package:flutter/material.dart';
import '../../widgets/main_app_bar.dart';
import '../../theme/app_colors.dart';
import '../../widgets/app_scaffold.dart';
import '../../theme/design_system/app_spacing.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  Widget _featureCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String desc,
    required Color color,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  desc,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: const MainAppBar(title: 'About App'),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // =========================
            // HERO SECTION
            // =========================
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.mangoOrange,
                    AppColors.mangoLight,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children:  [
                  Text(
                    "MultiConnect Marketplace",
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.surface,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "Your Local Marketplace for Shops, Food & Property in Mangochi",
                    style: TextStyle(
                      color: Colors.white70,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.md),

            Text(
              "Why use this platform",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: AppSpacing.sm),

            _featureCard(
              context: context,
              icon: Icons.store,
              title: "All Shops in One Place",
              desc:
                  "Find all Mangochi shops in one platform and compare prices easily.",
              color: AppColors.mangoOrange,
            ),

            _featureCard(
              context: context,
              icon: Icons.local_shipping,
              title: "Fast & Reliable Delivery",
              desc:
                  "We pick, verify, and deliver items safely to your location.",
              color: Theme.of(context).colorScheme.primary,
            ),

            _featureCard(
              context: context,
              icon: Icons.verified,
              title: "Verified Properties",
              desc: "Only verified land and houses are listed (no scams).",
              color: Theme.of(context).colorScheme.secondary,
            ),

            _featureCard(
              context: context,
              icon: Icons.security,
              title: "Secure Payments",
              desc:
                  "Pay safely via mobile money integration (PayChangu simulation).",
              color: Colors.purple,
            ),

            _featureCard(
              context: context,
              icon: Icons.trending_up,
              title: "Earn & Sell Easily",
              desc:
                  "Shop owners and property owners can earn through the platform.",
              color: Colors.teal,
            ),

            _featureCard(
              context: context,
              icon: Icons.phone_android,
              title: "Works on All Phones",
              desc:
                  "Lightweight, fast and mobile-first design for all devices.",
              color: Colors.redAccent,
            ),

            const SizedBox(height: AppSpacing.md),

            // =========================
            // VERSION CARD
            // =========================
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.25)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "App Version",
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  Text(
                    "1.0.0",
                    style: TextStyle(color: Theme.of(context).colorScheme.outline),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
