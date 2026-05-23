import 'package:flutter/material.dart';
import '../../widgets/main_app_bar.dart';
import '../../theme/app_colors.dart';
<<<<<<< HEAD
import '../../widgets/app_scaffold.dart';
=======
>>>>>>> 0cfc4702230a362924a138a5e87e31febed75a63

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  Widget _featureCard({
    required IconData icon,
    required String title,
    required String desc,
    required Color color,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
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
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  desc,
                  style: TextStyle(
                    color: Colors.grey[600],
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
<<<<<<< HEAD
    return AppScaffold(
=======
    return Scaffold(
>>>>>>> 0cfc4702230a362924a138a5e87e31febed75a63
      appBar: const MainAppBar(title: 'About App'),
      backgroundColor: const Color(0xFFF6F7FB),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // =========================
            // HERO SECTION
            // =========================
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
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
                children: const [
                  Text(
                    "MultiConnect Marketplace",
                    style: TextStyle(
                      color: Colors.white,
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

            const SizedBox(height: 20),

            const Text(
              "Why use this platform",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            _featureCard(
              icon: Icons.store,
              title: "All Shops in One Place",
              desc:
                  "Find all Mangochi shops in one platform and compare prices easily.",
              color: AppColors.mangoOrange,
            ),

            _featureCard(
              icon: Icons.local_shipping,
              title: "Fast & Reliable Delivery",
              desc:
                  "We pick, verify, and deliver items safely to your location.",
              color: Colors.blue,
            ),

            _featureCard(
              icon: Icons.verified,
              title: "Verified Properties",
              desc: "Only verified land and houses are listed (no scams).",
              color: Colors.green,
            ),

            _featureCard(
              icon: Icons.security,
              title: "Secure Payments",
              desc:
                  "Pay safely via mobile money integration (PayChangu simulation).",
              color: Colors.purple,
            ),

            _featureCard(
              icon: Icons.trending_up,
              title: "Earn & Sell Easily",
              desc:
                  "Shop owners and property owners can earn through the platform.",
              color: Colors.teal,
            ),

            _featureCard(
              icon: Icons.phone_android,
              title: "Works on All Phones",
              desc:
                  "Lightweight, fast and mobile-first design for all devices.",
              color: Colors.redAccent,
            ),

            const SizedBox(height: 16),

            // =========================
            // VERSION CARD
            // =========================
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text(
                    "App Version",
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  Text(
                    "1.0.0",
                    style: TextStyle(color: Colors.grey),
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