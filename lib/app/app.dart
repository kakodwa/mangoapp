// lib/app/app.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../screens/main_tabs_screen.dart'; 
import '../router/app_router.dart';
import '../screens/products/product_details_screen.dart';
import '../screens/shops/shop_details_screen.dart';
import '../screens/properties/property_details_screen.dart';
import '../main.dart'; // Grants access to DeepLinkBridge Shells

class MyApp extends ConsumerStatefulWidget {
  // 🛡️ ACCEPT THE DEEP LINK PATH FROM MAIN.DART
  final String? initialRoutePath;

  const MyApp({
    super.key,
    this.initialRoutePath,
  });

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> with WebRouterMixin {
  bool _deepLinkHandled = false;

  @override
  void initState() {
    super.initState();
    
    // Execute routing paths safely after the MainTabsScreen frame finishes mounting
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _processSavedDeepLink();
    });
  }

  void _processSavedDeepLink() {
    // If it has been handled already or there is no deep link, run your default setup
    if (_deepLinkHandled || widget.initialRoutePath == null) {
      handleIncomingWebLink();
      return;
    }

    final String path = widget.initialRoutePath!;
    _deepLinkHandled = true; // Lock out background loops from re-running this configuration

    // Navigate to the correct details screen over the main shell view context
    if (path.startsWith('/product/')) {
      final id = int.tryParse(path.replaceFirst('/product/', ''));
      if (id != null) _navigateTo(ProductDetailsScreen(productId: id));
    } else if (path.startsWith('/property/')) {
      final id = int.tryParse(path.replaceFirst('/property/', ''));
      if (id != null) _navigateTo(PropertyDetailsScreen(propertyId: id));
    } else if (path.startsWith('/shop/')) {
      final id = int.tryParse(path.replaceFirst('/shop/', ''));
      if (id != null) _navigateTo(ShopDetailsScreen(shopId: id));
    } else if (path.startsWith('/lodge/')) {
      final id = int.tryParse(path.replaceFirst('/lodge/', ''));
      if (id != null) _navigateTo(LodgeDeepLinkBridge(lodgeId: id));
    } else if (path.startsWith('/event/')) {
      final id = int.tryParse(path.replaceFirst('/event/', ''));
      if (id != null) _navigateTo(EventDeepLinkBridge(eventId: id));
    }
  }

  void _navigateTo(Widget targetScreen) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => targetScreen),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const MainTabsScreen(); 
  }
}