import 'package:flutter/material.dart';
import '../../services/analytics_service.dart';

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

  String _getTabEventName(int index) {
    switch (index) {
      case 0: return 'nav_tab_home';
      case 1: return 'nav_tab_shops';
      case 2: return 'nav_tab_products';
      case 3: return 'nav_tab_properties';
      case 4: return 'nav_tab_events';
      case 5: return 'nav_tab_booking';
      default: return 'nav_tab_unknown';
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final AnalyticsService analytics = AnalyticsService(); 
    final double screenWidth = MediaQuery.of(context).size.width;
    
    final bool isDesktop = screenWidth >= 900;

    const int mobileItemCount = 3;
    final int navBarIndex = (widget.currentIndex < 0 || widget.currentIndex >= mobileItemCount) 
        ? 0 
        : widget.currentIndex;

    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        // 1. Force show when near top of page
        if (notification.metrics.pixels <= 10) {
          if (!_isNavBarVisible) {
            setState(() {
              _isNavBarVisible = true;
              _scrollDistance = 0.0;
            });
          }
          return false;
        }

        // 2. Ignore small scroll bounces when user stops dragging (Pointer Up)
        if (notification is ScrollEndNotification) {
          _scrollDistance = 0.0;
          return false;
        }

        // 3. Process deliberate scroll updates
        if (notification is ScrollUpdateNotification) {
          final delta = notification.scrollDelta ?? 0.0;

          // Reset distance when changing scroll direction
          if ((delta > 0 && _scrollDistance < 0) || (delta < 0 && _scrollDistance > 0)) {
            _scrollDistance = 0.0;
          }

          _scrollDistance += delta;

          // Require a larger deliberate swipe DOWN (> 45px) to hide
          if (_scrollDistance > 45.0 && _isNavBarVisible) {
            setState(() {
              _isNavBarVisible = false;
              _scrollDistance = 0.0;
            });
          } 
          // Re-show easily on a gentle pull UP (< -10px)
          else if (_scrollDistance < -10.0 && !_isNavBarVisible) {
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
        backgroundColor: widget.backgroundColor,
        floatingActionButton: widget.floatingActionButton,
        body: Stack(
          children: [
            // Main Content Layer
            Positioned.fill(
              child: SafeArea(
                bottom: false,
                child: Row(
                  children: [
                    if (isDesktop) ...[
                      NavigationRail(
                        selectedIndex: widget.currentIndex > 5 ? 0 : widget.currentIndex,
                        elevation: 1,
                        minWidth: 56,          
                        minExtendedWidth: 180,
                        backgroundColor: colorScheme.surface,
                        selectedIconTheme: IconThemeData(color: colorScheme.primary),
                        unselectedIconTheme: IconThemeData(color: colorScheme.onSurface.withOpacity(0.6)),
                        extended: screenWidth >= 1200,
                        leading: const SizedBox(height: 16.0),
                        onDestinationSelected: (index) {
                          analytics.logEvent(_getTabEventName(index));
                          if (widget.onTabSelected != null) {
                            widget.onTabSelected!(index);
                          }
                        },
                        destinations: const [
                          NavigationRailDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: Text('Home')),
                          NavigationRailDestination(icon: Icon(Icons.store_outlined), selectedIcon: Icon(Icons.store), label: Text('Shops')),
                          NavigationRailDestination(icon: Icon(Icons.shopping_cart_outlined), selectedIcon: Icon(Icons.shopping_cart), label: Text('Products')),
                          NavigationRailDestination(icon: Icon(Icons.home_work_outlined), selectedIcon: Icon(Icons.home_work), label: Text('Properties')),
                          NavigationRailDestination(icon: Icon(Icons.event_outlined), selectedIcon: Icon(Icons.event), label: Text('Events')),
                          NavigationRailDestination(icon: Icon(Icons.hotel_outlined), selectedIcon: Icon(Icons.hotel), label: Text('Booking')),
                        ],
                      ),
                    ],

                    Expanded(
                      child: widget.body ?? const SizedBox.shrink(),
                    ),
                  ],
                ),
              ),
            ),

            // Floating Navigation Bar Overlay (Mobile Only)
            if (!isDesktop)
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: AnimatedSlide(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeOutCubic,
                  offset: _isNavBarVisible ? Offset.zero : const Offset(0, 1.5),
                  child: _buildFloatingNavBar(context, colorScheme, navBarIndex, analytics),
                ),
              ),
          ],
        ),
      ),
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