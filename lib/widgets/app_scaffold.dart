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

    // SAFEGUARD: Fallback the BottomNavigationBar highlight to index 0 if it goes out-of-bounds!
    final int navBarIndex = currentIndex > 5 ? 0 : currentIndex;

    return Scaffold(
      appBar: appBar,
      drawer: drawer,
      backgroundColor: backgroundColor,
      floatingActionButton: floatingActionButton,
      body: SafeArea(
        child: body ?? const SizedBox.shrink(), 
      ),
      // Wrapped in our scroll-animation listener to hide it dynamically
      bottomNavigationBar: _ScrollingBottomNavBarWrapper(
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
        return false; // Don't block the notification from bubble up
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