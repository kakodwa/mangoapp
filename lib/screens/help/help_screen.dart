// lib/screens/help/help_screen.dart
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../theme/app_colors.dart';
import '../../theme/design_system/app_spacing.dart';
import '../../widgets/web_footer.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  // Helper method to safely launch the floating WhatsApp thread directly
  Future<void> _launchWhatsApp() async {
    final Uri whatsappUrl = Uri.parse("https://wa.me/265993344416");
    if (!await launchUrl(whatsappUrl, mode: LaunchMode.externalApplication)) {
      debugPrint("Could not launch WhatsApp link thread.");
    }
  }

  Widget _contactCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Row(
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
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  value,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHoursCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.25),
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.access_time, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Support Hours",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  "Monday - Sunday: 8:00 AM - 6:00 PM",
                  style: TextStyle(color: Theme.of(context).colorScheme.outline),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTipCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 10),
          const Expanded(
            child: Text(
              "Tip: Include your order ID when contacting support for faster assistance.",
              style: TextStyle(height: 1.3),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isDesktop = screenWidth >= 800;

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Center(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 1200),
                padding: const EdgeInsets.all(AppSpacing.md),
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
                        children: [
                          Text(
                            "Need Help?",
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.surface,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            "We’re here to help you with orders, payments, shopping, and account issues.",
                            style: TextStyle(
                              color: Colors.white70,
                              height: 1.3,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: AppSpacing.md),

                    const Text(
                      "Contact Support",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: AppSpacing.sm),

                    if (isDesktop)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              children: [
                                _contactCard(
                                  context: context,
                                  icon: Icons.email,
                                  title: "Email Support",
                                  value: "info@malatrade.com",
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                                _contactCard(
                                  context: context,
                                  icon: Icons.phone,
                                  title: "Phone Support",
                                  value: "0993 344 416",
                                  color: Theme.of(context).colorScheme.secondary,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: Column(
                              children: [
                                _buildHoursCard(context),
                                const SizedBox(height: AppSpacing.md),
                                _buildTipCard(context),
                              ],
                            ),
                          )
                        ],
                      )
                    else ...[
                      _contactCard(
                        context: context,
                        icon: Icons.email,
                        title: "Email Support",
                        value: "support@malatrade.com",
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      _contactCard(
                        context: context,
                        icon: Icons.phone,
                        title: "Phone Support",
                        value: "0993 344 416",
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      _buildHoursCard(context),
                      const SizedBox(height: AppSpacing.md),
                      _buildTipCard(context),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 40),
            WebFooter(), 
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _launchWhatsApp,
        backgroundColor: const Color(0xFF25D366), 
        foregroundColor: Colors.white,
        tooltip: "Chat with Support on WhatsApp",
        child: const Icon(Icons.chat),
      ),
    );
  }
}