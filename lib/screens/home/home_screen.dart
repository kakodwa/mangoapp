// lib/screens/home/home_screen.dart

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
import '../../screens/products/product_constants.dart';

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
  String? _selectedHomeCategory;

  // Escrow overlay state
  OverlayEntry? _dropdownOverlayEntry;
  int? _activeOverlayStepIndex;

  late AnimationController _bounceController;
  late Animation<double> _bounceScale;

  // ---------------------------------------------------------------------------
  // QUICK SEARCH / CATEGORY ITEMS
  // ---------------------------------------------------------------------------

  final List<Map<String, String>> _quickSearchTypes = [
    {
      'key': 'all',
      'label': 'All items',
      'image': 'https://www.malatrade.com/media/mobile/all.png',
    },
    {
      'key': 'electronics',
      'label': 'Electronics',
      'image': 'https://www.malatrade.com/media/mobile/Electronics.png',
    },
    {
      'key': 'groceries',
      'label': 'Groceries',
      'image': 'https://www.malatrade.com/media/mobile/Oil.png',
    },
    {
      'key': 'Fashion_Clothing',
      'label': 'Fashion & Clothing',
      'image': 'https://www.malatrade.com/media/mobile/fashion.png',
    },
    {
      'key': 'home_living',
      'label': 'Home & Living',
      'image': 'https://www.malatrade.com/media/mobile/Home.png',
    },
    {
      'key': 'beauty_care',
      'label': 'Beauty & Personal Care',
      'image': 'https://www.malatrade.com/media/mobile/Beauty.png',
    },
    {
      'key': 'health_wellness',
      'label': 'Health & Wellness',
      'image': 'https://www.malatrade.com/media/mobile/food.png',
    },
    {
      'key': 'agriculture',
      'label': 'Agriculture',
      'image': 'https://www.malatrade.com/media/mobile/Goat.png',
    },
    {
      'key': 'vehicles',
      'label': 'Vehicles',
      'image': 'https://www.malatrade.com/media/mobile/Car.png',
    },
    {
      'key': 'hardware',
      'label': 'Construction & Hardware',
      'image': 'https://www.malatrade.com/media/mobile/all.png',
    },
    {
      'key': 'books_education',
      'label': 'Books & Education',
      'image': 'https://www.malatrade.com/media/mobile/all.png',
    },
    {
      'key': 'sports_outdoors',
      'label': 'Sports & Outdoors',
      'image': 'https://www.malatrade.com/media/mobile/all.png',
    },
    {
      'key': 'baby_kids',
      'label': 'Baby & Kids',
      'image': 'https://www.malatrade.com/media/mobile/all.png',
    },
    {
      'key': 'food_beverages',
      'label': 'Food & Beverages',
      'image': 'https://www.malatrade.com/media/mobile/all.png',
    },
    {
      'key': 'pets_animals',
      'label': 'Pets & Animals',
      'image': 'https://www.malatrade.com/media/mobile/all.png',
    },
    {
      'key': 'office_supplies',
      'label': 'Office Supplies',
      'image': 'https://www.malatrade.com/media/mobile/all.png',
    },
    {
      'key': 'entertainment',
      'label': 'Entertainment',
      'image': 'https://www.malatrade.com/media/mobile/all.png',
    },
    {
      'key': 'services',
      'label': 'Services',
      'image': 'https://www.malatrade.com/media/mobile/alll.png',
    },
    {
      'key': 'industrial',
      'label': 'Industrial Equipment',
      'image': 'https://www.malatrade.com/media/mobile/all.png',
    },
    {
      'key': 'shop',
      'label': 'Shops',
      'image': 'https://www.malatrade.com/media/mobile/all.png',
    },
    {
      'key': 'property',
      'label': 'Properties',
      'image': 'https://www.malatrade.com/media/mobile/all.png',
    },
    {
      'key': 'lodge',
      'label': 'Lodges',
      'image': 'https://www.malatrade.com/media/mobile/all.png',
    },
    {
      'key': 'event',
      'label': 'Events',
      'image': 'https://www.malatrade.com/media/mobile/all.png',
    },
  ];

  // ---------------------------------------------------------------------------
  // MALATRADE ESCROW / DELIVERY PROCESS
  // ---------------------------------------------------------------------------

  final List<Map<String, dynamic>> _escrowStages = [
    {
      'step': 1,
      'title': 'Pay Securely',
      'subtitle': 'Airtel Money, Mpamba or Card',
      'icon': Icons.payment_outlined,
      'color': Colors.orange,
      'details': [
        'Complete your checkout securely through PayChangu.',
        'Pay using Airtel Money, TNM Mpamba, Visa or Mastercard.',
        'A digital receipt is generated after successful payment.',
      ],
    },
    {
      'step': 2,
      'title': 'Money Protected',
      'subtitle': 'Your payment is held securely in MalaTrade Escrow',
      'icon': Icons.shield_outlined,
      'color': Colors.green,
      'details': [
        'Your payment is held securely in MalaTrade Escrow.',
        'The seller does not receive the money until you receive and verify your order.',
        'This helps protect you against missing or incorrect items.',
      ],
    },
    {
      'step': 3,
      'title': 'Seller Pickup Code',
      'subtitle': 'Seller gives the code to the Courier/Rider',
      'icon': Icons.qr_code_scanner_rounded,
      'color': Colors.orange,
      'details': [
        'The seller prepares your order for dispatch.',
        'A secure Seller Pickup Code is generated for collection.',
        'The Courier/Rider uses the code to verify the seller pickup.',
      ],
    },
    {
      'step': 4,
      'title': 'Courier Delivery',
      'subtitle': 'Courier uses the code to access the delivery route',
      'icon': Icons.local_shipping_outlined,
      'color': Colors.green,
      'details': [
        'The Courier/Rider enters the Seller Pickup Code.',
        'The delivery location and route become available.',
        'You can follow the order status while it is in transit.',
      ],
    },
    {
      'step': 5,
      'title': 'Buyer Verification',
      'subtitle': 'Inspect your order and provide your Customer Code',
      'icon': Icons.verified_user_outlined,
      'color': Colors.orange,
      'details': [
        'The Courier/Rider delivers your order.',
        'Inspect the items to make sure they match your order.',
        'Give your Customer Delivery Code after confirming the order.',
        'If you receive the item but do not provide the code, funds are automatically released after 2 days.',
      ],
    },
    {
      'step': 6,
      'title': 'Escrow Payout',
      'subtitle': 'Funds are released after successful verification',
      'icon': Icons.account_balance_wallet_outlined,
      'color': Colors.green,
      'details': [
        'The Customer Code confirms successful delivery.',
        'The order is marked as completed and funds move to the seller wallet.',
        'Sellers can withdraw their earnings to mobile money or a bank account.',
        'If the Customer Code is not provided, funds automatically release after 2 days.',
      ],
    },
  ];

  // ---------------------------------------------------------------------------
  // INIT
  // ---------------------------------------------------------------------------

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
      _hideDropdownOverlay();

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
        final dbBanners =
            ref.read(bannersProvider).valueOrNull ?? [];

        final filteredBanners = dbBanners.where((banner) {
          final String sub = (banner.subtitle ?? '').trim();

          return sub != 'text banner' &&
              sub != 'install app';
        }).toList();

        final totalBannersCount =
            filteredBanners.length + 1;

        if (totalBannersCount > 0) {
          final nextIndex =
              (bannerIndex + 1) % totalBannersCount;

          if (bannerController.hasClients) {
            bannerController.animateToPage(
              nextIndex,
              duration:
                  const Duration(milliseconds: 350),
              curve: Curves.easeOutCubic,
            );
          }
        }
      }

      return mounted;
    });
  }

  // ---------------------------------------------------------------------------
  // ESCROW OVERLAY
  // ---------------------------------------------------------------------------

  void _hideDropdownOverlay() {
    _dropdownOverlayEntry?.remove();
    _dropdownOverlayEntry = null;

    if (_activeOverlayStepIndex != null && mounted) {
      setState(() {
        _activeOverlayStepIndex = null;
      });
    } else {
      _activeOverlayStepIndex = null;
    }
  }

  void _toggleDropdownOverlay(
    BuildContext cardContext,
    Map<String, dynamic> stage,
  ) {
    final int step = stage['step'];

    if (_activeOverlayStepIndex == step) {
      _hideDropdownOverlay();
      return;
    }

    _hideDropdownOverlay();

    final RenderBox? renderBox =
        cardContext.findRenderObject() as RenderBox?;

    if (renderBox == null || !renderBox.hasSize) {
      return;
    }

    final Offset offset =
        renderBox.localToGlobal(Offset.zero);

    final Size size = renderBox.size;

    final Color iconColor = stage['color'];

    final List<String> details =
        List<String>.from(stage['details']);

    final mediaQuery = MediaQuery.of(context);

    final double screenWidth =
        mediaQuery.size.width;

    final double screenHeight =
        mediaQuery.size.height;

    // Responsive popup width.
    final double overlayWidth =
        screenWidth < 360
            ? screenWidth - 32
            : screenWidth < 500
                ? screenWidth - 28
                : 320;

    // Keep popup inside horizontal screen boundaries.
    double left = offset.dx;

    if (left + overlayWidth >
        screenWidth - 12) {
      left = screenWidth -
          overlayWidth -
          12;
    }

    if (left < 12) {
      left = 12;
    }

    // Approximate popup height.
    const double estimatedPopupHeight = 260;

    // Normally open below the card.
    double top = offset.dy + size.height + 6;

    // If there isn't enough space below, open above.
    if (top + estimatedPopupHeight >
            screenHeight - 12 &&
        offset.dy > estimatedPopupHeight + 20) {
      top = offset.dy -
          estimatedPopupHeight -
          6;
    }

    _dropdownOverlayEntry = OverlayEntry(
      builder: (overlayContext) {
        return Stack(
          children: [
            // -----------------------------------------------------------------
            // TRANSPARENT DISMISS BARRIER
            // -----------------------------------------------------------------

            Positioned.fill(
              child: GestureDetector(
                behavior:
                    HitTestBehavior.translucent,
                onTap: _hideDropdownOverlay,
                child: const SizedBox.expand(),
              ),
            ),

            // -----------------------------------------------------------------
            // FLOATING DETAILS CARD
            // -----------------------------------------------------------------

            Positioned(
              left: left,
              top: top,
              width: overlayWidth,
              child: Material(
                color: Colors.transparent,
                child: Container(
                  constraints:
                      const BoxConstraints(
                    maxHeight: 420,
                  ),
                  padding:
                      const EdgeInsets.all(14),
                  decoration:
                      BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                        BorderRadius.circular(14),
                    border: Border.all(
                      color: iconColor.withOpacity(0.35),
                      width: 1.3,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color:
                            Colors.black.withOpacity(0.12),
                        blurRadius: 18,
                        spreadRadius: 1,
                        offset:
                            const Offset(0, 7),
                      ),
                    ],
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize:
                          MainAxisSize.min,
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        // -----------------------------------------------------
                        // POPUP HEADER
                        // -----------------------------------------------------

                        Row(
                          children: [
                            Container(
                              width: 34,
                              height: 34,
                              decoration:
                                  BoxDecoration(
                                color: iconColor
                                    .withOpacity(0.10),
                                shape:
                                    BoxShape.circle,
                              ),
                              child: Icon(
                                stage['icon'],
                                color:
                                    iconColor,
                                size: 19,
                              ),
                            ),

                            const SizedBox(
                              width: 9,
                            ),

                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'STEP ${stage['step']}',
                                    style:
                                        TextStyle(
                                      fontSize: 9,
                                      fontWeight:
                                          FontWeight.bold,
                                      letterSpacing:
                                          0.7,
                                      color:
                                          iconColor,
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 1,
                                  ),
                                  Text(
                                    stage['title'],
                                    maxLines: 2,
                                    overflow:
                                        TextOverflow
                                            .ellipsis,
                                    style:
                                        const TextStyle(
                                      fontWeight:
                                          FontWeight.bold,
                                      fontSize: 13,
                                      color:
                                          Colors.black87,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            InkWell(
                              borderRadius:
                                  BorderRadius.circular(
                                      20),
                              onTap:
                                  _hideDropdownOverlay,
                              child: const Padding(
                                padding:
                                    EdgeInsets.all(4),
                                child: Icon(
                                  Icons
                                      .close_rounded,
                                  size: 18,
                                  color:
                                      Colors.grey,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(
                          height: 12,
                        ),

                        // -----------------------------------------------------
                        // DETAIL POINTS
                        // -----------------------------------------------------

                        ...details.map(
                          (point) {
                            return Padding(
                              padding:
                                  const EdgeInsets
                                      .only(
                                bottom: 9,
                              ),
                              child: Row(
                                crossAxisAlignment:
                                    CrossAxisAlignment
                                        .start,
                                children: [
                                  Padding(
                                    padding:
                                        const EdgeInsets
                                            .only(
                                      top: 2,
                                    ),
                                    child: Icon(
                                      Icons
                                          .check_circle_rounded,
                                      size: 14,
                                      color:
                                          iconColor,
                                    ),
                                  ),

                                  const SizedBox(
                                    width: 8,
                                  ),

                                  Expanded(
                                    child: Text(
                                      point,
                                      style:
                                          const TextStyle(
                                        fontSize: 11,
                                        color:
                                            Colors.black87,
                                        height: 1.35,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );

    Overlay.of(context).insert(
      _dropdownOverlayEntry!,
    );

    if (mounted) {
      setState(() {
        _activeOverlayStepIndex = step;
      });
    }
  }

  // ---------------------------------------------------------------------------
  // DISPOSE
  // ---------------------------------------------------------------------------

  @override
  void dispose() {
    _dropdownOverlayEntry?.remove();
    _dropdownOverlayEntry = null;

    _activeOverlayStepIndex = null;

    _bounceController.dispose();
    controller.dispose();
    bannerController.dispose();

    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // DEFAULT BANNER ACTION
  // ---------------------------------------------------------------------------

  void _handleDefaultBannerTap() {
    _analytics.logEvent(
      'click_default_promo_banner',
    );

    final authState =
        ref.read(authProvider);

    final userShopsAsync =
        ref.read(userShopsProvider);

    final bool isAuthenticated =
        authState.isAuthenticated;

    final bool hasShop =
        userShopsAsync.valueOrNull?.isNotEmpty ??
            false;

    if (!isAuthenticated) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) =>
              const RegisterScreen(),
        ),
      );
    } else if (!hasShop) {
      MainTabsScreen.of(context)
          ?.navigateToCreateShop();
    } else {
      MainTabsScreen.of(context)
          ?.navigateToMyShop();
    }
  }

  // ---------------------------------------------------------------------------
  // LEFT CATEGORY PANEL
  // ---------------------------------------------------------------------------

  Widget _buildLeftCategoriesWidget({
    double height = 485,
  }) {
    if (_selectedHomeCategory == null) {
      return Container(
        width: 250,
        height: height,
        margin:
            const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius:
              BorderRadius.circular(14),
          border: Border.all(
            color: Colors.grey.shade200,
          ),
        ),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Container(
              padding:
                  const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 10,
              ),
              decoration: BoxDecoration(
                color: Theme.of(context)
                    .colorScheme
                    .primary
                    .withOpacity(0.08),
                borderRadius:
                    const BorderRadius.only(
                  topLeft:
                      Radius.circular(14),
                  topRight:
                      Radius.circular(14),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.category_rounded,
                    size: 18,
                    color: Theme.of(context)
                        .colorScheme
                        .primary,
                  ),
                  const SizedBox(
                    width: 8,
                  ),
                  Text(
                    'Categories',
                    style: TextStyle(
                      fontWeight:
                          FontWeight.bold,
                      fontSize: 13,
                      color: Theme.of(context)
                          .colorScheme
                          .primary,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.separated(
                itemCount: ProductConstants
                    .categories.length,
                separatorBuilder:
                    (_, __) => Divider(
                  height: 1,
                  color:
                      Colors.grey.shade100,
                ),
                itemBuilder:
                    (context, index) {
                  final category =
                      ProductConstants
                          .categories[index];

                  return ListTile(
                    dense: true,
                    visualDensity:
                        VisualDensity.compact,
                    title: Text(
                      category,
                      style:
                          const TextStyle(
                        fontSize: 12,
                        fontWeight:
                            FontWeight.w500,
                      ),
                    ),
                    trailing:
                        const Icon(
                      Icons.chevron_right,
                      size: 16,
                      color:
                          Colors.grey,
                    ),
                    onTap: () {
                      setState(() {
                        _selectedHomeCategory =
                            category;
                      });
                    },
                  );
                },
              ),
            ),
          ],
        ),
      );
    }

    final subCategoryMap =
        ProductConstants
                .categorySubCategoryBrands[
            _selectedHomeCategory!] ??
        {};

    final subCategories =
        subCategoryMap.keys.toList();

    return Container(
      width: 250,
      height: height,
      margin:
          const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(14),
        border: Border.all(
          color: Colors.grey.shade200,
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Container(
            padding:
                const EdgeInsets.symmetric(
              horizontal: 6,
              vertical: 6,
            ),
            decoration: BoxDecoration(
              color: Theme.of(context)
                  .colorScheme
                  .primary
                  .withOpacity(0.08),
              borderRadius:
                  const BorderRadius.only(
                topLeft:
                    Radius.circular(14),
                topRight:
                    Radius.circular(14),
              ),
            ),
            child: Row(
              children: [
                IconButton(
                  icon:
                      const Icon(
                    Icons.arrow_back,
                    size: 16,
                  ),
                  onPressed: () {
                    setState(() {
                      _selectedHomeCategory =
                          null;
                    });
                  },
                ),
                Expanded(
                  child: Text(
                    _selectedHomeCategory!,
                    maxLines: 1,
                    overflow:
                        TextOverflow.ellipsis,
                    style: TextStyle(
                      fontWeight:
                          FontWeight.bold,
                      fontSize: 12,
                      color: Theme.of(context)
                          .colorScheme
                          .primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: subCategories.isEmpty
                ? Center(
                    child: TextButton(
                      onPressed: () {
                        MainTabsScreen.of(
                                context)
                            ?.setSelectedIndex(
                          7,
                          searchType:
                              'product',
                          category:
                              _selectedHomeCategory,
                        );
                      },
                      child: Text(
                        "Explore $_selectedHomeCategory",
                      ),
                    ),
                  )
                : ListView.separated(
                    itemCount:
                        subCategories.length,
                    separatorBuilder:
                        (_, __) => Divider(
                      height: 1,
                      color:
                          Colors.grey.shade100,
                    ),
                    itemBuilder:
                        (context, index) {
                      final subCategory =
                          subCategories[
                              index];

                      return ListTile(
                        dense: true,
                        visualDensity:
                            VisualDensity
                                .compact,
                        title: Text(
                          subCategory,
                          style:
                              const TextStyle(
                            fontSize: 11,
                            fontWeight:
                                FontWeight
                                    .w400,
                          ),
                        ),
                        trailing:
                            const Icon(
                          Icons
                              .arrow_forward_ios,
                          size: 10,
                          color:
                              Colors.grey,
                        ),
                        onTap: () {
                          _analytics.logEvent(
                            'click_home_left_subcategory_$subCategory',
                          );

                          MainTabsScreen.of(
                                  context)
                              ?.setSelectedIndex(
                            7,
                            searchType:
                                'product',
                            searchQuery:
                                subCategory,
                            category:
                                _selectedHomeCategory,
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // ESCROW STAGE CARD
  // ---------------------------------------------------------------------------

  Widget _buildEscrowStageCard(
    Map<String, dynamic> stage,
  ) {
    final int step = stage['step'];

    final bool isSelected =
        _activeOverlayStepIndex == step;

    final Color iconColor =
        stage['color'];

    return Builder(
      builder: (cardContext) {
        return Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius:
                BorderRadius.circular(10),
            onTap: () =>
                _toggleDropdownOverlay(
              cardContext,
              stage,
            ),
            child: AnimatedContainer(
              duration:
                  const Duration(
                milliseconds: 200,
              ),
              padding:
                  const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 8,
              ),
              decoration:
                  BoxDecoration(
                color: isSelected
                    ? iconColor
                        .withOpacity(0.08)
                    : Colors.transparent,
                borderRadius:
                    BorderRadius.circular(10),
                border: Border.all(
                  color: isSelected
                      ? iconColor
                      : Colors.grey.shade200,
                  width:
                      isSelected ? 1.4 : 1,
                ),
              ),
              child: Row(
                crossAxisAlignment:
                    CrossAxisAlignment.center,
                children: [
                  // -----------------------------------------------------------
                  // ICON
                  // -----------------------------------------------------------

                  Container(
                    width: 38,
                    height: 38,
                    decoration:
                        BoxDecoration(
                      color: iconColor
                          .withOpacity(0.08),
                      borderRadius:
                          BorderRadius.circular(
                        9,
                      ),
                    ),
                    child: Icon(
                      stage['icon'],
                      size: 21,
                      color:
                          iconColor,
                    ),
                  ),

                  const SizedBox(
                    width: 9,
                  ),

                  // -----------------------------------------------------------
                  // TITLE + SUBTITLE
                  // -----------------------------------------------------------

                  Expanded(
                    child: Column(
                      mainAxisSize:
                          MainAxisSize.min,
                      crossAxisAlignment:
                          CrossAxisAlignment
                              .start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                '$step. ${stage['title']}',
                                style:
                                    const TextStyle(
                                  fontSize: 12,
                                  fontWeight:
                                      FontWeight.bold,
                                  color:
                                      Colors.black87,
                                ),
                                maxLines: 1,
                                overflow:
                                    TextOverflow
                                        .ellipsis,
                              ),
                            ),

                            const SizedBox(
                              width: 3,
                            ),

                            AnimatedRotation(
                              turns:
                                  isSelected
                                      ? 0.5
                                      : 0,
                              duration:
                                  const Duration(
                                milliseconds: 200,
                              ),
                              child: Icon(
                                Icons
                                    .keyboard_arrow_down_rounded,
                                size: 18,
                                color: isSelected
                                    ? iconColor
                                    : Colors.grey
                                        .shade600,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(
                          height: 3,
                        ),

                        Text(
                          stage['subtitle'],
                          maxLines: 1,
                          overflow:
                              TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight:
                                FontWeight.w500,
                            color:
                                Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // ---------------------------------------------------------------------------
  // FEATURE HIGHLIGHTS / ESCROW BAR
  // ---------------------------------------------------------------------------

  Widget _buildFeatureHighlightsBar(
    double screenWidth,
  ) {
    final bool isDesktop =
        screenWidth >= 900;

    return Container(
      margin:
          const EdgeInsets.only(top: 12),
      padding:
          const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey.shade200,
        ),
        boxShadow: [
          BoxShadow(
            color:
                Colors.black.withOpacity(0.025),
            blurRadius: 5,
            offset:
                const Offset(0, 2),
          ),
        ],
      ),
      child: isDesktop
          ? Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                // -------------------------------------------------------------
                // ROW 1
                // -------------------------------------------------------------

                Row(
                  children: [
                    Expanded(
                      child:
                          _buildEscrowStageCard(
                        _escrowStages[0],
                      ),
                    ),
                    const SizedBox(
                      width: 8,
                    ),
                    Expanded(
                      child:
                          _buildEscrowStageCard(
                        _escrowStages[1],
                      ),
                    ),
                    const SizedBox(
                      width: 8,
                    ),
                    Expanded(
                      child:
                          _buildEscrowStageCard(
                        _escrowStages[2],
                      ),
                    ),
                  ],
                ),

                const SizedBox(
                  height: 8,
                ),

                // -------------------------------------------------------------
                // ROW 2
                // -------------------------------------------------------------

                Row(
                  children: [
                    Expanded(
                      child:
                          _buildEscrowStageCard(
                        _escrowStages[3],
                      ),
                    ),
                    const SizedBox(
                      width: 8,
                    ),
                    Expanded(
                      child:
                          _buildEscrowStageCard(
                        _escrowStages[4],
                      ),
                    ),
                    const SizedBox(
                      width: 8,
                    ),
                    Expanded(
                      child:
                          _buildEscrowStageCard(
                        _escrowStages[5],
                      ),
                    ),
                  ],
                ),
              ],
            )
          : SingleChildScrollView(
              scrollDirection:
                  Axis.horizontal,
              physics:
                  const BouncingScrollPhysics(),
              child: Row(
                children:
                    _escrowStages.map(
                  (stage) {
                    return Padding(
                      padding:
                          const EdgeInsets
                              .only(
                        right: 8,
                      ),
                      child: SizedBox(
                        width:
                            screenWidth < 500
                                ? 230
                                : 250,
                        child:
                            _buildEscrowStageCard(
                          stage,
                        ),
                      ),
                    );
                  },
                ).toList(),
              ),
            ),
    );
  }

  // ---------------------------------------------------------------------------
  // BUILD
  // ---------------------------------------------------------------------------

  @override
  Widget build(
    BuildContext context,
  ) {
    final feed =
        ref.watch(homeFeedProvider);

    final bannersAsync =
        ref.watch(bannersProvider);

    final double screenWidth =
        MediaQuery.of(context).size.width;

    final bool isDesktop =
        screenWidth >= 900;

    return feed.when(
      loading: () =>
          const Center(
        child:
            CircularProgressIndicator(),
      ),
      error: (e, _) =>
          Center(
        child:
            Text(e.toString()),
      ),
      data: (items) {
        return CustomScrollView(
          controller: controller,
          slivers: [
            // =================================================================
            // 0. SEARCH BAR
            // =================================================================

            const SliverToBoxAdapter(
              child:
                  GlobalSearchInputBar(),
            ),

            // =================================================================
            // 1. BANNER + CATEGORIES + ESCROW
            // =================================================================

            SliverToBoxAdapter(
              child: bannersAsync.when(
                data: (banners) {
                  final validBanners =
                      banners.where(
                    (banner) {
                      final String sub =
                          (banner.subtitle ??
                                  '')
                              .trim();

                      return sub !=
                              'text banner' &&
                          sub !=
                              'install app';
                    },
                  ).toList();

                  final displayLength =
                      validBanners.length + 1;

                  // -----------------------------------------------------------
                  // MAIN BANNER SLIDER
                  // -----------------------------------------------------------

                  Widget bannerSlider =
                      Column(
                    children: [
                      AspectRatio(
                        aspectRatio:
                            isDesktop
                                ? (16 / 9)
                                : (2560 / 1440),
                        child:
                            PageView.builder(
                          controller:
                              bannerController,
                          itemCount:
                              displayLength,
                          onPageChanged:
                              (index) {
                            bannerIndex =
                                index;
                          },
                          itemBuilder:
                              (
                            context,
                            index,
                          ) {
                            if (index ==
                                validBanners
                                    .length) {
                              return ShopQrBanner(
                                onTap:
                                    _handleDefaultBannerTap,
                              );
                            }

                            final banner =
                                validBanners[
                                    index];

                            return Padding(
                              padding:
                                  const EdgeInsets
                                      .symmetric(
                                horizontal: 2,
                              ),
                              child:
                                  InkWell(
                                borderRadius:
                                    BorderRadius
                                        .circular(
                                  14,
                                ),
                                onTap: () {
                                  _analytics
                                      .logEvent(
                                    'banner_click_${banner.title.replaceAll(' ', '_').toLowerCase()}',
                                  );
                                },
                                child:
                                    _buildBanner(
                                  context,
                                  image: banner
                                      .imageUrl,
                                  title: banner
                                      .title,
                                  subtitle: banner
                                      .subtitle,
                                  url: banner
                                      .url,
                                  ctaText: banner
                                      .ctaText,
                                  screenWidth:
                                      screenWidth,
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
                        controller:
                            bannerController,
                        count:
                            displayLength,
                        effect:
                            WormEffect(
                          dotHeight: 8,
                          dotWidth: 8,
                          activeDotColor:
                              Theme.of(
                            context,
                          )
                                  .colorScheme
                                  .primary,
                        ),
                      ),
                    ],
                  );

                  // -----------------------------------------------------------
                  // RIGHT BANNERS
                  // -----------------------------------------------------------

                  Widget rightBannersList =
                      Column(
                    children: [
                      if (validBanners
                          .isNotEmpty) ...[
                        Expanded(
                          child:
                              InkWell(
                            borderRadius:
                                BorderRadius
                                    .circular(
                              14,
                            ),
                            onTap: () {
                              _analytics
                                  .logEvent(
                                'right_banner_click_0',
                              );
                            },
                            child:
                                _buildBanner(
                              context,
                              image:
                                  validBanners[
                                          0]
                                      .imageUrl,
                              title:
                                  validBanners[
                                          0]
                                      .title,
                              subtitle:
                                  validBanners[
                                          0]
                                      .subtitle,
                              screenWidth:
                                  screenWidth,
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 12,
                        ),
                      ],

                      if (validBanners.length >
                          1) ...[
                        Expanded(
                          child:
                              InkWell(
                            borderRadius:
                                BorderRadius
                                    .circular(
                              14,
                            ),
                            onTap: () {
                              _analytics
                                  .logEvent(
                                'right_banner_click_1',
                              );
                            },
                            child:
                                _buildBanner(
                              context,
                              image:
                                  validBanners[
                                          1]
                                      .imageUrl,
                              title:
                                  validBanners[
                                          1]
                                      .title,
                              subtitle:
                                  validBanners[
                                          1]
                                      .subtitle,
                              screenWidth:
                                  screenWidth,
                            ),
                          ),
                        ),
                      ] else ...[
                        Expanded(
                          child:
                              ShopQrBanner(
                            onTap:
                                _handleDefaultBannerTap,
                          ),
                        ),
                      ],
                    ],
                  );

                  // -----------------------------------------------------------
                  // DESKTOP / MOBILE LAYOUT
                  // -----------------------------------------------------------

                  return Align(
                    alignment:
                        Alignment.topCenter,
                    child: Container(
                      constraints:
                          const BoxConstraints(
                        maxWidth: 1200,
                      ),
                      margin:
                          const EdgeInsets
                              .symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      child: isDesktop
                          ? Row(
                              crossAxisAlignment:
                                  CrossAxisAlignment
                                      .start,
                              children: [
                                // ------------------------------------------------
                                // LEFT CATEGORIES
                                // ------------------------------------------------

                                _buildLeftCategoriesWidget(
                                  height:
                                      485,
                                ),

                                // ------------------------------------------------
                                // MAIN CONTENT
                                // ------------------------------------------------

                                Expanded(
                                  child:
                                      Column(
                                    children: [
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment
                                                .start,
                                        children: [
                                          Expanded(
                                            child:
                                                bannerSlider,
                                          ),

                                          Container(
                                            width:
                                                260,
                                            height:
                                                380,
                                            margin:
                                                const EdgeInsets
                                                    .only(
                                              left:
                                                  16,
                                            ),
                                            child:
                                                rightBannersList,
                                          ),
                                        ],
                                      ),

                                      // ==================================================
                                      // ESCROW / DELIVERY PROCESS
                                      // ==================================================

                                      _buildFeatureHighlightsBar(
                                        screenWidth,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            )
                          : Column(
                              children: [
                                bannerSlider,

                                _buildFeatureHighlightsBar(
                                  screenWidth,
                                ),
                              ],
                            ),
                    ),
                  );
                },
                loading: () =>
                    const Padding(
                  padding:
                      EdgeInsets.all(16),
                  child: Center(
                    child:
                        CircularProgressIndicator(),
                  ),
                ),
                error: (_, __) =>
                    const SizedBox(),
              ),
            ),

            // =================================================================
            // 2. SHOP BY CATEGORY
            // =================================================================

            SliverToBoxAdapter(
              child: Align(
                alignment:
                    Alignment.topCenter,
                child: Container(
                  constraints:
                      const BoxConstraints(
                    maxWidth: 1200,
                  ),
                  margin:
                      const EdgeInsets
                          .symmetric(
                    vertical: 8,
                  ),
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment
                            .start,
                    children: [
                      const Padding(
                        padding:
                            EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 6,
                        ),
                        child: Text(
                          'Shop by Category',
                          style:
                              TextStyle(
                            fontSize: 18,
                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),
                      ),

                      SizedBox(
                        height: 105,
                        child:
                            ListView.builder(
                          scrollDirection:
                              Axis.horizontal,
                          padding:
                              const EdgeInsets
                                  .symmetric(
                            horizontal: 12,
                          ),
                          itemCount:
                              _quickSearchTypes
                                  .length,
                          itemBuilder:
                              (
                            context,
                            index,
                          ) {
                            final type =
                                _quickSearchTypes[
                                    index];

                            final String
                                imageUrl =
                                type['image'] ??
                                    'https://www.malatrade.com/media/mobile/all.png';

                            return Padding(
                              padding:
                                  const EdgeInsets
                                      .only(
                                right: 16,
                              ),
                              child:
                                  InkWell(
                                borderRadius:
                                    BorderRadius
                                        .circular(
                                  35,
                                ),
                                onTap: () {
                                  final String
                                      key =
                                      type[
                                          'key']!;

                                  final String
                                      label =
                                      type[
                                          'label']!;

                                  _analytics
                                      .logEvent(
                                    'click_home_chip_$key',
                                  );

                                  const domainTypes =
                                      {
                                    'all',
                                    'product',
                                    'shop',
                                    'property',
                                    'lodge',
                                    'event',
                                  };

                                  if (domainTypes
                                      .contains(
                                          key)) {
                                    MainTabsScreen
                                            .of(
                                                context)
                                        ?.setSelectedIndex(
                                      7,
                                      searchType:
                                          key,
                                      category:
                                          null,
                                    );
                                  } else {
                                    MainTabsScreen
                                            .of(
                                                context)
                                        ?.setSelectedIndex(
                                      7,
                                      searchType:
                                          'product',
                                      category:
                                          label,
                                    );
                                  }
                                },
                                child:
                                    Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment
                                          .center,
                                  children: [
                                    Container(
                                      width:
                                          65,
                                      height:
                                          65,
                                      decoration:
                                          BoxDecoration(
                                        shape:
                                            BoxShape
                                                .circle,
                                        color: Colors
                                            .grey
                                            .shade100,
                                        border:
                                            Border.all(
                                          color: Colors
                                              .grey
                                              .shade300,
                                          width:
                                              1,
                                        ),
                                      ),
                                      child:
                                          ClipOval(
                                        child:
                                            Image.network(
                                          imageUrl,
                                          fit: BoxFit
                                              .cover,
                                          errorBuilder:
                                              (
                                            _,
                                            __,
                                            ___,
                                          ) =>
                                              Icon(
                                            Icons
                                                .category_outlined,
                                            color: Theme.of(
                                              context,
                                            )
                                                .colorScheme
                                                .primary,
                                            size:
                                                30,
                                          ),
                                        ),
                                      ),
                                    ),

                                    const SizedBox(
                                      height: 6,
                                    ),

                                    SizedBox(
                                      width:
                                          80,
                                      child:
                                          Text(
                                        type[
                                            'label']!,
                                        textAlign:
                                            TextAlign
                                                .center,
                                        maxLines:
                                            1,
                                        overflow:
                                            TextOverflow
                                                .ellipsis,
                                        style:
                                            TextStyle(
                                          fontSize:
                                              11,
                                          fontWeight:
                                              FontWeight
                                                  .w600,
                                          color: Theme.of(
                                            context,
                                          )
                                              .colorScheme
                                              .primary,
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
                    ],
                  ),
                ),
              ),
            ),

            // =================================================================
            // SPACING
            // =================================================================

            const SliverToBoxAdapter(
              child: SizedBox(
                height:
                    AppSpacing.sm,
              ),
            ),

            // =================================================================
            // 3. FEED
            // =================================================================

            FeedListWidget(
              items: items,
            ),

            // =================================================================
            // FOOTER SPACING
            // =================================================================

            const SliverToBoxAdapter(
              child: SizedBox(
                height: 24,
              ),
            ),

            // =================================================================
            // 4. WEB FOOTER
            // =================================================================

            SliverToBoxAdapter(
              child: WebFooter(
                onDeliveryTap:
                    widget.onDeliveryTap,
              ),
            ),
          ],
        );
      },
    );
  }

  // ---------------------------------------------------------------------------
  // BANNER BUILDER
  // ---------------------------------------------------------------------------

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
        borderRadius:
            BorderRadius.circular(14),
        child: Container(
          color: Theme.of(context)
              .colorScheme
              .surface,
          child: Stack(
            fit: StackFit.expand,
            children: [
              // ---------------------------------------------------------------
              // IMAGE
              // ---------------------------------------------------------------

              isAssetImage
                  ? Image.asset(
                      image,
                      fit: BoxFit.cover,
                      alignment:
                          Alignment.center,
                    )
                  : Image.network(
                      image,
                      fit: BoxFit.cover,
                      alignment:
                          Alignment.center,
                      errorBuilder:
                          (
                        context,
                        error,
                        stackTrace,
                      ) =>
                          Container(
                        color: Colors
                            .grey
                            .shade200,
                        child:
                            const Icon(
                          Icons
                              .broken_image,
                          color:
                              Colors.grey,
                        ),
                      ),
                    ),

              // ---------------------------------------------------------------
              // OVERLAY + TEXT
              // ---------------------------------------------------------------

              if (title.isNotEmpty ||
                  subtitle.isNotEmpty ||
                  showJoinButton) ...[
                Container(
                  color: Colors.black
                      .withOpacity(0.35),
                ),

                Padding(
                  padding:
                      EdgeInsets.all(
                    innerPadding,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          mainAxisAlignment:
                              MainAxisAlignment
                                  .center,
                          crossAxisAlignment:
                              CrossAxisAlignment
                                  .start,
                          children: [
                            if (title
                                .isNotEmpty)
                              Text(
                                title,
                                maxLines:
                                    2,
                                overflow:
                                    TextOverflow
                                        .ellipsis,
                                style:
                                    TextStyle(
                                  color:
                                      Colors.white,
                                  fontSize:
                                      titleSize,
                                  fontWeight:
                                      FontWeight
                                          .bold,
                                ),
                              ),

                            if (subtitle
                                .isNotEmpty) ...[
                              const SizedBox(
                                height: 4,
                              ),
                              Text(
                                subtitle,
                                maxLines:
                                    2,
                                overflow:
                                    TextOverflow
                                        .ellipsis,
                                style:
                                    TextStyle(
                                  color:
                                      Colors.white70,
                                  fontSize:
                                      subtitleSize,
                                ),
                              ),
                            ],

                            if (showJoinButton) ...[
                              SizedBox(
                                height:
                                    screenWidth >=
                                            800
                                        ? 10
                                        : 6,
                              ),
                              ElevatedButton(
                                style:
                                    ElevatedButton
                                        .styleFrom(
                                  backgroundColor:
                                      Theme.of(
                                    context,
                                  )
                                          .colorScheme
                                          .primary,
                                  foregroundColor:
                                      Colors.white,
                                  padding:
                                      EdgeInsets
                                          .symmetric(
                                    horizontal:
                                        buttonPaddingHorizontal,
                                    vertical:
                                        buttonPaddingVertical,
                                  ),
                                  shape:
                                      RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius
                                            .circular(
                                      8,
                                    ),
                                  ),
                                ),
                                onPressed:
                                    _handleDefaultBannerTap,
                                child:
                                    Text(
                                  'JOIN',
                                  style:
                                      TextStyle(
                                    fontWeight:
                                        FontWeight
                                            .bold,
                                    fontSize:
                                        subtitleSize,
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