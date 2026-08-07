// lib/widgets/main_drawer.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../screens/main_tabs_screen.dart';
import '../theme/app_colors.dart';
import '../services/analytics_service.dart';
import '../screens/products/product_constants.dart';
import '../providers/products_provider.dart';
import '../models/product_model.dart';

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

  void _showCategoriesMegaMenu(BuildContext parentContext) {
    _analyticsService.logEvent('drawer_mega_menu_open');
    Navigator.pop(parentContext); // Close drawer first

    showGeneralDialog(
      context: parentContext,
      barrierDismissible: true,
      barrierLabel: 'CategoriesMegaMenu',
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (dialogContext, animation, secondaryAnimation) {
        return Align(
          alignment: Alignment.center,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 32),
            child: Material(
              color: Colors.transparent,
              child: Container(
                constraints: const BoxConstraints(maxWidth: 1100, maxHeight: 600),
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.25),
                      blurRadius: 24,
                      spreadRadius: 4,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: _DrawerCategoryMegaMenuView(parentContext: parentContext),
                ),
              ),
            ),
          ),
        );
      },
    );
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
                  // SLIM & TIGHT HEADER
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

                  // CATEGORIES ACCORDION & MEGA MENU TRIGGER
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
                      children: [
                        // MEGA MENU POPUP TRIGGER BUTTON FOR MOBILE/DESKTOP
                        InkWell(
                          onTap: () => _showCategoriesMegaMenu(context),
                          child: Container(
                            width: double.infinity,
                            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: AppColors.mangoOrange.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: AppColors.mangoOrange.withOpacity(0.3)),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.auto_awesome, size: 16, color: AppColors.mangoOrange),
                                SizedBox(width: 8),
                                Text(
                                  "Open Category Mega Menu",
                                  style: TextStyle(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.mangoOrange,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        ...ProductConstants.categories.map((category) {
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
                      ],
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

/// MOBILE & DESKTOP RESPONSIVE CATEGORY MEGA MENU VIEW
class _DrawerCategoryMegaMenuView extends ConsumerStatefulWidget {
  final BuildContext parentContext;

  const _DrawerCategoryMegaMenuView({required this.parentContext});

  @override
  ConsumerState<_DrawerCategoryMegaMenuView> createState() =>
      _DrawerCategoryMegaMenuViewState();
}

class _DrawerCategoryMegaMenuViewState
    extends ConsumerState<_DrawerCategoryMegaMenuView> {
  late String _selectedCategory;
  final AnalyticsService _analytics = AnalyticsService();

  @override
  void initState() {
    super.initState();
    _selectedCategory = ProductConstants.categories.isNotEmpty
        ? ProductConstants.categories.first
        : '';
  }

  Map<String, String> _buildSubCategoryImageMap(List<Product> products) {
    final Map<String, String> imageMap = {};

    for (final product in products) {
      final subCatKey = product.subCategory.trim().toLowerCase();
      if (subCatKey.isNotEmpty && !imageMap.containsKey(subCatKey)) {
        if (product.hasImage) {
          imageMap[subCatKey] = product.safeImage;
        } else if (product.images.isNotEmpty) {
          imageMap[subCatKey] = product.images.first;
        }
      }
    }
    return imageMap;
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isMobile = screenWidth < 600;

    final productsAsync = ref.watch(productsProvider);
    final List<Product> availableProducts = productsAsync.valueOrNull ?? [];
    final subCategoryImages = _buildSubCategoryImageMap(availableProducts);

    final subCategoryMap =
        ProductConstants.categorySubCategoryBrands[_selectedCategory] ?? {};
    final subCategories = subCategoryMap.keys.toList();

    Widget categoryList = ListView.builder(
      itemCount: ProductConstants.categories.length,
      itemBuilder: (context, index) {
        final category = ProductConstants.categories[index];
        final isSelected = category == _selectedCategory;

        return InkWell(
          onTap: () {
            setState(() {
              _selectedCategory = category;
            });
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            color: isSelected ? Colors.white : Colors.transparent,
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    category,
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                      color: isSelected
                          ? Theme.of(context).colorScheme.primary
                          : Colors.black87,
                    ),
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  size: 16,
                  color: isSelected
                      ? Theme.of(context).colorScheme.primary
                      : Colors.grey,
                ),
              ],
            ),
          ),
        );
      },
    );

    Widget subCategoryGrid = subCategories.isEmpty
        ? Center(
            child: ElevatedButton(
              onPressed: () {
                MainTabsScreen.of(widget.parentContext)?.setSelectedIndex(
                  7,
                  searchType: 'product',
                  category: _selectedCategory,
                );
                Navigator.pop(context);
              },
              child: Text("Browse $_selectedCategory"),
            ),
          )
        : GridView.builder(
            padding: const EdgeInsets.all(12),
            gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: isMobile ? 110 : 140,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 0.82,
            ),
            itemCount: subCategories.length,
            itemBuilder: (context, index) {
              final subCategory = subCategories[index];
              final imageUrl =
                  subCategoryImages[subCategory.trim().toLowerCase()];

              return InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () {
                  _analytics.logEvent(
                      'click_megamenu_subcategory_$subCategory');
                  MainTabsScreen.of(widget.parentContext)?.setSelectedIndex(
                    7,
                    searchType: 'product',
                    searchQuery: subCategory,
                    category: _selectedCategory,
                  );
                  Navigator.pop(context);
                },
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: isMobile ? 46 : 56,
                        height: isMobile ? 46 : 56,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.grey.shade100,
                        ),
                        child: ClipOval(
                          child: imageUrl != null && imageUrl.isNotEmpty
                              ? Image.network(
                                  imageUrl,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Icon(
                                    Icons.grid_view_rounded,
                                    size: 22,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .primary,
                                  ),
                                )
                              : Icon(
                                  Icons.grid_view_rounded,
                                  size: 22,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        subCategory,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );

    return Column(
      children: [
        // MODAL TOP HEADER BAR
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.08),
            border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.category_rounded,
                      size: 20, color: Theme.of(context).colorScheme.primary),
                  const SizedBox(width: 8),
                  Text(
                    'Category Mega Menu',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded, size: 22),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        ),

        // CONTENT BODY (LAYOUT ADAPTS FOR MOBILE & DESKTOP)
        Expanded(
          child: isMobile
              ? Column(
                  children: [
                    // TOP HORIZONTAL CATEGORY SCROLLER FOR MOBILE
                    SizedBox(
                      height: 42,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: ProductConstants.categories.length,
                        itemBuilder: (context, index) {
                          final category = ProductConstants.categories[index];
                          final isSelected = category == _selectedCategory;

                          return Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 4, vertical: 4),
                            child: ChoiceChip(
                              label: Text(
                                category,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                  color: isSelected
                                      ? Colors.white
                                      : Colors.black87,
                                ),
                              ),
                              selected: isSelected,
                              selectedColor:
                                  Theme.of(context).colorScheme.primary,
                              onSelected: (_) {
                                setState(() {
                                  _selectedCategory = category;
                                });
                              },
                            ),
                          );
                        },
                      ),
                    ),
                    const Divider(height: 1),
                    Expanded(child: subCategoryGrid),
                  ],
                )
              : Row(
                  children: [
                    Container(
                      width: 220,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        border: Border(
                            right: BorderSide(color: Colors.grey.shade200)),
                      ),
                      child: categoryList,
                    ),
                    Expanded(child: subCategoryGrid),
                  ],
                ),
        ),
      ],
    );
  }
}