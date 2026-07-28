// lib/widgets/web_footer.dart

import 'package:flutter/material.dart';
import '../screens/main_tabs_screen.dart'; 
import '../services/analytics_service.dart';

class WebFooter extends StatelessWidget {
  final VoidCallback? onAboutTap;
  final VoidCallback? onHelpTap;

  static final AnalyticsService _analyticsService = AnalyticsService();

  const WebFooter({
    super.key,
    this.onAboutTap,
    this.onHelpTap,
  });

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    
    if (screenWidth < 600) {
      return const SizedBox.shrink();
    }

    final bool isDesktop = screenWidth >= 950;

    return Container(
      width: double.infinity,
      color: const Color(0xFFF57C00),
      padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Column(
            children: [
              if (isDesktop)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildBrandSection(context),
                    _buildLinksColumn(context),
                    _buildPaymentSection(context),
                  ],
                )
              else
                Column(
                  children: [
                    _buildBrandSection(context),
                    const SizedBox(height: 32),
                    _buildLinksColumn(context),
                    const SizedBox(height: 32),
                    _buildPaymentSection(context),
                  ],
                ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 24.0),
                child: Divider(thickness: 0.5, height: 1, color: Colors.white30),
              ),
              
              const Center(
                child: Text(
                  '© 2026 MalaTrade Marketplace. All rights reserved.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBrandSection(BuildContext context) {
    return Column(
      crossAxisAlignment: MediaQuery.of(context).size.width >= 950 
          ? CrossAxisAlignment.start 
          : CrossAxisAlignment.center,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(6),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4),
                ],
              ),
              child: Image.asset('assets/images/logo.png', height: 28),
            ),
            const SizedBox(width: 10),
            const Text(
              '',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white),
            ),
          ],
        ),
        const SizedBox(height: 8),
        const Text(
          'Everything Local. One Hub.',
          style: TextStyle(color: Colors.white70, fontSize: 13),
        ),
      ],
    );
  }

  Widget _buildLinksColumn(BuildContext context) {
    const linkStyle = TextStyle(
      color: Colors.white,
      fontWeight: FontWeight.w500,
      fontSize: 14,
    );

    final isCentered = MediaQuery.of(context).size.width < 950;

    return Column(
      crossAxisAlignment: isCentered ? CrossAxisAlignment.center : CrossAxisAlignment.start,
      children: [
        const Text(
          'Platform Navigation',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.white),
        ),
        const SizedBox(height: 12),
        Wrap(
          direction: isCentered ? Axis.horizontal : Axis.vertical,
          spacing: 12,
          runSpacing: 8,
          children: [
            TextButton(
              onPressed: () {
                _analyticsService.logEvent('footer_about_click');
                if (onAboutTap != null) {
                  onAboutTap!();
                } else {
                  MainTabsScreen.of(context)?.setSelectedIndex(10);
                }
              },
              child: const Text('About App', style: linkStyle),
            ),
            TextButton(
              onPressed: () {
                _analyticsService.logEvent('footer_help_click');
                if (onHelpTap != null) {
                  onHelpTap!();
                } else {
                  MainTabsScreen.of(context)?.setSelectedIndex(11);
                }
              },
              child: const Text('Help & Support', style: linkStyle),
            ),
            TextButton(onPressed: () {}, child: const Text('Terms of Service', style: linkStyle)),
            TextButton(onPressed: () {}, child: const Text('Privacy Policy', style: linkStyle)),
          ],
        ),
      ],
    );
  }

  Widget _buildPaymentSection(BuildContext context) {
    return Column(
      crossAxisAlignment: MediaQuery.of(context).size.width >= 950 
          ? CrossAxisAlignment.start 
          : CrossAxisAlignment.center,
      children: [
        const Text(
          'Supported Payment Methods',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.white),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          alignment: WrapAlignment.center,
          children: [
            _paymentLogo('assets/images/tnm.png', 'TNM Mpamba'),
            _paymentLogo('assets/images/airtel.png', 'Airtel Money'),
            _paymentLogo('assets/images/changu.png', 'Changu Pay'),
            _paymentLogo('assets/images/visa.png', 'Visa Card'),
          ],
        ),
      ],
    );
  }

  Widget _paymentLogo(String assetPath, String tooltip) {
    return Tooltip(
      message: tooltip,
      child: Container(
        width: 84,  // Larger width
        height: 52, // Larger height
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.white24, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Image.asset(
          assetPath,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            return Center(
              child: Icon(Icons.credit_card, size: 24, color: Colors.grey[400]),
            );
          },
        ),
      ),
    );
  }
}