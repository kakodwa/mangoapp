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
    // Look up the ancestor state tree for MainTabsScreen
    final tabsState = MainTabsScreen.of(context);
    if (tabsState == null) return;

    switch (type) {
      case 'product':
        tabsState.setSelectedIndex(2); // Index 2 is ProductsListScreen
        break;

      case 'shop':
        tabsState.setSelectedIndex(1); // Index 1 is ShopsListScreen
        break;

      case 'event':
        tabsState.setSelectedIndex(4); // Index 4 is EventListScreen
        break;

      case 'property':
        tabsState.setSelectedIndex(3); // Index 3 is PropertiesListScreen
        break;

      case 'lodge':
        tabsState.setSelectedIndex(5); // Index 5 is LodgeListScreen
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
                return Padding(
                  padding: const EdgeInsets.all(8),
                  child: GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: products.length,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                      childAspectRatio: 0.62,
                    ),
                    itemBuilder: (_, i) => ProductCard(product: products[i]),
                  ),
                );

              // =========================
              // SINGLE ITEMS
              // =========================
              case 'shop':
                return ShopCard(shop: _shop(item.data));

              case 'event':
                return EventCard(event: _event(item.data));

              case 'property':
                return PropertyCard(property: _property(item.data));

              case 'lodge':
                return LodgeCard(lodge: _lodge(item.data));

              // =========================
              // HORIZONTAL PRODUCTS
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

              // =========================
              // HORIZONTAL SHOPS
              // =========================
              case 'horizontal_shops':
                return SectionWrapper(
                  title: item.title ?? 'Shops',
                  onViewAll: () => _openViewAll(context, item.viewAllType),
                  child: HorizontalShops(
                    shops: (item.data as List).map<Shop>(_shop).toList(),
                    showHeader: false,
                  ),
                );

              // =========================
              // HORIZONTAL EVENTS
              // =========================
              case 'horizontal_events':
                return SectionWrapper(
                  title: item.title ?? 'Events',
                  onViewAll: () => _openViewAll(context, item.viewAllType),
                  child: HorizontalEvents(
                    events: (item.data as List).map<EventModel>(_event).toList(),
                    showHeader: false,
                  ),
                );

              // =========================
              // HORIZONTAL PROPERTIES
              // =========================
              case 'horizontal_properties':
                return SectionWrapper(
                  title: item.title ?? 'Properties',
                  onViewAll: () => _openViewAll(context, item.viewAllType),
                  child: HorizontalProperties(
                    properties: (item.data as List).map<Property>(_property).toList(),
                    showHeader: false,
                  ),
                );

              // =========================
              // HORIZONTAL LODGES
              // =========================
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