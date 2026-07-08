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

// 🌟 FIX: Apply the mixin directly onto State<MainTabsScreen> or remove strict bindings to ensure public class compatibility
mixin AppRouterMixin<T extends StatefulWidget> on State<T> {
  late final AppLinks _appLinks;
  StreamSubscription<Uri>? _linkSubscription;

  /// Call this method in your Main Screen's initState() to listen to QR and shared links everywhere!
  void initializeRouting() {
    debugPrint('[AppRouter] Initializing routing...');

    if (kIsWeb) {
      debugPrint("[AppRouter] Web platform detected");
      final href = html.window.location.href;
      debugPrint("HREF = $href");
      parseAndNavigate(href);
      return;
    }

    // MOBILE DEEP LINKS
    _appLinks = AppLinks();

    _appLinks.getInitialLink().then((uri) {
      if (uri != null) {
        debugPrint('[AppRouter] Initial link: $uri');
        parseAndNavigate(uri.toString());
      }
    });

    _linkSubscription = _appLinks.uriLinkStream.listen(
      (uri) {
        debugPrint('[AppRouter] Incoming link: $uri');
        parseAndNavigate(uri.toString());
      },
      onError: (err) {
        debugPrint('[AppRouter] Link Error: $err');
      },
    );
  }

  /// Centralized Parsing Engine for incoming path formats
  void parseAndNavigate(String path) {
    if (path.isEmpty || path == "/") return;

    debugPrint('[AppRouter] Attempting to parse deep link: $path');

    String cleanPath = path;

    if (path.startsWith('http')) {
      final uri = Uri.parse(path);

      if (uri.fragment.isNotEmpty) {
        cleanPath = uri.fragment.startsWith('/')
            ? uri.fragment
            : '/${uri.fragment}';
      } else {
        cleanPath = uri.path;
      }
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
      // 🌟 Use the public static instance directly safely
      final tabs = MainTabsScreenState.instance;

      if (tabs == null) {
        debugPrint('[AppRouter] Critical Error - Component context unavailable.');
        return;
      }

      debugPrint("Type = $type");
      debugPrint("ID = $id");

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