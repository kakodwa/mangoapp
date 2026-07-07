// lib/router/app_router.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:universal_html/html.dart' as html;
import 'package:app_links/app_links.dart'; 

// Import Main explicitly for global navigation controller targets
import '../main.dart' show globalNavigatorKey, EventDeepLinkBridge, LodgeDeepLinkBridge;

// 📦 Feature Screen Imports
import 'package:mangochi_marketplace/screens/main_tabs_screen.dart';

mixin AppRouterMixin<T extends StatefulWidget> on State<T> {
  late final AppLinks _appLinks;
  StreamSubscription<Uri>? _linkSubscription;

  /// Call this method in your Main Screen's initState() to listen to QR and shared links everywhere!
  void initializeRouting() {
    debugPrint('[AppRouter] Initializing routing...');
    
    if (kIsWeb) {
      debugPrint('[AppRouter] Web platform detected');
      // 🌟 FIX: Access Dart's Storage object using Map operator syntax
      final String? deferredLink = html.window.localStorage['deferred_deep_link'];
      html.window.localStorage.remove('deferred_deep_link'); // Clean up immediately

      final String currentUrl = deferredLink ?? html.window.location.href;
      debugPrint('[AppRouter] Current URL: $currentUrl');
      
      if (currentUrl.contains('/#/')) {
        // Handle hash routing fallback safely
        final String extractedPath = currentUrl.split('/#/').last;
        debugPrint('[AppRouter] Hash routing detected, extracted path: /$extractedPath');
        parseAndNavigate('/$extractedPath');
      } else {
        // Handle standard path routing fallback
        final String webPath = html.window.location.pathname ?? '';
        if (webPath.isNotEmpty && webPath != '/') {
          debugPrint('[AppRouter] Path routing detected: $webPath');
          parseAndNavigate(webPath);
        }
      }
    } else {
      // Handle Mobile Deep Links (Both when app is closed, and running in background)
      debugPrint('[AppRouter] Mobile platform detected, initializing app_links');
      _appLinks = AppLinks();
      
      // 1. Check if the app was cold-started/opened directly by a QR code scan or shared link
      _appLinks.getInitialLink().then((uri) {
        if (uri != null) {
          debugPrint('[AppRouter] Initial deep link found: $uri');
          parseAndNavigate(uri.toString());
        } else {
          debugPrint('[AppRouter] No initial deep link found');
        }
      }).catchError((error) {
        debugPrint('[AppRouter] Error getting initial link: $error');
      });

      // 2. Listen to incoming deep links while the app is already open in memory
      _linkSubscription = _appLinks.uriLinkStream.listen((uri) {
        debugPrint('[AppRouter] Deep link received while app open: $uri');
        parseAndNavigate(uri.toString());
      }, onError: (err) {
        debugPrint('[AppRouter] Failed to receive deep link: $err');
      });
    }
  }

  /// Centralized Parsing Engine for incoming path formats (e.g., "/shop/2" or "https://mangobackend-yayy.onrender.com/shop/2")
void parseAndNavigate(String path) {
  if (path.isEmpty || path == "/") return;

  debugPrint('[AppRouter] Attempting to parse deep link: $path');

  // Extract just the path component if it's a full URL
  String cleanPath = path;
  if (path.contains('mangobackend-yayy.onrender.com')) {
    final uri = Uri.parse(path);
    cleanPath = uri.path;
    debugPrint('[AppRouter] Extracted path from URL: $cleanPath');
  }

  // Remove trailing slash
  cleanPath = cleanPath.endsWith("/") ? cleanPath.substring(0, cleanPath.length - 1) : cleanPath;
  
  if (cleanPath.isEmpty || cleanPath == "/") return;

  final segments = cleanPath.split('/').where((s) => s.isNotEmpty).toList();

  debugPrint('[AppRouter] Path segments: $segments');

  if (segments.length < 2) {
    debugPrint('[AppRouter] Not enough segments to parse');
    return;
  }

  final type = segments[0];
  final idStr = segments[1];
  final id = int.tryParse(idStr);

  if (id == null) {
    debugPrint('[AppRouter] Could not parse ID: $idStr');
    return;
  }

  debugPrint('[AppRouter] Successfully parsed - Type: $type, ID: $id');

  WidgetsBinding.instance.addPostFrameCallback((_) {
    final tabs = MainTabsScreen.of(globalNavigatorKey.currentContext!);

    if (tabs == null) {
      debugPrint('[AppRouter] MainTabsScreen not found in context');
      return;
    }

    switch (type) {
      case "product":
        debugPrint('[AppRouter] Navigating to product: $id');
        tabs.navigateToProductDetails(id);
        break;

      case "shop":
        debugPrint('[AppRouter] Navigating to shop: $id');
        tabs.navigateToShopDetails(id);
        break;

      case "property":
        debugPrint('[AppRouter] Navigating to property: $id');
        tabs.navigateToPropertyDetails(id);
        break;

      case "event":
        debugPrint('[AppRouter] Navigating to event: $id');
        globalNavigatorKey.currentState!.push(
          MaterialPageRoute(
            builder: (_) => EventDeepLinkBridge(eventId: id),
          ),
        );
        break;

      case "lodge":
        debugPrint('[AppRouter] Navigating to lodge: $id');
        globalNavigatorKey.currentState!.push(
          MaterialPageRoute(
            builder: (_) => LodgeDeepLinkBridge(lodgeId: id),
          ),
        );
        break;
        
      default:
        debugPrint('[AppRouter] Unknown type: $type');
    }
  });
}

  /// Always clean up native streams on state destruction
  void disposeRouting() {
    _linkSubscription?.cancel();
  }
}
