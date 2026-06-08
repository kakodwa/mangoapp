// lib/screens/main_tabs_screen.dart

import 'package:flutter/material.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/main_app_bar.dart';
import '../widgets/main_drawer.dart';

import 'home/home_screen.dart';
import 'shops/feed_shops_list_screen.dart';
import 'products/feed_products_list_screen.dart';
import 'properties/feed_properties_list_screen.dart';
import 'events/feed_event_list_screen.dart';
import 'hospitality/feed_lodge_list_screen.dart';
import 'profile/profile_screen.dart';
import 'search/unified_search_screen.dart';
import 'cart/cart_screen.dart';
import 'delivery/delivery_code_entry_screen.dart';
import 'about/about_screen.dart';
import 'help/help_screen.dart';

import 'products/product_details_screen.dart'; 
import 'properties/property_details_screen.dart';
import 'shops/shop_details_screen.dart'; 
import 'hospitality/lodge_detail_screen.dart'; 
import 'events/event_detail_screen.dart'; // IMPORTED: Add target child screen reference
import '../models/lodge_model.dart';           
import '../models/event_model.dart'; // IMPORTED: Add core model definition

class MainTabsScreen extends StatefulWidget {
  const MainTabsScreen({super.key});

  static _MainTabsScreenState? of(BuildContext context) {
    return context.findAncestorStateOfType<_MainTabsScreenState>();
  }

  @override
  State<MainTabsScreen> createState() => _MainTabsScreenState();
}

class _MainTabsScreenState extends State<MainTabsScreen> {
  int _currentIndex = 0;
  int? _activeProductId; 
  int? _activeShopId; 
  Lodge? _activeLodge;
  int? _activePropertyId; 
  EventModel? _activeEvent; // UPDATED: Persistent local container tracking selected event view data

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    
    _screens = [
      HomeScreen(onDeliveryTap: () => _changeTab(9)),
      const ShopsListScreen(),        // Index 1
      const ProductsListScreen(),     // Index 2
      const PropertiesListScreen(),   // Index 3
      const EventListScreen(),        // Index 4
      const LodgeListScreen(),        // Index 5
      const ProfileScreen(),          // Index 6
      const UnifiedSearchScreen(),    // Index 7
      const CartScreen(),             // Index 8
      const DeliveryCodeScreen(),     // Index 9
      const AboutScreen(),            // Index 10
      const HelpSupportScreen(),      // Index 11
    ];
  }

  void navigateToProductDetails(int productId) {
    setState(() {
      _activeProductId = productId;
      _currentIndex = 12;
    });
  }

  void navigateToShopDetails(int shopId) {
    setState(() {
      _activeShopId = shopId;
      _currentIndex = 13;
    });
  }

  void navigateToLodgeDetails(Lodge lodge) {
    setState(() {
      _activeLodge = lodge;
      _currentIndex = 14;
    });
  }

  void navigateToPropertyDetails(int propertyId) {
    setState(() {
      _activePropertyId = propertyId;
      _currentIndex = 15; 
    });
  }

  // UPDATED: Dynamic transition mechanism routing details view content inside structural shell
  void navigateToEventDetails(EventModel event) {
    setState(() {
      _activeEvent = event;
      _currentIndex = 16; // Assigned explicitly to Slot index 16
    });
  }

  void setSelectedIndex(int index) {
    _changeTab(index);
  }

  void _changeTab(int index) {
    if (_currentIndex == index) return;
    setState(() {
      _currentIndex = index;
    });
  }

  String _getAppBarTitle() {
    switch (_currentIndex) {
      case 9: return "Delivery Rider";
      case 10: return "About App";
      case 11: return "Help";
      default: return "MangoHub";
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isModalRouteActive = ModalRoute.of(context)?.isCurrent ?? true;

    int displayIndex = _currentIndex;
    if (_currentIndex == 12) displayIndex = 2; // Product details -> Products tab
    if (_currentIndex == 13) displayIndex = 1; // Shop details -> Shops tab
    if (_currentIndex == 14) displayIndex = 5; // Lodge details -> Lodges tab
    if (_currentIndex == 15) displayIndex = 3; // Property details -> Properties tab
    if (_currentIndex == 16) displayIndex = 4; // UPDATED: Maps internal details slot back to base Events navigation option tab

    return AppScaffold(
      currentIndex: displayIndex,
      onTabSelected: _changeTab,
      // UPDATED: Included structural Index boundary check verification rule for index 16
      appBar: (_currentIndex == 12 || _currentIndex == 13 || _currentIndex == 14 || _currentIndex == 15 || _currentIndex == 16)
          ? null 
          : MainAppBar(
              title: _getAppBarTitle(),
              onProfileTap: () => _changeTab(6),
              onSearchTap: () => _changeTab(7),
              onCartTap: () => _changeTab(8),
            ),
      drawer: MainDrawer(
        onAboutTap: () => _changeTab(10),
        onHelpTap: () => _changeTab(11),
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: [
          ..._screens,
          // Index 12: Persistent Product View
          _activeProductId != null 
              ? ProductDetailsScreen(key: ValueKey('p_$_activeProductId'), productId: _activeProductId!)
              : const Center(child: Text("No product selected")),
          // Index 13: Persistent Shop View
          _activeShopId != null 
              ? ShopDetailsScreen(key: ValueKey('s_$_activeShopId'), shopId: _activeShopId!)
              : const Center(child: Text("No shop selected")),
          // Index 14: Persistent Lodge View
          _activeLodge != null 
              ? LodgeDetailScreen(key: ValueKey('l_${_activeLodge!.id}'), lodge: _activeLodge!)
              : const Center(child: Text("No lodge selected")),
          // Index 15: Persistent Property View
          _activePropertyId != null 
              ? PropertyDetailsScreen(key: ValueKey('prop_$_activePropertyId'), propertyId: _activePropertyId!)
              : const Center(child: Text("No property selected")),
          // Index 16: UPDATED: Added structural allocation destination component target slot matching core application shells
          _activeEvent != null
              ? EventDetailScreen(key: ValueKey('event__${_activeEvent!.id}'), event: _activeEvent!)
              : const Center(child: Text("No event selected")),
        ],
      ),
    );
  }
}