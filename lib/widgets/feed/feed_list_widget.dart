import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/product_model.dart';
import '../../models/shop_model.dart';
import '../../models/event_model.dart';
import '../../models/property_model.dart';
import '../../models/lodge_model.dart';

import '../../screens/products/product_card.dart';
import '../../screens/shops/shop_card.dart';
import '../../screens/properties/property_card.dart';
import '../hospitality/lodge_card.dart';
import '../events/event_card.dart';

// Import your MainTabsScreen to get access to its static .of(context) helper
import '../../screens/main_tabs_screen.dart'; 

import '../horizontal_feed/horizontal_products.dart';
import '../horizontal_feed/horizontal_shops.dart';
import '../horizontal_feed/horizontal_events.dart';
import '../horizontal_feed/horizontal_properties.dart';
import '../horizontal_feed/horizontal_lodges.dart';
import 'section_wrapper.dart';

class FeedListWidget extends ConsumerWidget {
  final List items;

  const FeedListWidget({
    super.key,
    required this.items,
  });

  /// Changes the active index inside MainTabsScreen's IndexedStack
  void _openViewAll(
    BuildContext context,
    String? type,
  ) {
    final tabsState = MainTabsScreen.of(context);
    if (tabsState == null) return;

    switch (type) {
      case 'product':
        tabsState.setSelectedIndex(2);
        break;
      case 'shop':
        tabsState.setSelectedIndex(1);
        break;
      case 'event':
        tabsState.setSelectedIndex(4);
        break;
      case 'property':
        tabsState.setSelectedIndex(3);
        break;
      case 'lodge':
        tabsState.setSelectedIndex(5);
        break;
    }
  }

  // =========================
  // SAFE PARSERS
  // =========================

  Product _product(dynamic data) {
    if (data is Product) return data;
    return Product.fromJson(Map<String, dynamic>.from(data));
  }

  Shop _shop(dynamic data) {
    if (data is Shop) return data;
    return Shop.fromJson(Map<String, dynamic>.from(data));
  }

  EventModel _event(dynamic data) {
    if (data is EventModel) return data;
    return EventModel.fromJson(Map<String, dynamic>.from(data));
  }

  Property _property(dynamic data) {
    if (data is Property) return data;
    return Property.fromJson(Map<String, dynamic>.from(data));
  }

  Lodge _lodge(dynamic data) {
    if (data is Lodge) return data;
    return Lodge.fromJson(Map<String, dynamic>.from(data));
  }

