// lib/widgets/web_footer.dart

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../screens/about/about_screen.dart';
import '../screens/help/help_screen.dart';
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

  // Helper method to safely launch external URLs for the admin portal
  Future<void> _launchAdminUrl() async {
    final Uri url = Uri.parse('https://mangobackend-yayy.onrender.com/admin_appconsole/dashboard/'); // Replace with your actual admin web URL
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    
    if (screenWidth < 600) {
      return const SizedBox.shrink();
    }

    final bool isDesktop = screenWidth >= 950;

    return Container(
      width: double.infinity,
      // Styled with Mango brand orange color base
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
              
              // Responsive flex lane for legal copy and administrative entries
              Flex(
                direction: isDesktop ? Axis.horizontal : Axis.vertical,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    '© 2026 MangoHub Marketplace. All rights reserved.',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                    ),
                  ),
                  if (!isDesktop) const SizedBox(height: 12),
                  TextButton.icon(
                    onPressed: () {
                      _analyticsService.logEvent('footer_admin_portal_click');
                      _launchAdminUrl();
                    },
                    icon: const Icon(Icons.admin_panel_settings_outlined, size: 16, color: Colors.white),
                    label: const Text('Admin Portal'),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.white,
                      textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
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
              'MangoHub',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white),
            ),
          ],
        ),
        const SizedBox(height: 8),
        // FIXED: Replaced 'Colors.whiteAmd' typo with standard 'Colors.white70'
        const Text(
          'Everything Local. One Hub.',
          style: TextStyle(color: Colors.white70, fontSize: 13),
        ),
        const SizedBox(height: 16),
        ElevatedButton.icon(
          onPressed: () => _showAppInstallDialog(context),
          icon: const Icon(Icons.phone_android_rounded, size: 18, color: Color(0xFFF57C00)),
          label: const Text('Install Mobile App'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: const Color(0xFFF57C00),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          ),
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
              // Trigger analytics event safely in the background
              _analyticsService.logEvent('footer_about_click');
              
              Navigator.pop(context);
              if (onAboutTap != null) {
                onAboutTap!();
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
                  Navigator.push(
                    context, 
                    MaterialPageRoute(builder: (_) => HelpSupportScreen()),
                  );
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
        width: 64,
        height: 40,
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: Colors.white24, width: 1),
        ),
        child: Image.asset(
          assetPath,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            return Center(
              child: Icon(Icons.credit_card, size: 18, color: Colors.grey[400]),
            );
          },
        ),
      ),
    );
  }

  void _showAppInstallDialog(BuildContext context) {
    _analyticsService.logEvent('footer_install_app_click');
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Get the MangoHub App'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Scan or access via your phone mobile store provider to experience seamless push updates, orders, and geolocation tools.'),
            SizedBox(height: 16),
            Center(
              child: Icon(Icons.qr_code_2_rounded, size: 140, color: Colors.black87),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}