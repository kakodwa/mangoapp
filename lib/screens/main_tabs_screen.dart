import 'package:flutter/material.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/main_app_bar.dart';
import '../widgets/main_drawer.dart';

import 'home/home_screen.dart';
import 'shops/feed_shops_list_screen.dart';
import 'products/feed_products_list_screen.dart';
import 'products/product_details_screen.dart';
import 'properties/feed_properties_list_screen.dart';
import 'events/feed_event_list_screen.dart';
import 'events/scan_ticket_screen.dart';
import 'hospitality/feed_lodge_list_screen.dart';
import 'profile/profile_screen.dart';
import 'search/unified_search_screen.dart';
import 'cart/cart_screen.dart';
import 'delivery/delivery_code_entry_screen.dart';
import 'about/about_screen.dart';
import 'help/help_screen.dart';

class MainTabsScreen extends StatefulWidget {
  const MainTabsScreen({super.key});

  @override
  State<MainTabsScreen> createState() => _MainTabsScreenState();
}

class _MainTabsScreenState extends State<MainTabsScreen> {
  int _currentIndex = 0;

  void _changeTab(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  // Helper method to make sure the app bar updates its text nicely
  String _getAppBarTitle() {
    switch (_currentIndex) {
      case 9:
        return "Delivery Rider";
      case 10:
        return "Scan Ticket";
      case 11:
        return "About App";
      case 12:
        return "Help";
      default:
        return "MangoHub";
    }
  }

  @override
  Widget build(BuildContext context) {
    // Exact mapping order (Indices: 0 to 11)
    final List<Widget> screens = [
      HomeScreen(
        onDeliveryTap: () => _changeTab(9),     // Corrected target index link
        onTicketScanerTap: () => _changeTab(10), // Corrected target index link
      ),
      const ShopsListScreen(),        // Index 1
      const ProductsListScreen(),     // Index 2
      const PropertiesListScreen(),   // Index 3
      const EventListScreen(),        // Index 4
      const LodgeListScreen(),        // Index 5
      const ProfileScreen(),          // Index 6
      const UnifiedSearchScreen(),    // Index 7
      const CartScreen(),             // Index 8
      const DeliveryCodeScreen(),     // Index 9
      const ScanTicketScreen(),       // Index 10
      const AboutScreen(),            // Index 11
      const HelpSupportScreen(),        // Index 12
    ];

    return AppScaffold(
      currentIndex: _currentIndex,
      onTabSelected: _changeTab,
      appBar: MainAppBar(
        title: _getAppBarTitle(),
        onProfileTap: () => _changeTab(6),
        onSearchTap: () => _changeTab(7),
        onCartTap: () => _changeTab(8),
      ),
      drawer: MainDrawer(
        onAboutTap: () => _changeTab(11),
        onHelpTap: () => _changeTab(12),
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
    );
  }
}