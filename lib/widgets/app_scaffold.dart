import 'package:flutter/material.dart';
import '../../services/analytics_service.dart'; // Import your analytics service layer

class AppScaffold extends StatelessWidget {
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

  // Helper method to convert the tab index to a clean analytical tag name
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
    
    // Web Responsive Breakpoint Flag
    final bool isDesktop = screenWidth >= 900;

    // SAFEGUARD: Fallback the Navigation highlight to index 0 if it goes out-of-bounds!
    final int navBarIndex = currentIndex > 5 ? 0 : currentIndex;

    return Scaffold(
      appBar: appBar,
      drawer: isDesktop ? null : drawer, // Disable side drawer if nav rail is actively displayed
      backgroundColor: backgroundColor,
      floatingActionButton: floatingActionButton,
      body: SafeArea(
        child: Row(
          children: [
            // --- WEB RESPONSIVE SIDE NAVIGATION RAIL ---
            if (isDesktop) ...[
              NavigationRail(
                selectedIndex: navBarIndex,
                elevation: 1,
                minWidth: 56,          
                minExtendedWidth: 180,
                backgroundColor: colorScheme.surface,
                selectedIconTheme: IconThemeData(color: colorScheme.primary),
                unselectedIconTheme: IconThemeData(color: colorScheme.onSurface.withOpacity(0.6)),
                // Dynamic expansion if ultra-wide viewport
                extended: screenWidth >= 1200,
                // Removed the MangoHub text header block here and replaced with clean top padding spacing
                leading: const SizedBox(height: 16.0),
                onDestinationSelected: (index) {
                  analytics.logEvent(_getTabEventName(index));
                  if (onTabSelected != null) {
                    onTabSelected!(index);
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
              //const VerticalDivider(thickness: 1, width: 1),
            ],

            // Content Panel area housing viewport page components
            Expanded(
              child: body ?? const SizedBox.shrink(),
            ),
          ],
        ),
      ),
      
      // --- MOBILE BOTTOM NAVIGATION BAR ---
      bottomNavigationBar: isDesktop
          ? null
          : _ScrollingBottomNavBarWrapper(
              child: BottomNavigationBar(
                type: BottomNavigationBarType.fixed,
                currentIndex: navBarIndex, 
                selectedItemColor: currentIndex > 5 
                    ? colorScheme.onSurface.withOpacity(0.6) 
                    : colorScheme.primary,
                unselectedItemColor: colorScheme.onSurface.withOpacity(0.6),
                showSelectedLabels: false,
                showUnselectedLabels: false,
                onTap: (index) {
                  analytics.logEvent(_getTabEventName(index));
                  if (onTabSelected != null) {
                    onTabSelected!(index);
                  }
                },
                items: const [
                  BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home', tooltip: 'Home'),
                  BottomNavigationBarItem(icon: Icon(Icons.store), label: 'Shops', tooltip: 'Shops'),
                  BottomNavigationBarItem(icon: Icon(Icons.shopping_cart), label: 'Products', tooltip: 'Products'),
                  BottomNavigationBarItem(icon: Icon(Icons.home_work), label: 'Properties', tooltip: 'Properties'),
                  BottomNavigationBarItem(icon: Icon(Icons.event), label: 'Events', tooltip: 'Events'),
                  BottomNavigationBarItem(icon: Icon(Icons.hotel), label: 'Booking', tooltip: 'Booking'),
                ],
              ),
            ),
    );
  }
}

/// Helper stateful wrapper that catches scroll notifications from the body and hides the bar
class _ScrollingBottomNavBarWrapper extends StatefulWidget {
  final Widget child;
  const _ScrollingBottomNavBarWrapper({required this.child});

  @override
  State<_ScrollingBottomNavBarWrapper> createState() => _ScrollingBottomNavBarWrapperState();
}

class _ScrollingBottomNavBarWrapperState extends State<_ScrollingBottomNavBarWrapper> {
  bool _isVisible = true;

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (notification is ScrollUpdateNotification) {
          // Detect user scrolling down vs up
          if (notification.scrollDelta! > 2.0 && _isVisible) {
            setState(() => _isVisible = false); 
          } else if (notification.scrollDelta! < -2.0 && !_isVisible) {
            setState(() => _isVisible = true); 
          }
        }
        return false; // Don't block the notification from bubbling up
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        height: _isVisible ? kBottomNavigationBarHeight + MediaQuery.of(context).padding.bottom : 0,
        child: Wrap( 
          children: [widget.child],
        ),
      ),
    );
  }
}