  // ========================================================
  // RESPONSIVE GRID HELPER BUILDER
  // ========================================================
  Widget _buildResponsiveGrid({
    required BuildContext context,
    required int itemCount,
    required double childAspectRatio,
    required Widget Function(BuildContext, int) cardBuilder,
    bool isProductGrid = false,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;

    int crossAxisCount;

    if (isProductGrid) {
      // Products: Mobile = 2, Desktop scales up to 6
      if (screenWidth >= 1200) {
        crossAxisCount = 6;
      } else if (screenWidth >= 800) {
        crossAxisCount = 4;
      } else if (screenWidth >= 600) {
        crossAxisCount = 3;
      } else {
        crossAxisCount = 2; 
      }
    } else {
      // Shops, Lodges, Properties, Events: Mobile = 1, Desktop scales up
      if (screenWidth >= 1200) {
        crossAxisCount = 4; // Looks cleaner on large displays for wider item layouts
      } else if (screenWidth >= 800) {
        crossAxisCount = 3;
      } else if (screenWidth >= 600) {
        crossAxisCount = 2;
      } else {
        crossAxisCount = 1; // 1 per row on standard mobile displays
      }
    }

    return Padding(
      padding: const EdgeInsets.all(8),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: itemCount,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
          childAspectRatio: childAspectRatio,
        ),
        itemBuilder: cardBuilder,
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final item = items[index];

          try {
            switch (item.type) {
              // =========================
              // PRODUCT GRID
              // =========================
              case 'product_grid':
                final products = (item.data as List).map<Product>(_product).toList();
                return _buildResponsiveGrid(
                  context: context,
                  itemCount: products.length,
                  childAspectRatio: 0.62,
                  isProductGrid: true,
                  cardBuilder: (_, i) => ProductCard(product: products[i]),
                );

              // ========================================================
              // DYNAMIC GRIDS (Now adapting safely from 1 on Mobile)
              // ========================================================
              case 'shop':
                final rawData = item.data is List ? item.data as List : [item.data];
                final shops = rawData.map<Shop>(_shop).toList();
                return _buildResponsiveGrid(
                  context: context,
                  itemCount: shops.length,
                  childAspectRatio: 1.3, // Adjusted for wide desktop rows
                  cardBuilder: (_, i) => ShopCard(shop: shops[i]),
                );

              case 'event':
                final rawData = item.data is List ? item.data as List : [item.data];
                final events = rawData.map<EventModel>(_event).toList();
                return _buildResponsiveGrid(
                  context: context,
                  itemCount: events.length,
                  childAspectRatio: 1.2,
                  cardBuilder: (_, i) => EventCard(event: events[i]),
                );

              case 'property':
                final rawData = item.data is List ? item.data as List : [item.data];
                final properties = rawData.map<Property>(_property).toList();
                return _buildResponsiveGrid(
                  context: context,
                  itemCount: properties.length,
                  childAspectRatio: 1.1,
                  cardBuilder: (_, i) => PropertyCard(property: properties[i]),
                );

              case 'lodge':
                final rawData = item.data is List ? item.data as List : [item.data];
                final lodges = rawData.map<Lodge>(_lodge).toList();
                return _buildResponsiveGrid(
                  context: context,
                  itemCount: lodges.length,
                  childAspectRatio: 1.1,
                  cardBuilder: (_, i) => LodgeCard(lodge: lodges[i]),
                );

              // =========================
              // HORIZONTAL FEEDS
              // =========================
              case 'horizontal_products':
                return SectionWrapper(
                  title: item.title ?? 'Products',
                  onViewAll: () => _openViewAll(context, item.viewAllType),
                  child: HorizontalProducts(
                    products: (item.data as List).map<Product>(_product).toList(),
                    showHeader: false,
                  ),
                );

              case 'horizontal_shops':
                return SectionWrapper(
                  title: item.title ?? 'Shops',
                  onViewAll: () => _openViewAll(context, item.viewAllType),
                  child: HorizontalShops(
                    shops: (item.data as List).map<Shop>(_shop).toList(),
                    showHeader: false,
                  ),
                );

              case 'horizontal_events':
                return SectionWrapper(
                  title: item.title ?? 'Events',
                  onViewAll: () => _openViewAll(context, item.viewAllType),
                  child: HorizontalEvents(
                    events: (item.data as List).map<EventModel>(_event).toList(),
                    showHeader: false,
                  ),
                );

              case 'horizontal_properties':
                return SectionWrapper(
                  title: item.title ?? 'Properties',
                  onViewAll: () => _openViewAll(context, item.viewAllType),
                  child: HorizontalProperties(
                    properties: (item.data as List).map<Property>(_property).toList(),
                    showHeader: false,
                  ),
                );

              case 'horizontal_lodges':
                return SectionWrapper(
                  title: item.title ?? 'Lodges',
                  onViewAll: () => _openViewAll(context, item.viewAllType),
                  child: HorizontalLodges(
                    lodges: (item.data as List).map<Lodge>(_lodge).toList(),
                    showHeader: false,
                  ),
                );

              default:
                return const SizedBox.shrink();
            }
          } catch (e, stackTrace) {
            debugPrint('Feed Render Error => ${item.type}');
            return Container(
              margin: const EdgeInsets.all(12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Error loading ${item.type}',
                style: const TextStyle(color: Colors.red),
              ),
            );
          }
        },
        childCount: items.length,
      ),
    );
  }
}