import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/auth_provider.dart';
import '../providers/products_provider.dart';
import '../models/product_model.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/main_tabs_screen.dart';
import '../screens/products/product_constants.dart';
import '../services/analytics_service.dart';

class MainAppBar extends ConsumerWidget implements PreferredSizeWidget {
  final VoidCallback? onProfileTap;
  final VoidCallback? onSearchTap;
  final VoidCallback? onCartTap;
  final VoidCallback? onDeliveryTap;
  final Widget? title;
  final Widget? leading;

  static final AnalyticsService _analyticsService = AnalyticsService();

  const MainAppBar({
    super.key,
    this.title,
    this.onProfileTap,
    this.onSearchTap,
    this.onCartTap,
    this.onDeliveryTap,
    this.leading,
  });

  /// Reliable navigation helper to switch tabs on desktop and mobile
  void _navigateToHome(BuildContext context) {
    _analyticsService.logEvent('appbar_logo_click_home');

    final tabsState = MainTabsScreen.of(context);
    if (tabsState != null) {
      tabsState.setSelectedIndex(0);
    } else {
      // Fallback: If inherited widget isn't found in tree, pop to root or push MainTabsScreen
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const MainTabsScreen()),
        (route) => false,
      );
    }
  }

  void _showCategoriesMegaMenu(BuildContext parentContext) {
    showGeneralDialog(
      context: parentContext,
      barrierDismissible: true,
      barrierLabel: 'CategoriesMegaMenu',
      barrierColor: Colors.black45,
      transitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (dialogContext, animation, secondaryAnimation) {
        return Align(
          alignment: Alignment.topCenter,
          child: Padding(
            padding: const EdgeInsets.only(top: kToolbarHeight + 12),
            child: Material(
              color: Colors.transparent,
              child: Container(
                constraints: const BoxConstraints(maxWidth: 1100),
                width: MediaQuery.of(parentContext).size.width * 0.9,
                height: 540,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 24,
                      spreadRadius: 4,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: _CategoryMegaMenuView(parentContext: parentContext),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartItems = ref.watch(cartProvider);
    final authState = ref.watch(authProvider);
    final isLoggedIn = authState.isAuthenticated;
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isDesktop = screenWidth >= 900;

    return PreferredSize(
      preferredSize: const Size.fromHeight(kToolbarHeight),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          border: Border(bottom: BorderSide(color: Colors.grey.shade200, width: 1)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: AppBar(
          centerTitle: false,
          elevation: 0,
          backgroundColor: Colors.transparent,
          titleSpacing: 0,
          automaticallyImplyLeading: leading == null ? !isDesktop : false,
          leading: leading,
          // GUARANTEED CLICKABLE LOGO FOR HOME NAVIGATION
          title: title ??
              MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => _navigateToHome(context),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
                    child: Image.asset(
                      'assets/images/logo.png',
                      height: 32,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
          actions: [
            if (isDesktop) ...[
              // CATEGORIES TEXT BUTTON
              TextButton.icon(
                icon: const Icon(Icons.category_rounded, size: 18),
                label: const Text('Categories', style: TextStyle(fontWeight: FontWeight.w600)),
                onPressed: () {
                  _analyticsService.logEvent('appbar_categories_click');
                  _showCategoriesMegaMenu(context);
                },
              ),
              TextButton(
                onPressed: () => MainTabsScreen.of(context)?.setSelectedIndex(1),
                child: const Text('Shops', style: TextStyle(fontWeight: FontWeight.w600, color: Colors.black87)),
              ),
              TextButton(
                onPressed: () => MainTabsScreen.of(context)?.setSelectedIndex(2),
                child: const Text('Products', style: TextStyle(fontWeight: FontWeight.w600, color: Colors.black87)),
              ),
              TextButton(
                onPressed: () {
                  _analyticsService.logEvent('appbar_delivery_click');
                  if (onDeliveryTap != null) {
                    onDeliveryTap!();
                  } else {
                    MainTabsScreen.of(context)?.setSelectedIndex(9);
                  }
                },
                child: const Text('Confirm Delivery', style: TextStyle(fontWeight: FontWeight.w600, color: Colors.black87)),
              ),
              TextButton(
                onPressed: () {
                  _analyticsService.logEvent('appbar_help_click');
                  MainTabsScreen.of(context)?.setSelectedIndex(11);
                },
                child: const Text('Help Center', style: TextStyle(fontWeight: FontWeight.w600, color: Colors.black87)),
              ),
              const SizedBox(width: 12),

              // SEARCH BAR
              Container(
                width: 240,
                height: 38,
                margin: const EdgeInsets.only(right: 12),
                child: TextField(
                  readOnly: true,
                  onTap: () {
                    _analyticsService.logEvent('appbar_search_click');
                    onSearchTap?.call();
                  },
                  decoration: InputDecoration(
                    hintText: 'Search platform...',
                    hintStyle: const TextStyle(fontSize: 13),
                    prefixIcon: const Icon(Icons.search, size: 18),
                    contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
                    filled: true,
                    fillColor: Colors.grey.shade100,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
            ] else ...[
              IconButton(
                icon: const Icon(Icons.category_outlined),
                tooltip: 'Categories',
                onPressed: () {
                  _analyticsService.logEvent('appbar_categories_click');
                  _showCategoriesMegaMenu(context);
                },
              ),
              IconButton(
                icon: const Icon(Icons.search_rounded),
                tooltip: 'Search Platform',
                onPressed: () {
                  _analyticsService.logEvent('appbar_search_click');
                  onSearchTap?.call();
                },
              ),
            ],

            // SHOPPING CART BUTTON
            Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.shopping_cart_outlined),
                  onPressed: () {
                    _analyticsService.logEvent('appbar_cart_click');
                    onCartTap?.call();
                  },
                  tooltip: 'Shopping Cart',
                ),
                if (cartItems.isNotEmpty)
                  Positioned(
                    right: 4,
                    top: 4,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '${cartItems.length}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 8),

            // AUTH ACTION BUTTONS
            if (isDesktop) ...[
              if (!isLoggedIn) ...[
                TextButton(
                  onPressed: () => _handleAuthNavigation(context, 'login'),
                  child: const Text('Login', style: TextStyle(fontWeight: FontWeight.w600, color: Colors.black87)),
                ),
                const SizedBox(width: 4),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                  onPressed: () => _handleAuthNavigation(context, 'register'),
                  child: const Text('Register', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ] else ...[
                TextButton.icon(
                  icon: const Icon(Icons.account_circle, size: 22),
                  label: const Text('Profile', style: TextStyle(fontWeight: FontWeight.w600, color: Colors.black87)),
                  onPressed: () => _handleAuthNavigation(context, 'profile'),
                ),
                const SizedBox(width: 4),
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                  onPressed: () => _handleAuthNavigation(context, 'logout', ref: ref),
                  child: const Text('Logout'),
                ),
              ],
            ] else ...[
              PopupMenuButton<String>(
                offset: const Offset(0, 45),
                onSelected: (value) => _handleAuthNavigation(context, value, ref: ref),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
                  child: isLoggedIn
                      ? const Icon(Icons.account_circle, size: 28)
                      : Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.person_outline_rounded,
                                  size: 16, color: Theme.of(context).colorScheme.primary),
                              const SizedBox(width: 4),
                              Text(
                                'Login',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                ),
                itemBuilder: (_) => !isLoggedIn
                    ? const [
                        PopupMenuItem(value: 'login', child: Text('Login')),
                        PopupMenuItem(value: 'register', child: Text('Register')),
                      ]
                    : const [
                        PopupMenuItem(value: 'profile', child: Text('Profile')),
                        PopupMenuItem(value: 'logout', child: Text('Logout')),
                      ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _handleAuthNavigation(BuildContext context, String destination, {WidgetRef? ref}) async {
    _analyticsService.logEvent('appbar_${destination}_click');
    switch (destination) {
      case 'login':
        Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
        break;
      case 'register':
        Navigator.push(context, MaterialPageRoute(builder: (_) => const RegisterScreen()));
        break;
      case 'profile':
        onProfileTap?.call();
        break;
      case 'logout':
        if (ref != null) {
          await ref.read(authProvider.notifier).logout();
          if (context.mounted) {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const LoginScreen()),
              (route) => false,
            );
          }
        }
        break;
    }
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _CategoryMegaMenuView extends ConsumerStatefulWidget {
  final BuildContext parentContext;

  const _CategoryMegaMenuView({required this.parentContext});

  @override
  ConsumerState<_CategoryMegaMenuView> createState() => _CategoryMegaMenuViewState();
}

class _CategoryMegaMenuViewState extends ConsumerState<_CategoryMegaMenuView> {
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
    final productsAsync = ref.watch(productsProvider);
    final List<Product> availableProducts = productsAsync.valueOrNull ?? [];
    
    final subCategoryImages = _buildSubCategoryImageMap(availableProducts);

    final subCategoryMap =
        ProductConstants.categorySubCategoryBrands[_selectedCategory] ?? {};
    final subCategories = subCategoryMap.keys.toList();

    return Row(
      children: [
        // LEFT NAVIGATION SIDEBAR
        Container(
          width: 280,
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            border: Border(right: BorderSide(color: Colors.grey.shade200)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                color: Theme.of(context).colorScheme.primary.withOpacity(0.08),
                child: Row(
                  children: [
                    Icon(Icons.category_rounded,
                        size: 18, color: Theme.of(context).colorScheme.primary),
                    const SizedBox(width: 8),
                    Text(
                      'All Categories',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
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
                        padding:
                            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        color: isSelected ? Colors.white : Colors.transparent,
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                category,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight:
                                      isSelected ? FontWeight.bold : FontWeight.w500,
                                  color: isSelected
                                      ? Theme.of(context).colorScheme.primary
                                      : Colors.black87,
                                ),
                              ),
                            ),
                            Icon(
                              Icons.chevron_right_rounded,
                              size: 18,
                              color: isSelected
                                  ? Theme.of(context).colorScheme.primary
                                  : Colors.grey,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),

        // RIGHT SUBCATEGORIES GRID PANEL
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                decoration: BoxDecoration(
                  border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _selectedCategory,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, size: 22),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: subCategories.isEmpty
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
                    : Padding(
                        padding: const EdgeInsets.all(20),
                        child: GridView.builder(
                          gridDelegate:
                              const SliverGridDelegateWithMaxCrossAxisExtent(
                            maxCrossAxisExtent: 140,
                            mainAxisSpacing: 16,
                            crossAxisSpacing: 16,
                            childAspectRatio: 0.85,
                          ),
                          itemCount: subCategories.length,
                          itemBuilder: (context, index) {
                            final subCategory = subCategories[index];
                            final imageUrl = subCategoryImages[subCategory.trim().toLowerCase()];

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
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Colors.grey.shade200),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      width: 58,
                                      height: 58,
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
                                                  size: 24,
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .primary,
                                                ),
                                              )
                                            : Icon(
                                                Icons.grid_view_rounded,
                                                size: 24,
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .primary,
                                              ),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      subCategory,
                                      textAlign: TextAlign.center,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}