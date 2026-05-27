import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:carousel_slider/carousel_controller.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../providers/products_provider.dart';
import '../../providers/shops_provider.dart';
import '../../providers/properties_provider.dart';
import '../../theme/design_system/app_spacing.dart';
import '../../theme/design_system/app_typography.dart';
import '../shops/shop_card.dart';
import '../products/product_card.dart';
import '../properties/property_card.dart';
import '../../screens/delivery/delivery_code_entry_screen.dart';
import '../../screens/events/scan_ticket_screen.dart';
import '../../screens/events/event_list_screen.dart';
import '../../screens/hospitality/lodge_list_screen.dart';
import '../../widgets/main_drawer.dart';
import '../../widgets/main_app_bar.dart';
import '../../widgets/app_scaffold.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int activeIndex = 0;

  final CarouselSliderController _controller = CarouselSliderController();

  void _openUrl(String url) async {
    final uri = Uri.parse(url);

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final productsAsync = ref.watch(productsProvider);
    final shopsAsync = ref.watch(shopsProvider);
    final propertiesAsync = ref.watch(propertiesProvider);
    final bannersAsync = ref.watch(bannersProvider); // 👈 FROM BACKEND

    return AppScaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: const MainAppBar(title: 'MangoHub'),
      drawer: const MainDrawer(),
      body: SingleChildScrollView(
        child: Column(
          children: [

            /// 🔥 BANNERS FROM DJANGO
            bannersAsync.when(
              data: (banners) {
                if (banners.isEmpty) return const SizedBox();

                return Column(
                  children: [
                    CarouselSlider.builder(
                      itemCount: banners.length,
                      itemBuilder: (context, index, _) {
                        final banner = banners[index];

                        return _buildBanner(
                          context,
                          image: banner.imageUrl,
                          title: banner.title,
                          subtitle: banner.subtitle,
                          url: banner.url,
                          ctaText: banner.ctaText,
                        );
                      },
                      options: CarouselOptions(
                        height: 190,
                        autoPlay: true,
                        viewportFraction: 1.0,
                        onPageChanged: (index, reason) {
                          setState(() => activeIndex = index);
                        },
                      ),
                    ),

                    const SizedBox(height: 10),

                    AnimatedSmoothIndicator(
                      activeIndex: activeIndex,
                      count: banners.length,
                      effect: WormEffect(
                        dotHeight: 8,
                        dotWidth: 8,
                        activeDotColor:
                            Theme.of(context).colorScheme.primary,
                      ),
                      onDotClicked: (index) {
                        _controller.animateToPage(index);
                      },
                    ),
                  ],
                );
              },
              loading: () => const Padding(
                padding: EdgeInsets.all(20),
                child: CircularProgressIndicator(),
              ),
              error: (_, __) => const SizedBox(),
            ),

            const SizedBox(height: AppSpacing.lg),

            // QUICK ACTIONS
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
                  Expanded(
                    child: _QuickActionButton(
                      icon: Icons.home_work,
                      label: 'Properties',
                      onTap: () {
                        // TODO: navigate to properties screen
                      },
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
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
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.sm),

            Padding(
  padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
  child: Row(
    children: [

      /// HOSPITALITY
      Expanded(
        child: _QuickActionButton(
          icon: Icons.hotel,
          label: 'Hospitality',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const LodgeListScreen(),
              ),
            );
          },
        ),
      ),

      const SizedBox(width: AppSpacing.sm),

      /// EVENTS
      Expanded(
        child: _QuickActionButton(
          icon: Icons.event,
          label: 'Events',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const EventListScreen(),
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
            const SizedBox(height: AppSpacing.lg),

            // SHOPS
            _sectionHeader(context, 'Popular Shops'),
            shopsAsync.when(
              data: (shops) {
                final featured = shops.take(3).toList();
                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
                  itemCount: featured.length,
                  itemBuilder: (context, index) =>
                      ShopCard(shop: featured[index]),
                );
              },
              loading: () => CircularProgressIndicator(),
              error: (_, __) => const SizedBox(),
            ),

            const SizedBox(height: AppSpacing.lg),

            // PRODUCTS
            _sectionHeader(context, 'Featured Products'),
            productsAsync.when(
              data: (products) {
                final featured = products.take(4).toList();
                return GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  childAspectRatio: 0.60,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  children: featured
                      .map((p) => ProductCard(product: p))
                      .toList(),
                );
              },
              loading: () => CircularProgressIndicator(),
              error: (_, __) => const SizedBox(),
            ),

            const SizedBox(height: AppSpacing.lg),

            // PROPERTIES
            _sectionHeader(context, 'Featured Properties'),
            propertiesAsync.when(
              data: (properties) {
                final featured = properties.take(3).toList();
                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
                  itemCount: featured.length,
                  itemBuilder: (context, index) =>
                      PropertyCard(property: featured[index]),
                );
              },
              loading: () => CircularProgressIndicator(),
              error: (_, __) => const SizedBox(),
            ),

            const SizedBox(height: AppSpacing.xl),
          ],
        ),
      ),
    );
  }

  // SECTION HEADER
  Widget _sectionHeader(BuildContext context, String title) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          TextButton(
            onPressed: () {},
            child: Text(
              'View All',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 🔥 BANNER WITH URL BUTTON
Widget _buildBanner(
  BuildContext context, {
  required String image,
  required String title,
  required String subtitle,
  String? url,
  String? ctaText,
}) {
  return Container(
    margin: EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 6),
    child: ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: Stack(
        fit: StackFit.expand,
        children: [

          /// IMAGE
          Image.network(image, fit: BoxFit.cover),

          /// DARK OVERLAY
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                  Theme.of(context).colorScheme.onSurface.withOpacity(0.2),
                ],
                begin: Alignment.bottomLeft,
                end: Alignment.topRight,
              ),
            ),
          ),

          /// CONTENT
          Padding(
  padding: EdgeInsets.all(20),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Text(
        title,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Theme.of(context).colorScheme.surface,
              fontWeight: FontWeight.bold,
            ),
      ),

      const SizedBox(height: AppSpacing.xs),

      Text(
        subtitle,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.white70,
            ),
      ),

      const SizedBox(height: AppSpacing.sm),

      /// 🔥 CLICKABLE "LEARN MORE →"
      if (url != null && url.isNotEmpty)
        GestureDetector(
          onTap: () async {
            final uri = Uri.parse(url);
            if (await canLaunchUrl(uri)) {
              await launchUrl(
                uri,
                mode: LaunchMode.externalApplication,
              );
            }
          },
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
            Text(
              ctaText ?? "Learn more",
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontSize: 14,
                fontWeight: FontWeight.w600,
                decoration: TextDecoration.underline,
                ),
              ),
              const SizedBox(width: 6),
              Icon(
                Icons.arrow_forward,
                size: 16,
                color: Theme.of(context).colorScheme.surface,
              ),
            ],
          ),
        ),
    ],
    ),
  ),
        ],
      ),
    ),
  );
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
