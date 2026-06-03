import 'package:flutter/material.dart';
import '../widgets/app_scaffold.dart';

// Import all your tab screens
import 'home/home_screen.dart';
import 'shops/feed_shops_list_screen.dart';
import 'products/feed_products_list_screen.dart';
import 'properties/feed_properties_list_screen.dart';
import 'events/feed_event_list_screen.dart';
import 'hospitality/feed_lodge_list_screen.dart';
import 'search/unified_search_screen.dart';

// Import common layout dependencies 
import '../widgets/main_drawer.dart';
import '../widgets/main_app_bar.dart';

class MainTabsScreen extends StatefulWidget {
  const MainTabsScreen({super.key});

  @override
  State<MainTabsScreen> createState() => _MainTabsScreenState();
}

class _MainTabsScreenState extends State<MainTabsScreen> {
  int _currentIndex = 0;

  // The list of screens kept alive in memory via IndexedStack
  final List<Widget> _screens = const [
    HomeScreen(),
    ShopsListScreen(),
    ProductsListScreen(),
    PropertiesListScreen(),
    EventListScreen(),
    LodgeListScreen(),
    UnifiedSearchScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      currentIndex: _currentIndex,
      onTabSelected: (index) {
        setState(() {
          _currentIndex = index; // Updates the visible tab smoothly without reloading
        });
      },
      appBar: const MainAppBar(title: "MangoHub"),
      drawer: const MainDrawer(),
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
    );
  }
}