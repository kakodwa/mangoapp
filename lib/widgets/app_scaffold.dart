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
    final AnalyticsService analytics = AnalyticsService(); // Initialize tracking

    // SAFEGUARD: If the user selects any hidden screen (Index 6 Profile, Index 7 Search, etc.)
    // fallback the BottomNavigationBar highlight to index 0 so it doesn't crash out-of-bounds!
    final int navBarIndex = currentIndex > 5 ? 0 : currentIndex;

    return Scaffold(
      appBar: appBar,
      drawer: drawer,
      backgroundColor: backgroundColor,
      floatingActionButton: floatingActionButton,
      body: SafeArea(
        // Receives the IndexedStack containing all 8 elements seamlessly from parent file
        child: body ?? const SizedBox.shrink(), 
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: navBarIndex, // Uses the safe layout index
        // Dim selection focus highlighting completely when viewing a hidden view tab
        selectedItemColor: currentIndex > 5 
            ? colorScheme.onSurface.withOpacity(0.6) 
            : colorScheme.primary,
        unselectedItemColor: colorScheme.onSurface.withOpacity(0.6),
        showSelectedLabels: false,
        showUnselectedLabels: false,
        onTap: (index) {
          // 📊 TRACK EVENT: Map index to string label and log to Django backend asynchronously
          analytics.logEvent(_getTabEventName(index));

          // Trigger your original navigation routing function passed from parent widget
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
    );
  }
}