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
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color:
                Theme.of(context).colorScheme.onSurface.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
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
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  desc,
                  style: TextStyle(
                    color:
                        Theme.of(context).colorScheme.onSurfaceVariant,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: const MainAppBar(title: 'About MangoHub'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // =========================
            // HERO SECTION
            // =========================
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.mangoOrange,
                    AppColors.mangoLight,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    "MangoHub",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  SizedBox(height: 10),

                  Text(
                    "Everything Local. One Hub.",
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),

                  SizedBox(height: 14),

                  Text(
                    "MangoHub is a multi-service digital marketplace "
                    "that connects shopping, hospitality, real estate, "
                    "events, and payments into one unified platform.",
                    style: TextStyle(
                      color: Colors.white,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.lg),

            // =========================
            // PLATFORM SERVICES
            // =========================
            _sectionTitle("Platform Services"),

            _featureCard(
              context: context,
              icon: Icons.shopping_bag_outlined,
              title: "E-Commerce Marketplace",
              desc:
                  "Browse local shops, discover products, add items to cart, "
                  "and place orders with secure checkout and delivery support.",
              color: AppColors.mangoOrange,
            ),

            _featureCard(
              context: context,
              icon: Icons.home_work_outlined,
              title: "Real Estate",
              desc:
                  "Explore verified houses, land, and rental properties with "
                  "detailed information, amenities, and image galleries.",
              color: Colors.teal,
            ),

            _featureCard(
              context: context,
              icon: Icons.hotel_outlined,
              title: "Hospitality Booking",
              desc:
                  "Find lodges and rooms, compare pricing, check availability, "
                  "and make online bookings directly from the app.",
              color: Colors.indigo,
            ),

            _featureCard(
              context: context,
              icon: Icons.confirmation_num_outlined,
              title: "Events & Ticketing",
              desc:
                  "Discover upcoming events, buy digital tickets, and manage "
                  "your event attendance with ticket verification support.",
              color: Colors.deepPurple,
            ),

            _featureCard(
              context: context,
              icon: Icons.account_balance_wallet_outlined,
              title: "Digital Wallet",
              desc:
                  "Manage your wallet balance, make secure payments, track "
                  "transactions, and pay across all platform services.",
              color: Colors.green,
            ),

            const SizedBox(height: AppSpacing.lg),

            // =========================
            // WHY USE
            // =========================
            _sectionTitle("Why Use MangoHub"),

            _featureCard(
              context: context,
              icon: Icons.storefront_outlined,
              title: "Everything in One Platform",
              desc:
                  "Access shopping, bookings, property listings, events, "
                  "and payments from a single mobile application.",
              color: Colors.orange,
            ),

            _featureCard(
              context: context,
              icon: Icons.verified_user_outlined,
              title: "Trusted & Verified",
              desc:
                  "Properties, vendors, and services are verified to help "
                  "reduce scams and improve trust for users.",
              color: Colors.blue,
            ),

            _featureCard(
              context: context,
              icon: Icons.lock_outline,
              title: "Secure Transactions",
              desc:
                  "Built with secure authentication, protected payments, "
                  "and encrypted communication for safer transactions.",
              color: Colors.redAccent,
            ),

            _featureCard(
              context: context,
              icon: Icons.phone_android_outlined,
              title: "Mobile First Experience",
              desc:
                  "Fast, lightweight, and optimized for Android devices "
                  "with a smooth and modern user experience.",
              color: Colors.pink,
            ),

            const SizedBox(height: AppSpacing.lg),

            // =========================
            // TECHNOLOGY
            // =========================
            _sectionTitle("Built With"),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.flutter_dash,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 10),
                      const Expanded(
                        child: Text(
                          "Flutter Frontend with Riverpod state management",
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  Row(
                    children: [
                      Icon(
                        Icons.storage_outlined,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 10),
                      const Expanded(
                        child: Text(
                          "Django REST Framework backend with PostgreSQL database",
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  Row(
                    children: [
                      Icon(
                        Icons.security_outlined,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 10),
                      const Expanded(
                        child: Text(
                          "JWT authentication and secure RESTful APIs",
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.lg),

            // =========================
            // FUTURE FEATURES
            // =========================
            _sectionTitle("Upcoming Features"),

            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                _chip("Push Notifications"),
                _chip("AI Recommendations"),
                _chip("Multi-language Support"),
              ],
            ),

            const SizedBox(height: AppSpacing.lg),

            // =========================
            // VERSION CARD
            // =========================
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Theme.of(context)
                      .colorScheme
                      .outline
                      .withOpacity(0.2),
                ),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "App Version",
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        "1.0.0",
                        style: TextStyle(
                          color: Theme.of(context)
                              .colorScheme
                              .outline,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  Text(
                    "© 2026 MangoHub Platform",
                    style: TextStyle(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurfaceVariant,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  static Widget _chip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 10,
      ),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}