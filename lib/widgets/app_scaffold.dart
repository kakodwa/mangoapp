import 'package:flutter/material.dart';

import '../screens/home/home_screen.dart';
import '../screens/shops/feed_shops_list_screen.dart';
import '../screens/products/feed_products_list_screen.dart';
import '../screens/properties/feed_properties_list_screen.dart';
import '../screens/events/feed_event_list_screen.dart';
import '../screens/hospitality/feed_lodge_list_screen.dart';

class AppScaffold extends StatelessWidget {
  final Widget? body; // Made optional since IndexedStack handles the body now
  final PreferredSizeWidget? appBar;
  final Widget? drawer;
  final int currentIndex;
  final Color? backgroundColor;
  final Widget? floatingActionButton;
  final ValueChanged<int>? onTabSelected; // Added callback to pass index back to parent

  const AppScaffold({
    super.key,
    this.body,
    this.appBar,
    this.drawer,
    this.currentIndex = 0,
    this.backgroundColor,
    this.floatingActionButton,
    this.onTabSelected, // Pass this from your parent stateful widget
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    // List of screens to keep alive in the background
    final List<Widget> screens = [
      HomeScreen(),
      ShopsListScreen(),
      ProductsListScreen(),
      PropertiesListScreen(),
      EventListScreen(),
      LodgeListScreen(),
    ];

    return Scaffold(
      appBar: appBar,
      drawer: drawer,
      backgroundColor: backgroundColor,
      floatingActionButton: floatingActionButton,

      // --- IndexedStack preserves screen state and scroll positions ---
      body: SafeArea(
        child: body ?? IndexedStack(
          index: currentIndex,
          children: screens,
        ),
      ),

      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: currentIndex,
        selectedItemColor: colorScheme.primary,
        unselectedItemColor: colorScheme.onSurface.withOpacity(0.6),
        showSelectedLabels: false,
        showUnselectedLabels: false,
        
        // Notify the parent state to update the currentIndex
        onTap: onTabSelected,
        
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