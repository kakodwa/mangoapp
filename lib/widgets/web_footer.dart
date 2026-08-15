// lib/widgets/web_footer.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../providers/auth_provider.dart';
import '../screens/auth/login_screen.dart';
import '../screens/main_tabs_screen.dart';
import '../services/analytics_service.dart';

class WebFooter extends ConsumerWidget {
  final VoidCallback? onAboutTap;
  final VoidCallback? onHelpTap;
  final VoidCallback? onDeliveryTap;

  static final AnalyticsService _analyticsService = AnalyticsService();

  const WebFooter({
    super.key,
    this.onAboutTap,
    this.onHelpTap,
    this.onDeliveryTap,
  });

  Future<void> _launchUrl(String path) async {
    final Uri uri = Uri.parse('https://www.malatrade.com/$path');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  /// Helper method to execute action if authenticated, or redirect to LoginScreen
  void _executeProtectedAction(
    BuildContext context,
    WidgetRef ref, {
    required VoidCallback onAuthenticated,
  }) {
    final authState = ref.read(authProvider);
    if (authState.isAuthenticated) {
      onAuthenticated();
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final double screenWidth = MediaQuery.of(context).size.width;

    // Hide footer on mobile screens (< 600px)
    if (screenWidth < 600) {
      return const SizedBox.shrink();
    }

    final bool isDesktop = screenWidth >= 950;

    return Container(
      width: double.infinity,
      color: const Color(0xFF232F3E), // Amazon dark slate color background
      padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Column(
            children: [
              // ================= FOOTER COLUMNS =================
              if (isDesktop)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildColumn(
                      context,
                      title: 'Get to Know Us',
                      items: [
                        _footerLink('About App', () {
                          _analyticsService.logEvent('footer_about_click');
                          if (onAboutTap != null) {
                            onAboutTap!();
                          } else {
                            MainTabsScreen.of(context)?.setSelectedIndex(10);
                          }
                        }),
                        _footerLink('Platform Guide', () {
                          _analyticsService.logEvent('footer_guide_click');
                          MainTabsScreen.of(context)?.setSelectedIndex(43);
                        }),
                        _footerLink('Help & Support', () {
                          _analyticsService.logEvent('footer_help_click');
                          if (onHelpTap != null) {
                            onHelpTap!();
                          } else {
                            MainTabsScreen.of(context)?.setSelectedIndex(11);
                          }
                        }),
                      ],
                    ),
                    _buildColumn(
                      context,
                      title: 'Make Money with Us',
                      items: [
                        _footerLink('Sell Products (Shops)', () {
                          _analyticsService.logEvent('footer_create_shop_click');
                          _executeProtectedAction(context, ref, onAuthenticated: () {
                            MainTabsScreen.of(context)?.navigateToCreateShop();
                          });
                        }),
                        _footerLink('Manage Properties', () {
                          _analyticsService.logEvent('footer_properties_click');
                          _executeProtectedAction(context, ref, onAuthenticated: () {
                            MainTabsScreen.of(context)?.navigateToMyProperties();
                          });
                        }),
                        _footerLink('List Lodges & Hospitality', () {
                          _analyticsService.logEvent('footer_lodge_click');
                          _executeProtectedAction(context, ref, onAuthenticated: () {
                            MainTabsScreen.of(context)?.navigateToLodgeDashboard();
                          });
                        }),
                        _footerLink('Host Events & Tickets', () {
                          _analyticsService.logEvent('footer_manage_events_click');
                          _executeProtectedAction(context, ref, onAuthenticated: () {
                            MainTabsScreen.of(context)?.navigateToManageEvents();
                          });
                        }),
                      ],
                    ),
                    _buildColumn(
                      context,
                      title: 'Platform Navigation',
                      items: [
                        _footerLink('Browse Products', () {
                          _analyticsService.logEvent('footer_products_click');
                          MainTabsScreen.of(context)?.setSelectedIndex(2);
                        }),
                        _footerLink('Browse Shops', () {
                          _analyticsService.logEvent('footer_shops_click');
                          MainTabsScreen.of(context)?.setSelectedIndex(1);
                        }),
                        _footerLink('Confirm Delivery', () {
                          _analyticsService.logEvent('footer_delivery_click');
                          if (onDeliveryTap != null) {
                            onDeliveryTap!();
                          } else {
                            MainTabsScreen.of(context)?.setSelectedIndex(9);
                          }
                        }),
                        _footerLink('Scan Ticket Panel', () {
                          _analyticsService.logEvent('footer_scan_ticket_click');
                          _executeProtectedAction(context, ref, onAuthenticated: () {
                            MainTabsScreen.of(context)?.setSelectedIndex(44);
                          });
                        }),
                      ],
                    ),
                    _buildColumn(
                      context,
                      title: 'Account & Legal',
                      items: [
                        _footerLink('Your Orders', () {
                          _analyticsService.logEvent('footer_orders_click');
                          _executeProtectedAction(context, ref, onAuthenticated: () {
                            MainTabsScreen.of(context)?.navigateToOrders();
                          });
                        }),
                        _footerLink('Your Wallet & Payouts', () {
                          _analyticsService.logEvent('footer_wallet_click');
                          _executeProtectedAction(context, ref, onAuthenticated: () {
                            MainTabsScreen.of(context)?.navigateToWalletTransactions();
                          });
                        }),
                        _footerLink('Terms of Service', () {
                          _analyticsService.logEvent('footer_terms_click');
                          _launchUrl('terms/');
                        }),
                        _footerLink('Privacy Policy', () {
                          _analyticsService.logEvent('footer_privacy_click');
                          _launchUrl('privacy/');
                        }),
                      ],
                    ),
                  ],
                )
              else
                Wrap(
                  spacing: 40,
                  runSpacing: 32,
                  alignment: WrapAlignment.start,
                  children: [
                    _buildColumn(
                      context,
                      title: 'Get to Know Us',
                      items: [
                        _footerLink('About App', () {
                          if (onAboutTap != null) {
                            onAboutTap!();
                          } else {
                            MainTabsScreen.of(context)?.setSelectedIndex(10);
                          }
                        }),
                        _footerLink('Platform Guide', () => MainTabsScreen.of(context)?.setSelectedIndex(43)),
                        _footerLink('Help & Support', () {
                          if (onHelpTap != null) {
                            onHelpTap!();
                          } else {
                            MainTabsScreen.of(context)?.setSelectedIndex(11);
                          }
                        }),
                      ],
                    ),
                    _buildColumn(
                      context,
                      title: 'Make Money with Us',
                      items: [
                        _footerLink('Sell Products (Shops)', () {
                          _executeProtectedAction(context, ref, onAuthenticated: () {
                            MainTabsScreen.of(context)?.navigateToCreateShop();
                          });
                        }),
                        _footerLink('Manage Properties', () {
                          _executeProtectedAction(context, ref, onAuthenticated: () {
                            MainTabsScreen.of(context)?.navigateToMyProperties();
                          });
                        }),
                        _footerLink('List Lodges & Hospitality', () {
                          _executeProtectedAction(context, ref, onAuthenticated: () {
                            MainTabsScreen.of(context)?.navigateToLodgeDashboard();
                          });
                        }),
                        _footerLink('Host Events & Tickets', () {
                          _executeProtectedAction(context, ref, onAuthenticated: () {
                            MainTabsScreen.of(context)?.navigateToManageEvents();
                          });
                        }),
                      ],
                    ),
                    _buildColumn(
                      context,
                      title: 'Platform Navigation',
                      items: [
                        _footerLink('Browse Products', () => MainTabsScreen.of(context)?.setSelectedIndex(2)),
                        _footerLink('Browse Shops', () => MainTabsScreen.of(context)?.setSelectedIndex(1)),
                        _footerLink('Confirm Delivery', () {
                          if (onDeliveryTap != null) {
                            onDeliveryTap!();
                          } else {
                            MainTabsScreen.of(context)?.setSelectedIndex(9);
                          }
                        }),
                        _footerLink('Scan Ticket Panel', () {
                          _executeProtectedAction(context, ref, onAuthenticated: () {
                            MainTabsScreen.of(context)?.setSelectedIndex(44);
                          });
                        }),
                      ],
                    ),
                    _buildColumn(
                      context,
                      title: 'Account & Legal',
                      items: [
                        _footerLink('Your Orders', () {
                          _executeProtectedAction(context, ref, onAuthenticated: () {
                            MainTabsScreen.of(context)?.navigateToOrders();
                          });
                        }),
                        _footerLink('Your Wallet & Payouts', () {
                          _executeProtectedAction(context, ref, onAuthenticated: () {
                            MainTabsScreen.of(context)?.navigateToWalletTransactions();
                          });
                        }),
                        _footerLink('Terms of Service', () => _launchUrl('terms/')),
                        _footerLink('Privacy Policy', () => _launchUrl('privacy/')),
                      ],
                    ),
                  ],
                ),

              const Padding(
                padding: EdgeInsets.symmetric(vertical: 32.0),
                child: Divider(thickness: 0.5, height: 1, color: Colors.white24),
              ),

              // ================= BRAND & PAYMENT SECTION =================
              Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Image.asset('assets/images/logo.png', height: 26),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'MalaTrade Marketplace',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                    ],
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
                  const SizedBox(height: 24),
                  const Text(
                    '© 2026 MalaTrade Marketplace. All rights reserved.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white54,
                      fontSize: 13,
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

  // ================= COLUMN BUILDER =================
  Widget _buildColumn(
    BuildContext context, {
    required String title,
    required List<Widget> items,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 15,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 14),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: items,
        ),
      ],
    );
  }

  // ================= LINK ITEM BUILDER =================
  Widget _footerLink(String text, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: InkWell(
        onTap: onTap,
        hoverColor: Colors.white10,
        borderRadius: BorderRadius.circular(4),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 2.0),
          child: Text(
            text,
            style: const TextStyle(
              color: Color(0xFFDDDDDD),
              fontSize: 13.5,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      ),
    );
  }

  // ================= PAYMENT LOGO BUILDER =================
  Widget _paymentLogo(String assetPath, String tooltip) {
    return Tooltip(
      message: tooltip,
      child: Container(
        width: 64,
        height: 38,
        padding: const EdgeInsets.all(4),
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
              child: Icon(Icons.credit_card, size: 20, color: Colors.grey[400]),
            );
          },
        ),
      ),
    );
  }
}