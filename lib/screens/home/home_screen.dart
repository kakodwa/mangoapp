import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../../providers/feed/main_feed_providers.dart';
import '../../providers/products_provider.dart'; // contains bannersProvider

import '../../theme/design_system/app_spacing.dart';

import '../../widgets/feed/feed_list_widget.dart';

import '../../screens/delivery/delivery_code_entry_screen.dart';
import '../../screens/events/scan_ticket_screen.dart';
import '../../screens/shops/shops_list_screen.dart';
import '../about/how_it_works.dart';
import '../about/tour.dart';

import '../../services/analytics_service.dart'; 

class HomeScreen extends ConsumerStatefulWidget {
  final VoidCallback onDeliveryTap;
  final VoidCallback onTicketScanerTap;
  
  const HomeScreen({
    super.key,
    required this.onDeliveryTap,
    required this.onTicketScanerTap,
  });

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final ScrollController controller = ScrollController();
  final AnalyticsService _analytics = AnalyticsService(); // Analytics instance
  int bannerIndex = 0;

  @override
  void initState() {
    super.initState();

    // 📊 TRACK EVENT: App / HomeScreen Opened
    _analytics.logEvent('home_screen_open');

    controller.addListener(() {
      if (controller.position.pixels >
          controller.position.maxScrollExtent - 500) {
        ref.read(homeFeedProvider.notifier).loadMore();
      }
    });

    /// Auto rotate banners
    Future.doWhile(() async {
      await Future.delayed(
        const Duration(seconds: 4),
      );

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

  @override
  void dispose() {
    controller.dispose(); // Clean up controller memory
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final feed = ref.watch(homeFeedProvider);
    final bannersAsync = ref.watch(bannersProvider);

    return feed.when(
      loading: () => const Center(
        child: CircularProgressIndicator(),
      ),
      error: (e, _) => Center(
        child: Text(e.toString()),
      ),
      data: (items) {
        return CustomScrollView(
          controller: controller,
          slivers: [
            /// Banner
            SliverToBoxAdapter(
              child: bannersAsync.when(
                data: (banners) {
                  if (banners.isEmpty) {
                    return const SizedBox();
                  }

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
                          child: InkWell(
                            borderRadius: BorderRadius.circular(14),
                            // 📊 TRACK EVENT: Banner Item Interaction
                            onTap: () {
                              _analytics.logEvent('banner_click_${banner.title.replaceAll(' ', '_').toLowerCase()}');
                            },
                            child: _buildBanner(
                              context,
                              image: banner.imageUrl,
                              title: banner.title,
                              subtitle: banner.subtitle,
                              url: banner.url,
                              ctaText: banner.ctaText,
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        AnimatedSmoothIndicator(
                          activeIndex: bannerIndex,
                          count: banners.length,
                          effect: WormEffect(
                            dotHeight: 8,
                            dotWidth: 8,
                            activeDotColor:
                                Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                  );
                },
                loading: () => const Padding(
                  padding: EdgeInsets.all(
                    16,
                  ),
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
                error: (_, __) => const SizedBox(),
              ),
            ),

            const SliverToBoxAdapter(
              child: SizedBox(
                height: AppSpacing.sm,
              ),
            ),

            /// Quick Actions
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: _QuickActionButton(
                        icon: Icons.map_outlined,
                        label: 'Guide',
                        onTap: () {
                          // 📊 TRACK EVENT: Shops Clicked
                          _analytics.logEvent('click_Guide');
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const MangoHubScreen(),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(
                      width: AppSpacing.sm,
                    ),
                    Expanded(
                      child: _QuickActionButton(
                        icon: Icons.local_shipping,
                        label: 'Delivery',
                        onTap: () {
                          // 📊 TRACK EVENT: Delivery Clicked
                          _analytics.logEvent('click_delivery');
                          widget.onDeliveryTap();
                        }, 
                      ),
                    ),
                    const SizedBox(
                      width: AppSpacing.sm,
                    ),
                    Expanded(
                      child: _QuickActionButton(
                        icon: Icons.qr_code_scanner,
                        label: 'Scan Ticket',
                        onTap: () {
                          // 📊 TRACK EVENT: Scan Ticket Clicked
                          _analytics.logEvent('click_scan_ticket');
                          widget.onTicketScanerTap();
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),

            /// Feed
            FeedListWidget(
              items: items,
            ),

            const SliverToBoxAdapter(
              child: SizedBox(height: 40),
            ),
          ],
        );
      },
    );
  }

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
          Image.network(
            image,
            fit: BoxFit.cover,
          ),
          Container(
            color: Colors.black.withOpacity(0.4),
          ),
          Padding(
            padding: const EdgeInsets.all(
              16,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(
                  height: 6,
                ),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

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
      onTapDown: (_) => setState(() {
        _isPressed = true;
      }),
      onTapUp: (_) => setState(() {
        _isPressed = false;
      }),
      onTapCancel: () => setState(() {
        _isPressed = false;
      }),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _isPressed ? 0.95 : 1.0,
        duration: const Duration(
          milliseconds: 100,
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(
              16,
            ),
            color: Theme.of(context).colorScheme.surface,
            boxShadow: [
              BoxShadow(
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withOpacity(0.06),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(
              16,
            ),
            onTap: widget.onTap,
            child: Padding(
              padding: const EdgeInsets.all(
                AppSpacing.md,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    widget.icon,
                    size: 28,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(
                    height: AppSpacing.xs,
                  ),
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