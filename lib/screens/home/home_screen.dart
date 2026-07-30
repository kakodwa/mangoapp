import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../../providers/feed/main_feed_providers.dart';
import '../../providers/products_provider.dart'; 
import '../../providers/auth_provider.dart';
import '../../providers/shops_provider.dart';

import '../../theme/design_system/app_spacing.dart';

import '../../widgets/feed/feed_list_widget.dart';
import '../../widgets/web_footer.dart';

import '../../screens/search/global_search_input_bar.dart';

import '../../screens/shops/shop_qr_advert.dart';
import '../../screens/auth/register_screen.dart';

import '../main_tabs_screen.dart';

import '../../services/analytics_service.dart'; 

class HomeScreen extends ConsumerStatefulWidget {
  final VoidCallback onDeliveryTap;
  
  const HomeScreen({
    super.key,
    required this.onDeliveryTap,
  });

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with SingleTickerProviderStateMixin {
  final ScrollController controller = ScrollController();
  final PageController bannerController = PageController(); 
  final AnalyticsService _analytics = AnalyticsService(); 
  int bannerIndex = 0;

  // Bounce animation controllers
  late AnimationController _bounceController;
  late Animation<double> _bounceScale;

  final List<Map<String, String>> _quickSearchTypes = [
    {'key': 'all', 'label': 'All items', 'image': 'assets/images/all.png'},
    {'key': 'electronics', 'label': 'Electronics', 'image': 'assets/images/Electronics.png'},
    {'key': 'groceries', 'label': 'Groceries', 'image': 'assets/images/Oil.png'},
    {'key': 'Fashion_Clothing', 'label': 'Fashion & Clothing', 'image': 'assets/images/fashion.png'},
    {'key': 'home_living', 'label': 'Home & Living', 'image': 'assets/images/Home.png'},
    {'key': 'beauty_care', 'label': 'Beauty & Personal Care', 'image': 'assets/images/Beauty.png'},
    {'key': 'health_wellness', 'label': 'Health & Wellness', 'image': 'assets/images/food.png'},
    {'key': 'agriculture', 'label': 'Agriculture', 'image': 'assets/images/Goat.png'},
    {'key': 'vehicles', 'label': 'Vehicles', 'image': 'assets/images/Car.png'},
    {'key': 'hardware', 'label': 'Construction & Hardware', 'image': 'assets/images/all.png'},
    {'key': 'books_education', 'label': 'Books & Education', 'image': 'assets/images/all.png'},
    {'key': 'sports_outdoors', 'label': 'Sports & Outdoors', 'image': 'assets/images/all.png'},
    {'key': 'baby_kids', 'label': 'Baby & Kids', 'image': 'assets/images/all.png'},
    {'key': 'food_beverages', 'label': 'Food & Beverages', 'image': 'assets/images/all.png'},
    {'key': 'pets_animals', 'label': 'Pets & Animals', 'image': 'assets/images/all.png'},
    {'key': 'office_supplies', 'label': 'Office Supplies', 'image': 'assets/images/all.png'},
    {'key': 'entertainment', 'label': 'Entertainment', 'image': 'assets/images/all.png'},
    {'key': 'services', 'label': 'Services', 'image': 'assets/images/alll.png'},
    {'key': 'industrial', 'label': 'Industrial Equipment', 'image': 'assets/images/all.png'},
    {'key': 'shop', 'label': 'Shops', 'image': 'assets/images/all.png'},
    {'key': 'property', 'label': 'Properties', 'image': 'assets/images/all.png'},
    {'key': 'lodge', 'label': 'Lodges', 'image': 'assets/images/all.png'},
    {'key': 'event', 'label': 'Events', 'image': 'assets/images/all.png'},
  ];

  @override
  void initState() {
    super.initState();

    _analytics.logEvent('home_screen_open');

    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _bounceScale = Tween<double>(
      begin: 0.98,
      end: 1.02,
    ).animate(
      CurvedAnimation(
        parent: _bounceController,
        curve: Curves.easeInOut,
      ),
    );

    controller.addListener(() {
      if (controller.position.pixels >
          controller.position.maxScrollExtent - 500) {
        ref.read(homeFeedProvider.notifier).loadMore();
      }
    });

    Future.doWhile(() async {
      await Future.delayed(
        const Duration(seconds: 4),
      );

      if (mounted) {
        final dbBanners = ref.read(bannersProvider).valueOrNull ?? [];
        
        final filteredBanners = dbBanners.where((banner) {
          final String sub = (banner.subtitle ?? '').trim();
          return sub != 'text banner' && sub != 'install app';
        }).toList();

        final totalBannersCount = filteredBanners.length + 1;

        if (totalBannersCount > 0) {
          final nextIndex = (bannerIndex + 1) % totalBannersCount;
          
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
    _bounceController.dispose();
    controller.dispose(); 
    bannerController.dispose(); 
    super.dispose();
  }

  void _handleDefaultBannerTap() {
    _analytics.logEvent('click_default_promo_banner');

    final authState = ref.read(authProvider);
    final userShopsAsync = ref.read(userShopsProvider);

    final bool isAuthenticated = authState.isAuthenticated;
    final bool hasShop = userShopsAsync.valueOrNull?.isNotEmpty ?? false;

    if (!isAuthenticated) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const RegisterScreen(),
        ),
      );
    } else if (!hasShop) {
      MainTabsScreen.of(context)?.navigateToCreateShop();
    } else {
      MainTabsScreen.of(context)?.navigateToMyShop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final feed = ref.watch(homeFeedProvider);
    final bannersAsync = ref.watch(bannersProvider);
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isDesktop = screenWidth >= 900;

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
            /// 0. SEARCH BAR SECTION
            GlobalSearchInputBar.sliver(),

            /// 1. PROMO BANNER SECTION
            SliverToBoxAdapter(
              child: bannersAsync.when(
                data: (banners) {
                  final validBanners = banners.where((banner) {
                    final String sub = (banner.subtitle ?? '').trim();
                    return sub != 'text banner' && sub != 'install app';
                  }).toList();

                  final displayLength = validBanners.length + 1;

                  // Main Interactive Slider Banner
                  Widget bannerSlider = Column(
                    children: [
                      AspectRatio(
                        aspectRatio: isDesktop ? (16 / 9) : (2560 / 1440),
                        child: PageView.builder(
                          controller: bannerController,
                          itemCount: displayLength,
                          onPageChanged: (index) {
                            bannerIndex = index;
                          },
                          itemBuilder: (context, index) {
                            if (index == validBanners.length) {
                              return ShopQrBanner(
                                onTap: _handleDefaultBannerTap,
                              );
                            }

                            final banner = validBanners[index];
                            return Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 2.0),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(14),
                                onTap: () {
                                  _analytics.logEvent(
                                    'banner_click_${banner.title.replaceAll(' ', '_').toLowerCase()}',
                                  );
                                },
                                child: _buildBanner(
                                  context,
                                  image: banner.imageUrl,
                                  title: banner.title,
                                  subtitle: banner.subtitle,
                                  url: banner.url,
                                  ctaText: banner.ctaText,
                                  screenWidth: screenWidth,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 10),
                      SmoothPageIndicator(
                        controller: bannerController,
                        count: displayLength,
                        effect: WormEffect(
                          dotHeight: 8,
                          dotWidth: 8,
                          activeDotColor: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ],
                  );

                  // Right Side Vertical Banner List for Desktop
                  Widget rightBannersList = Column(
                    children: [
                      if (validBanners.isNotEmpty) ...[
                        Expanded(
                          child: InkWell(
                            borderRadius: BorderRadius.circular(14),
                            onTap: () {
                              _analytics.logEvent('right_banner_click_0');
                            },
                            child: _buildBanner(
                              context,
                              image: validBanners[0].imageUrl,
                              title: validBanners[0].title,
                              subtitle: validBanners[0].subtitle,
                              screenWidth: screenWidth,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],
                      if (validBanners.length > 1) ...[
                        Expanded(
                          child: InkWell(
                            borderRadius: BorderRadius.circular(14),
                            onTap: () {
                              _analytics.logEvent('right_banner_click_1');
                            },
                            child: _buildBanner(
                              context,
                              image: validBanners[1].imageUrl,
                              title: validBanners[1].title,
                              subtitle: validBanners[1].subtitle,
                              screenWidth: screenWidth,
                            ),
                          ),
                        ),
                      ] else ...[
                        Expanded(
                          child: ShopQrBanner(
                            onTap: _handleDefaultBannerTap,
                          ),
                        ),
                      ],
                    ],
                  );

                  return Align(
                    alignment: Alignment.topCenter,
                    child: Container(
                      constraints: const BoxConstraints(maxWidth: 1200),
                      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      child: isDesktop
                          ? Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Left Main Banner Slider
                                Expanded(child: bannerSlider),

                                // Right Vertical Banner Column
                                Container(
                                  width: 280,
                                  height: 380,
                                  margin: const EdgeInsets.only(left: 16),
                                  child: rightBannersList,
                                ),
                              ],
                            )
                          : bannerSlider,
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

            /// 2. DOMAIN & CATEGORY LIST
            SliverToBoxAdapter(
              child: Align(
                alignment: Alignment.topCenter,
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 1200),
                  height: 105,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    itemCount: _quickSearchTypes.length,
                    itemBuilder: (context, index) {
                      final type = _quickSearchTypes[index];
                      final String imagePath = type['image'] ?? 'assets/images/logo.png';

                      return Padding(
                        padding: const EdgeInsets.only(right: 16.0),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(35),
                          onTap: () {
                            final String key = type['key']!;
                            final String label = type['label']!;

                            _analytics.logEvent('click_home_chip_$key');
                            
                            const domainTypes = {
                              'all',
                              'product',
                              'shop',
                              'property',
                              'lodge',
                              'event'
                            };

                            if (domainTypes.contains(key)) {
                              MainTabsScreen.of(context)?.setSelectedIndex(
                                7,
                                searchType: key,
                                category: null,
                              );
                            } else {
                              MainTabsScreen.of(context)?.setSelectedIndex(
                                7,
                                searchType: 'product',
                                category: label,
                              );
                            }
                          },
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 65,
                                height: 65,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.grey.shade100,
                                  border: Border.all(
                                    color: Colors.grey.shade300,
                                    width: 1,
                                  ),
                                ),
                                child: ClipOval(
                                  child: Image.asset(
                                    imagePath,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => Icon(
                                      Icons.category_outlined,
                                      color: Theme.of(context).colorScheme.primary,
                                      size: 30,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 6),
                              SizedBox(
                                width: 80,
                                child: Text(
                                  type['label']!,
                                  textAlign: TextAlign.center,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: Theme.of(context).colorScheme.primary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),

            const SliverToBoxAdapter(
              child: SizedBox(
                height: AppSpacing.sm,
              ),
            ),

            /// Feed Content List
            FeedListWidget(
              items: items,
            ),

            const SliverToBoxAdapter(
              child: SizedBox(height: 24),
            ),

            /// 3. WEB/DESKTOP FOOTER (NEATLY ATTACHED BELOW ALL CONTENT)
            SliverToBoxAdapter(
              child: WebFooter(
                onDeliveryTap: widget.onDeliveryTap,
              ),
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
    required double screenWidth,
    String? url,
    String? ctaText,
    bool isAssetImage = false,
    bool showJoinButton = false,
  }) {
    double titleSize = 15.0;
    double subtitleSize = 11.0;
    double innerPadding = 12.0;
    double buttonPaddingHorizontal = 18.0;
    double buttonPaddingVertical = 6.0;

    if (screenWidth >= 1200) {
      titleSize = 18.0;
      subtitleSize = 13.0;
      innerPadding = 18.0;
      buttonPaddingHorizontal = 24.0;
      buttonPaddingVertical = 10.0;
    } else if (screenWidth >= 800) {
      titleSize = 16.0;
      subtitleSize = 12.0;
      innerPadding = 14.0;
      buttonPaddingHorizontal = 20.0;
      buttonPaddingVertical = 8.0;
    }

    return ScaleTransition(
      scale: _bounceScale,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Container(
          color: Theme.of(context).colorScheme.surface,
          child: Stack(
            fit: StackFit.expand,
            children: [
              isAssetImage
                  ? Image.asset(
                      image,
                      fit: BoxFit.cover,
                      alignment: Alignment.center,
                    )
                  : Image.network(
                      image,
                      fit: BoxFit.cover,
                      alignment: Alignment.center,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: Colors.grey.shade200,
                        child: const Icon(Icons.broken_image, color: Colors.grey),
                      ),
                    ),
              if (title.isNotEmpty || subtitle.isNotEmpty || showJoinButton) ...[
                Container(
                  color: Colors.black.withOpacity(0.35),
                ),
                Padding(
                  padding: EdgeInsets.all(innerPadding),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (title.isNotEmpty)
                              Text(
                                title,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: titleSize,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            if (subtitle.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Text(
                                subtitle,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: subtitleSize,
                                ),
                              ),
                            ],
                            if (showJoinButton) ...[
                              SizedBox(height: screenWidth >= 800 ? 10 : 6),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Theme.of(context).colorScheme.primary,
                                  foregroundColor: Colors.white,
                                  padding: EdgeInsets.symmetric(
                                    horizontal: buttonPaddingHorizontal, 
                                    vertical: buttonPaddingVertical,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                onPressed: _handleDefaultBannerTap,
                                child: Text(
                                  "JOIN",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: subtitleSize,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}