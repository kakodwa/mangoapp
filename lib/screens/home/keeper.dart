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
// Assuming RegisterScreen is located here, update import path accordingly:
// import '../../screens/auth/register_screen.dart'; 
import '../about/how_it_works.dart';
import '../about/tour.dart';

import '../../services/analytics_service.dart'; 

// A simple mock class structure mirroring your banner model if it doesn't match exactly
class BannerModel {
  final String imageUrl;
  final String title;
  final String subtitle;
  final String? url;
  final String? ctaText;

  const BannerModel({
    required this.imageUrl,
    required this.title,
    required this.subtitle,
    this.url,
    this.ctaText,
  });
}

class HomeScreen extends ConsumerStatefulWidget {
  final VoidCallback onDeliveryTap;
  
  const HomeScreen({
    super.key,
    required this.onDeliveryTap,
  });

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final ScrollController controller = ScrollController();
  final PageController bannerController = PageController(); 
  final AnalyticsService _analytics = AnalyticsService(); 
  int bannerIndex = 0;

  @override
  void initState() {
    super.initState();

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
        // Updated to account for the default asset banner we inject in UI
        final bannersData = ref.read(bannersProvider).valueOrNull ?? [];
        final totalCount = bannersData.length + 1; // +1 for the default banner

        if (totalCount > 0) {
          final nextIndex = (bannerIndex + 1) % totalCount;
          
          if (bannerController.hasClients) {
            bannerController.animateToPage(
              nextIndex,
              duration: const Duration(milliseconds: 350),
              curve: Curves.easeOutCubic,
            );
          }
        }
      }

      return mounted;
    });
  }

  @override
  void dispose() {
    controller.dispose(); 
    bannerController.dispose(); 
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
                data: (fetchedBanners) {
                  // 1. Create your default onboarding banner instance
                  final defaultBanner = BannerModel(
                    imageUrl: 'assets/images/banner.png',
                    title: 'Open Your Shop on MangoHub and Start Selling Your Products Today',
                    subtitle: '', // Kept empty as the title holds the instructions
                    ctaText: 'Join now',
                  );

                  // 2. Prepend the default banner into the list
                  final List<dynamic> combinedBanners = [defaultBanner, ...fetchedBanners];

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
                          child: PageView.builder(
                            controller: bannerController,
                            itemCount: combinedBanners.length,
                            onPageChanged: (index) {
                              bannerIndex = index;
                            },
                            itemBuilder: (context, index) {
                              final banner = combinedBanners[index];
                              
                              return Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 2.0),
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(14),
                                  onTap: () {
                                    _analytics.logEvent(
                                      'banner_click_${banner.title.replaceAll(' ', '_').toLowerCase()}',
                                    );

                                    // Check if this is the first (default) banner targeted to Register Screen
                                    if (index == 0) {
                                      // Replace 'RegisterScreen()' with your actual targeted register widget name
                                      // Navigator.push(
                                      //   context,
                                      //   MaterialPageRoute(builder: (_) => const RegisterScreen()),
                                      // );
                                    }
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
                              );
                            },
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        SmoothPageIndicator(
                          controller: bannerController,
                          count: combinedBanners.length,
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
                  padding: EdgeInsets.all(16),
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
                          _analytics.logEvent('click_scan_ticket');
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
    // Determine whether to parse as local asset path or an image web URL
    final bool isAsset = image.startsWith('assets/');

    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Background Color Fallback if the asset or network image has transparency
          Container(color: Colors.orange),
          
          isAsset
              ? Image.asset(
                  image,
                  fit: BoxFit.cover,
                )
              : Image.network(
                  image,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(color: Colors.orange),
                ),
          Container(
            color: Colors.black.withOpacity(0.35), // Shaded blend overlay for readability
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (subtitle.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Text(
                          subtitle,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (ctaText != null && ctaText.isNotEmpty) ...[
                  const SizedBox(width: 12),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.orange.shade800,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    ),
                    onPressed: () {
                      // Trigger fallback execution or same logic as banner container click
                      _analytics.logEvent('banner_cta_click');
                      // Implement navigation here if needed, or rely on parent InkWell
                    },
                    child: Text(
                      ctaText,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ]
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// --- QUICK ACTION BUTTON WIDGET ---
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
            borderRadius: BorderRadius.circular(16),
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
            borderRadius: BorderRadius.circular(16),
            onTap: widget.onTap,
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
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