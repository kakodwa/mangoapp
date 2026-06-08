// lib/router/app_router.dart
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:universal_html/html.dart' as html;

// Import Main explicitly for global navigation controller targets
import '../main.dart' show globalNavigatorKey;

// 📦 Feature Screen Imports (Double check spelling matching your exact widget classes!)
import 'package:mangochi_marketplace/screens/products/product_details_screen.dart';
import 'package:mangochi_marketplace/screens/properties/property_details_screen.dart';
import 'package:mangochi_marketplace/screens/shops/shop_details_screen.dart';
import 'package:mangochi_marketplace/screens/events/event_detail_screen.dart';
import 'package:mangochi_marketplace/screens/hospitality/lodge_detail_screen.dart';

// 📦 Data Infrastructure Models
import '../models/event_model.dart';
import '../models/lodge_model.dart';

mixin WebRouterMixin<T extends StatefulWidget> on State<T> {
  
  void handleIncomingWebLink() {
    if (!kIsWeb) return;

    // 🌟 Read the absolute browser pathname (e.g. '/shop/2') instead of the old hash fragment
    final String path = html.window.location.pathname ?? ''; 
    if (path.isEmpty || path == '/') return;

    final uri = Uri.parse(path);
    final segments = uri.pathSegments;
    
    if (segments.length < 2) return;
    
    final String type = segments[0]; // matches 'shop', 'product', 'property', etc.
    final int? itemId = int.tryParse(segments[1]);
    if (itemId == null) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      
      Widget? destinationScreen;

      switch (type) {
        case 'shop':
          destinationScreen = ShopDetailsScreen(shopId: itemId);
          break;
        case 'product':
          destinationScreen = ProductDetailsScreen(productId: itemId);
          break;
        case 'property':
          destinationScreen = PropertyDetailsScreen(propertyId: itemId);
          break;
        case 'event':
          destinationScreen = EventDetailScreen(
            event: EventModel(
              id: itemId, title: "Loading Event...", description: "",
              venue: "", district: "", city: "", eventDate: "",
              startTime: "", endTime: "", banner: "", ticketPrice: 0.0,
              totalTickets: 0, availableTickets: 0, isFeatured: false, ticketTypes: const [],
            ),
          );
          break;
        case 'lodge':
          destinationScreen = LodgeDetailScreen(
            lodge: Lodge(
              id: itemId, name: "Loading Lodge...", description: "",
              lodgeType: "Lodge", city: "", district: "", address: "",
              phoneNumber: "", email: "", isVerified: false, images: const [], 
            ),
          );
          break;
        default:
          return;
      }

      // 🌟 Clean mount placement over active app framework
      if (destinationScreen != null && globalNavigatorKey.currentState != null) {
        globalNavigatorKey.currentState!.push(
          MaterialPageRoute(builder: (_) => destinationScreen!),
        );
      }
    });
  }
}