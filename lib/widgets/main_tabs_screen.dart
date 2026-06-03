import 'package:flutter/material.dart';
import '../../widgets/app_scaffold.dart';

// Import all your tab screens
import '../../screens/home/home_screen.dart';
import '../../screens/shops/feed_shops_list_screen.dart';
import '../../screens/products/feed_products_list_screen.dart';
import '../../screens/properties/feed_properties_list_screen.dart';
import '../../screens/events/feed_event_list_screen.dart';
import '../../screens/hospitality/feed_lodge_list_screen.dart';

// Import common layout dependencies 
import 'main_drawer.dart';
import 'main_app_bar.dart';

class MainTabsScreen extends StatefulWidget {
  const MainTabsScreen({super.key});

  @override
  State<MainTabsScreen> createState() => _MainTabsScreenState();
}

class _MainTabsScreenState extends State<MainTabsScreen> {
  int _currentIndex = 0;

  // The list of screens to maintain in memory via IndexedStack
  final List<Widget> _screens = const [
    HomeScreen(),
    ShopsListScreen(),
    ProductsListScreen(),
    PropertiesListScreen(),
    EventListScreen(),
    LodgeListScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      currentIndex: _currentIndex,
      onTabSelected: (index) {
        setState(() {
          _currentIndex = index;
        });
      },
      appBar: const MainAppBar(title: "MangoHub"),
      drawer: const MainDrawer(),
      // Passing the IndexedStack here keeps screen memory intact!
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
    );
  }
}