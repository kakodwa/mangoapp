import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../providers/products_provider.dart';
import '../../providers/shops_provider.dart';
import '../../providers/events_provider.dart';
import '../../providers/lodges_provider.dart';
import '../../providers/properties_provider.dart';
import '../../providers/products_provider.dart';

import '../../theme/design_system/app_spacing.dart';

import '../shops/shop_card.dart';
import '../products/product_card.dart';
import '../properties/property_card.dart';

import '../../screens/delivery/delivery_code_entry_screen.dart';
import '../../screens/events/scan_ticket_screen.dart';
import '../../screens/events/event_list_screen.dart';
import '../../screens/hospitality/lodge_list_screen.dart';
import '../../screens/properties/properties_list_screen.dart';
import '../../screens/shops/shops_list_screen.dart';
import '../../screens/products/products_list_screen.dart';

import '../../widgets/main_drawer.dart';
import '../../widgets/main_app_bar.dart';
import '../../widgets/app_scaffold.dart';
import '../../widgets/events/event_card.dart';
import '../../widgets/hospitality/lodge_card.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int bannerIndex = 0;

  @override
  void initState() {
    super.initState();

    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 4));

      if (mounted) {
        final banners = ref.read(bannersProvider).valueOrNull;
        if (banners != null && banners.isNotEmpty) {
          setState(() {
            bannerIndex = (bannerIndex + 1) % banners.length;
          });
        }
      }
      return mounted;
    });
  }

  /// ================= SMART FEED CONFIG =================
  List<String> feedPattern = [
    "products",
    "properties",
    "products",
    "shops",
    "products",
    "events",
    "products",
    "lodges",
    "products",
  ];

  @override
  Widget build(BuildContext context) {
    final productsAsync = ref.watch(productsProvider);
    final shopsAsync = ref.watch(shopsProvider);
    final propertiesAsync = ref.watch(propertiesProvider);
    final eventsAsync = ref.watch(eventsProvider);
    final lodgesAsync = ref.watch(lodgesProvider);
    final bannersAsync = ref.watch(bannersProvider);

    return AppScaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: const MainAppBar(title: 'MangoHub'),
      drawer: const MainDrawer(),
      body: SingleChildScrollView(
        child: Column(
          children: [
          /// ================= BANNER (TOP ONLY) =================
bannersAsync.when(
  data: (banners) {
    if (banners.isEmpty) return const SizedBox();

    final banner = banners[bannerIndex];

    return Container(
      margin: const EdgeInsets.only(
        top: 12,
        left: 12,
        right: 12,
        bottom: 8,
      ),
      child: Column(
        children: [
          SizedBox(
            height: 190,
            width: double.infinity,
            child: _buildBanner(
              context,
              image: banner.imageUrl,
              title: banner.title,
              subtitle: banner.subtitle,
              url: banner.url,
              ctaText: banner.ctaText,
            ),
          ),

          const SizedBox(height: 10),

          AnimatedSmoothIndicator(
            activeIndex: bannerIndex,
            count: banners.length,
            effect: WormEffect(
              dotHeight: 8,
              dotWidth: 8,
              activeDotColor: Theme.of(context).colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  },
  loading: () => const Padding(
    padding: EdgeInsets.all(16),
    child: CircularProgressIndicator(),
  ),
  error: (_, __) => const SizedBox(),
),


            const SizedBox(height: AppSpacing.sm),

            Padding(
  padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
  child: Row(
    children: [

      Expanded(
                    child: _QuickActionButton(
                      icon: Icons.store,
                      label: 'Shops',
                      onTap: () {
                        // TODO: navigate to shops screen
                      },
                    ),
                  ),

      const SizedBox(width: AppSpacing.sm),

      /// EVENTS
      Expanded(
                    child: _QuickActionButton(
                      icon: Icons.local_shipping,
                      label: 'Delivery',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const DeliveryCodeScreen(),
                          ),
                        );
                      },
                    ),
                  ),

      const SizedBox(width: AppSpacing.sm),

      /// MORE
      Expanded(
        child:  _QuickActionButton(
        icon: Icons.qr_code_scanner,
        label: 'Scan Ticket',
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const ScanTicketScreen(),
            ),
          );
        },
      ),
      ),
    ],
  ),
),
       

            const SizedBox(height: 10),

            /// ================= SMART FEED =================
            productsAsync.when(
              data: (products) {
                return shopsAsync.when(
                  data: (shops) {
                    return propertiesAsync.when(
                      data: (properties) {
                        return eventsAsync.when(
                          data: (events) {
                            return lodgesAsync.when(
                              data: (lodges) {
                                return _buildSmartFeed(
                                  products: products,
                                  shops: shops,
                                  properties: properties,
                                  events: events,
                                  lodges: lodges,
                                );
                              },
                              loading: () => const CircularProgressIndicator(),
                              error: (_, __) => const SizedBox(),
                            );
                          },
                          loading: () => const CircularProgressIndicator(),
                          error: (_, __) => const SizedBox(),
                        );
                      },
                      loading: () => const CircularProgressIndicator(),
                      error: (_, __) => const SizedBox(),
                    );
                  },
                  loading: () => const CircularProgressIndicator(),
                  error: (_, __) => const SizedBox(),
                );
              },
              loading: () => const CircularProgressIndicator(),
              error: (_, __) => const SizedBox(),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  /// ================= SMART FEED BUILDER =================
  Widget _buildSmartFeed({
    required List products,
    required List shops,
    required List properties,
    required List events,
    required List lodges,
  }) {
    int productIndex = 0;

    return Column(
      children: List.generate(feedPattern.length, (i) {
        final type = feedPattern[i];

        switch (type) {
          case "products":
            if (productIndex >= products.length) {
              return const SizedBox();
            }

            final chunk = products.skip(productIndex).take(4).toList();
            productIndex += chunk.length;

            return _productGrid(chunk);

          case "shops":
            return _horizontalBlock(
              "Popular Shops",
              shops,
              (item) => ShopCard(shop: item),
              itemWidth: 340,
              height: 270,
            );

          case "properties":
            return _horizontalBlock(
              "Suggested Properties",
              properties,
              (item) =>PropertyCard(property: item),
              itemWidth: 340,
              height:310,
            );
          case "events":
            return _horizontalBlock(
            "Upcoming Events",
            events,
            (item) => EventCard(event: item),
            itemWidth: 340,
            height:360,
            );

case "lodges":
  return _horizontalBlock(
    "Recommended Lodges",
    lodges,
    (item) => LodgeCard(lodge: item),
    itemWidth: 340,
    height:290,
  );

          default:
            return const SizedBox();
        }
      }),
    );
  }

  /// ================= PRODUCT GRID =================
  Widget _productGrid(List products) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 2,
        childAspectRatio: 0.72,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        children: products
            .map((p) => ProductCard(product: p))
            .toList(),
      ),
    );
  }

  /// ================= HORIZONTAL BLOCK =================
Widget _horizontalBlock(
  String title,
  List items,
  Widget Function(dynamic) builder, {
  double itemWidth = 200,
  double height = 220,
}) {
  if (items.isEmpty) return const SizedBox();

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      const SizedBox(height: 8),
      SizedBox(
        height: height,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount:items.length,
          itemBuilder: (_, i) {
            return SizedBox(
              width: itemWidth,
              child: Padding(
                padding: const EdgeInsets.only(left: 10),
                child: builder(items[i]),
              ),
            );
          },
        ),
      ),
    ],
  );
}
  /// ================= BANNER =================
  Widget _buildBanner(
    BuildContext context, {
    required String image,
    required String title,
    required String subtitle,
    String? url,
    String? ctaText,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.network(image, fit: BoxFit.cover),
          Container(
            color: Colors.black.withOpacity(0.4),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                Text(subtitle,
                    style: const TextStyle(color: Colors.white70)),
              ],
            ),
          )
        ],
      ),
    );
  }
}


// QUICK ACTION BUTTON
class _QuickActionButton extends StatefulWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  State<_QuickActionButton> createState() => _QuickActionButtonState();
}

class _QuickActionButtonState extends State<_QuickActionButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _isPressed ? 0.95 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: Theme.of(context).colorScheme.surface,
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.06),
                blurRadius: 12,
                offset: const Offset(0, 4),
              )
            ],
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: widget.onTap,
            child: Padding(
              padding: EdgeInsets.all(AppSpacing.md),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    widget.icon,
                    size: 28,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    widget.label,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.labelMedium,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}