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
    if (kIsWeb) {
      // 🌟 FIX: Access Dart's Storage object using Map operator syntax
      final String? deferredLink = html.window.localStorage['deferred_deep_link'];
      html.window.localStorage.remove('deferred_deep_link'); // Clean up immediately

      final String currentUrl = deferredLink ?? html.window.location.href;
      
      if (currentUrl.contains('/#/')) {
        // Handle hash routing fallback safely
        final String extractedPath = currentUrl.split('/#/').last;
        parseAndNavigate('/$extractedPath');
      } else {
        // Handle standard path routing fallback
        final String webPath = html.window.location.pathname ?? '';
        if (webPath.isNotEmpty && webPath != '/') {
          parseAndNavigate(webPath);
        }
      }
    } else {
      // Handle Mobile Deep Links (Both when app is closed, and running in background)
      _appLinks = AppLinks();
      
      // 1. Check if the app was cold-started/opened directly by a QR code scan or shared link
      _appLinks.getInitialLink().then((uri) {
        if (uri != null) parseAndNavigate(uri.path);
      });

      // 2. Listen to incoming deep links while the app is already open in memory
      _linkSubscription = _appLinks.uriLinkStream.listen((uri) {
        parseAndNavigate(uri.path);
      }, onError: (err) {
        debugPrint('Failed to receive deep link: $err');
      });
    }
  }

  /// Centralized Parsing Engine for incoming path formats (e.g., "/shop/2")
void parseAndNavigate(String path) {
  if (path.isEmpty || path == "/") return;

  final cleanPath =
      path.endsWith("/") ? path.substring(0, path.length - 1) : path;

  final uri = Uri.parse(cleanPath);
  final segments = uri.pathSegments;

  if (segments.length < 2) return;

  final type = segments[0];
  final id = int.tryParse(segments[1]);

  if (id == null) return;

  WidgetsBinding.instance.addPostFrameCallback((_) {
    final tabs = MainTabsScreen.of(globalNavigatorKey.currentContext!);

    if (tabs == null) return;

    switch (type) {
      case "product":
        tabs.navigateToProductDetails(id);
        break;

      case "shop":
        tabs.navigateToShopDetails(id);
        break;

      case "property":
        tabs.navigateToPropertyDetails(id);
        break;

      case "event":
        globalNavigatorKey.currentState!.push(
          MaterialPageRoute(
            builder: (_) => EventDeepLinkBridge(eventId: id),
          ),
        );
        break;

      case "lodge":
        globalNavigatorKey.currentState!.push(
          MaterialPageRoute(
            builder: (_) => LodgeDeepLinkBridge(lodgeId: id),
          ),
        );
        break;
    }
  });
}

  /// Always clean up native streams on state destruction
  void disposeRouting() {
    _linkSubscription?.cancel();
  }
}