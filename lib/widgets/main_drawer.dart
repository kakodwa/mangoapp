// lib/widgets/main_drawer.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../screens/main_tabs_screen.dart';
import '../theme/app_colors.dart';
import '../services/analytics_service.dart';
import '../screens/products/product_constants.dart';

class MainDrawer extends ConsumerStatefulWidget {
  final VoidCallback? onAboutTap;
  final VoidCallback? onHelpTap;
  final VoidCallback? onDeliveryTap;

  const MainDrawer({
    super.key,
    this.onAboutTap,
    this.onHelpTap,
    this.onDeliveryTap,
  });

  @override
  ConsumerState<MainDrawer> createState() => _MainDrawerState();
}

class _MainDrawerState extends ConsumerState<MainDrawer> {
  static final AnalyticsService _analyticsService = AnalyticsService();

  Future<void> _launchUrl(String path) async {
    final Uri uri = Uri.parse('https://www.malatrade.com/$path');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Electronics':
        return Icons.devices_other;
      case 'Groceries':
        return Icons.local_grocery_store_outlined;
      case 'Fashion':
        return Icons.checkroom;
      case 'Home & Living':
        return Icons.home_outlined;
      case 'Beauty & Personal Care':
        return Icons.face_retouching_natural;
      case 'Health & Wellness':
        return Icons.health_and_safety_outlined;
      case 'Agriculture':
        return Icons.agriculture_outlined;
      case 'Vehicles':
        return Icons.directions_car_outlined;
      case 'Construction & Hardware':
        return Icons.handyman_outlined;
      case 'Books & Education':
        return Icons.menu_book_outlined;
      case 'Sports & Outdoors':
        return Icons.sports_basketball_outlined;
      case 'Baby & Kids':
        return Icons.child_friendly_outlined;
      case 'Food & Beverages':
        return Icons.fastfood_outlined;
      case 'Pets & Animals':
        return Icons.pets_outlined;
      case 'Office Supplies':
        return Icons.work_outline;
      case 'Entertainment':
        return Icons.theater_comedy_outlined;
      case 'Services':
        return Icons.miscellaneous_services_outlined;
      case 'Industrial Equipment':
        return Icons.precision_manufacturing_outlined;
      default:
        return Icons.category_outlined;
    }
  }

  /// Compact Flat Navigation Tile
  Widget _menuTile({
    required BuildContext context,
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return ListTile(
      dense: true,
      visualDensity: const VisualDensity(horizontal: -2, vertical: -3),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
      leading: Icon(icon, color: color, size: 20),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 13.5,
          fontWeight: FontWeight.w600,
          color: Color(0xFF1F2937),
        ),
      ),
      trailing: Icon(
        Icons.chevron_right,
        color: Colors.grey.shade400,
        size: 16,
      ),
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Drawer(
      backgroundColor: Colors.white,
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  // SLIM HEADER
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.only(
                      top: MediaQuery.of(context).padding.top + 8,
                      bottom: 8,
                      left: 16,
                      right: 16,
                    ),
                    decoration: const BoxDecoration(
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
                      child: Image.asset(
                        'assets/images/logo3.png',
                        height: 32,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),

                  // NATIVE CATEGORIES ACCORDION
                  Theme(
                    data: Theme.of(context).copyWith(
                      dividerColor: Colors.transparent,
                      visualDensity: const VisualDensity(vertical: -3),
                    ),
                    child: ExpansionTile(
                      dense: true,
                      iconColor: AppColors.mangoOrange,
                      collapsedIconColor: Colors.grey.shade600,
                      tilePadding: const EdgeInsets.symmetric(horizontal: 16),
                      leading: const Icon(
                        Icons.grid_view_rounded,
                        color: AppColors.mangoOrange,
                        size: 20,
                      ),
                      title: const Text(
                        "Categories",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1F2937),
                        ),
                      ),
                      children: ProductConstants.categories.map((category) {
                        final subCategoryMap =
                            ProductConstants.categorySubCategoryBrands[category] ?? {};
                        final subCategories = subCategoryMap.keys.toList();

                        return ExpansionTile(
                          dense: true,
                          visualDensity: const VisualDensity(vertical: -3),
                          tilePadding: const EdgeInsets.only(left: 28, right: 16),
                          leading: Icon(
                            _getCategoryIcon(category),
                            size: 18,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          title: Text(
                            category,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF374151),
                            ),
                          ),
                          children: subCategories.map((subCategory) {
                            return InkWell(
                              onTap: () {
                                _analyticsService.logEvent('drawer_subcategory_click_$subCategory');
                                Navigator.pop(context);

                                MainTabsScreen.of(context)?.setSelectedIndex(
                                  7,
                                  searchType: 'product',
                                  searchQuery: subCategory,
                                  category: category,
                                );
                              },
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.only(
                                  left: 54,
                                  right: 16,
                                  top: 8,
                                  bottom: 8,
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 4,
                                      height: 4,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors.grey.shade400,
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        subCategory,
                                        style: TextStyle(
                                          fontSize: 12.5,
                                          color: Colors.grey.shade700,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                    Icon(
                                      Icons.chevron_right,
                                      size: 14,
                                      color: Colors.grey.shade400,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        );
                      }).toList(),
                    ),
                  ),

                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    child: Divider(height: 1),
                  ),

                  // MAIN NAVIGATION
                  _menuTile(
                    context: context,
                    icon: Icons.map_outlined,
                    title: "Guide",
                    color: Colors.blue,
                    onTap: () {
                      _analyticsService.logEvent('drawer_guide_click');
                      Navigator.pop(context);
                      MainTabsScreen.of(context)?.setSelectedIndex(43);
                    },
                  ),

                  _menuTile(
                    context: context,
                    icon: Icons.local_shipping_outlined,
                    title: "Confirm Delivery",
                    color: Colors.orange,
                    onTap: () {
                      _analyticsService.logEvent('drawer_delivery_click');
                      Navigator.pop(context);
                      if (widget.onDeliveryTap != null) {
                        widget.onDeliveryTap!();
                      } else {
                        MainTabsScreen.of(context)?.setSelectedIndex(9);
                      }
                    },
                  ),

                  _menuTile(
                    context: context,
                    icon: Icons.qr_code_scanner_rounded,
                    title: "Scan Ticket",
                    color: Colors.purple,
                    onTap: () {
                      _analyticsService.logEvent('drawer_scan_ticket_click');
                      Navigator.pop(context);
                      MainTabsScreen.of(context)?.setSelectedIndex(44);
                    },
                  ),

                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    child: Divider(height: 1),
                  ),

                  _menuTile(
                    context: context,
                    icon: Icons.info_outline_rounded,
                    title: "About App",
                    color: AppColors.mangoOrange,
                    onTap: () {
                      _analyticsService.logEvent('drawer_about_click');
                      Navigator.pop(context);
                      if (widget.onAboutTap != null) {
                        widget.onAboutTap!();
                      } else {
                        MainTabsScreen.of(context)?.setSelectedIndex(10);
                      }
                    },
                  ),

                  _menuTile(
                    context: context,
                    icon: Icons.help_outline_rounded,
                    title: "Help Center",
                    color: AppColors.leafGreen,
                    onTap: () {
                      _analyticsService.logEvent('drawer_help_click');
                      Navigator.pop(context);
                      if (widget.onHelpTap != null) {
                        widget.onHelpTap!();
                      } else {
                        MainTabsScreen.of(context)?.setSelectedIndex(11);
                      }
                    },
                  ),

                  _menuTile(
                    context: context,
                    icon: Icons.description_outlined,
                    title: "Terms of Service",
                    color: Colors.teal,
                    onTap: () {
                      _analyticsService.logEvent('drawer_terms_click');
                      Navigator.pop(context);
                      _launchUrl('terms/');
                    },
                  ),

                  _menuTile(
                    context: context,
                    icon: Icons.privacy_tip_outlined,
                    title: "Privacy Policy",
                    color: Colors.indigo,
                    onTap: () {
                      _analyticsService.logEvent('drawer_privacy_click');
                      Navigator.pop(context);
                      _launchUrl('privacy/');
                    },
                  ),

                  const SizedBox(height: 12),
                ],
              ),
            ),

            // FOOTER
            Padding(
              padding: const EdgeInsets.only(bottom: 12, top: 4),
              child: Text(
                "Version 1.0.0",
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: colorScheme.onSurface.withOpacity(0.4),
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}