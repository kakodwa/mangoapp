import 'package:flutter/material.dart';
import '../../services/analytics_service.dart';
import '../../screens/products/product_constants.dart';
import '../screens/main_tabs_screen.dart';
import 'web_footer.dart';

class AppScaffold extends StatefulWidget {
  final Widget? body;
  final PreferredSizeWidget? appBar;
  final Widget? drawer;
  final int currentIndex;
  final Color? backgroundColor;
  final Widget? floatingActionButton;
  final ValueChanged<int>? onTabSelected;

  const AppScaffold({
    super.key,
    this.body,
    this.appBar,
    this.drawer,
    this.currentIndex = 0,
    this.backgroundColor,
    this.floatingActionButton,
    this.onTabSelected,
  });

  @override
  State<AppScaffold> createState() => _AppScaffoldState();
}

class _AppScaffoldState extends State<AppScaffold> {
  bool _isNavBarVisible = true;
  double _scrollDistance = 0.0;
  
  // Selected Category State for Desktop Left Categories Panel
  String? _selectedCategory;

  String _getTabEventName(int index) {
    switch (index) {
      case 0:
        return 'nav_tab_home';
      case 1:
        return 'nav_tab_shops';
      case 2:
        return 'nav_tab_products';
      default:
        return 'nav_tab_unknown';
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final AnalyticsService analytics = AnalyticsService();
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isDesktop = screenWidth >= 900;

    const int mobileItemCount = 3;
    final int navBarIndex =
        (widget.currentIndex < 0 || widget.currentIndex >= mobileItemCount)
            ? 0
            : widget.currentIndex;

    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (isDesktop) return false;

        if (notification.metrics.pixels <= 10) {
          if (!_isNavBarVisible) {
            setState(() {
              _isNavBarVisible = true;
              _scrollDistance = 0.0;
            });
          }
          return false;
        }

        if (notification is ScrollEndNotification) {
          _scrollDistance = 0.0;
          return false;
        }

        if (notification is ScrollUpdateNotification) {
          final delta = notification.scrollDelta ?? 0.0;
          if ((delta > 0 && _scrollDistance < 0) ||
              (delta < 0 && _scrollDistance > 0)) {
            _scrollDistance = 0.0;
          }
          _scrollDistance += delta;

          if (_scrollDistance > 45.0 && _isNavBarVisible) {
            setState(() {
              _isNavBarVisible = false;
              _scrollDistance = 0.0;
            });
          } else if (_scrollDistance < -10.0 && !_isNavBarVisible) {
            setState(() {
              _isNavBarVisible = true;
              _scrollDistance = 0.0;
            });
          }
        }
        return false;
      },
      child: Scaffold(
        appBar: widget.appBar,
        drawer: isDesktop ? null : widget.drawer,
        backgroundColor: widget.backgroundColor ?? Colors.grey.shade50,
        floatingActionButton: widget.floatingActionButton,
        body: SafeArea(
          bottom: false,
          child: isDesktop
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // DESKTOP LEFT CATEGORIES SIDEBAR
                    Container(
                      width: 260,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border(
                          right: BorderSide(
                            color: Colors.grey.shade200,
                            width: 1,
                          ),
                        ),
                      ),
                      child: _selectedCategory == null
                          ? _buildPrimaryCategoriesList(context)
                          : _buildSubCategoriesList(context, _selectedCategory!),
                    ),

                    // MAIN CONTENT AREA (DIRECT EXPANDED BODY)
                    Expanded(
                      child: widget.body ?? const SizedBox.shrink(),
                    ),
                  ],
                )
              : Stack(
                  children: [
                    Positioned.fill(
                      child: widget.body ?? const SizedBox.shrink(),
                    ),

                    // Floating Navigation Bar (Mobile View Only)
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: AnimatedSlide(
                        duration: const Duration(milliseconds: 200),
                        curve: Curves.easeOutCubic,
                        offset: _isNavBarVisible
                            ? Offset.zero
                            : const Offset(0, 1.5),
                        child: _buildFloatingNavBar(
                          context,
                          colorScheme,
                          navBarIndex,
                          analytics,
                        ),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  // Desktop Primary Categories List Widget
  Widget _buildPrimaryCategoriesList(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          color: Theme.of(context).colorScheme.primary.withOpacity(0.08),
          child: Row(
            children: [
              Icon(Icons.category_rounded, size: 18, color: Theme.of(context).colorScheme.primary),
              const SizedBox(width: 8),
              Text(
                'Categories',
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
          child: ListView.separated(
            itemCount: ProductConstants.categories.length,
            separatorBuilder: (_, __) => Divider(height: 1, color: Colors.grey.shade100),
            itemBuilder: (context, index) {
              final category = ProductConstants.categories[index];
              return ListTile(
                dense: true,
                visualDensity: VisualDensity.compact,
                title: Text(
                  category,
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                ),
                trailing: const Icon(Icons.chevron_right, size: 18, color: Colors.grey),
                onTap: () {
                  setState(() {
                    _selectedCategory = category;
                  });
                },
              );
            },
          ),
        ),
      ],
    );
  }

  // Desktop Subcategories List Widget
  Widget _buildSubCategoriesList(BuildContext context, String parentCategory) {
    final subCategoryMap = ProductConstants.categorySubCategoryBrands[parentCategory] ?? {};
    final subCategories = subCategoryMap.keys.toList();
    final AnalyticsService analytics = AnalyticsService();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.08),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, size: 18),
                onPressed: () {
                  setState(() {
                    _selectedCategory = null;
                  });
                },
              ),
              Expanded(
                child: Text(
                  parentCategory,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: subCategories.isEmpty
              ? Center(
                  child: TextButton(
                    onPressed: () {
                      MainTabsScreen.of(context)?.setSelectedIndex(
                        7,
                        searchType: 'product',
                        category: parentCategory,
                      );
                    },
                    child: Text("Explore $parentCategory"),
                  ),
                )
              : ListView.separated(
                  itemCount: subCategories.length,
                  separatorBuilder: (_, __) => Divider(height: 1, color: Colors.grey.shade100),
                  itemBuilder: (context, index) {
                    final subCategory = subCategories[index];
                    return ListTile(
                      dense: true,
                      visualDensity: VisualDensity.compact,
                      title: Text(
                        subCategory,
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w400),
                      ),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 12, color: Colors.grey),
                      onTap: () {
                        analytics.logEvent('click_desktop_subcategory_$subCategory');
                        
                        MainTabsScreen.of(context)?.setSelectedIndex(
                          7,
                          searchType: 'product',
                          searchQuery: subCategory,
                          category: parentCategory,
                        );
                      },
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildFloatingNavBar(
    BuildContext context,
    ColorScheme colorScheme,
    int navBarIndex,
    AnalyticsService analytics,
  ) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.only(left: 20, right: 20, bottom: 12),
        child: Container(
          height: 64,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(32),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.12),
                blurRadius: 20,
                spreadRadius: 2,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildPillNavItem(
                index: 0,
                icon: Icons.home_outlined,
                activeIcon: Icons.home_rounded,
                label: 'Home',
                currentIndex: navBarIndex,
                analytics: analytics,
              ),
              _buildPillNavItem(
                index: 1,
                icon: Icons.storefront_outlined,
                activeIcon: Icons.storefront_rounded,
                label: 'Shops',
                currentIndex: navBarIndex,
                analytics: analytics,
              ),
              _buildPillNavItem(
                index: 2,
                icon: Icons.shopping_bag_outlined,
                activeIcon: Icons.shopping_bag_rounded,
                label: 'Products',
                currentIndex: navBarIndex,
                analytics: analytics,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPillNavItem({
    required int index,
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required int currentIndex,
    required AnalyticsService analytics,
  }) {
    final isSelected = index == currentIndex;
    final primaryColor = Theme.of(context).colorScheme.primary;

    return GestureDetector(
      onTap: () {
        analytics.logEvent(_getTabEventName(index));
        if (widget.onTabSelected != null) {
          widget.onTabSelected!(index);
        }
      },
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? primaryColor.withOpacity(0.12) : Colors.transparent,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? activeIcon : icon,
              color: isSelected ? primaryColor : Colors.grey.shade600,
              size: 22,
            ),
            if (isSelected) ...[
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: primaryColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}