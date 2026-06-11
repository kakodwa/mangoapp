// lib/screens/products/product_details_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/foundation.dart';

import '../../providers/products_provider.dart';
import '../../providers/shops_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/api_provider.dart' as api;

import '../../models/product_model.dart';

import '../products/product_card.dart';

import '../shops/shop_details_screen.dart';
import '../main_tabs_screen.dart';
import '../products/edit_product_screen.dart';
import '../auth/login_screen.dart';

import '../../widgets/app_fab.dart';
import '../../widgets/reviews/review_section_widget.dart';

import '../../utils/app_toast.dart';
import '../../utils/app_snackbar.dart';

// Design System Imports
import '../../theme/design_system/app_spacing.dart';
import '../../theme/design_system/app_typography.dart';
import '../../theme/design_system/app_card.dart';
import '../../theme/design_system/app_badge.dart';
import '../../theme/app_colors.dart';

// Analytics Import
import '../../services/analytics_service.dart';

class ProductDetailsScreen extends ConsumerStatefulWidget {
  final int productId;

  const ProductDetailsScreen({
    Key? key,
    required this.productId,
  }) : super(key: key);

  @override
  ConsumerState<ProductDetailsScreen> createState() =>
      _ProductDetailsScreenState();
}

class _ProductDetailsScreenState
    extends ConsumerState<ProductDetailsScreen> {
  int _currentIndex = 0;

  // related products
  final ScrollController _scrollController = ScrollController();
  final List<Product> _related = [];
  bool _loadingMore = false;
  
  // Track viewed state to avoid duplicate triggers during local UI builds
  bool _hasLoggedView = false;

  // State variable to manage the dynamic FAB expansion menu
  bool _isMenuOpen = false;

  void _openWhatsApp(String phone) async {
    final uri = Uri.parse("https://wa.me/$phone");

    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      AppToast.info(context, "Could not open WhatsApp");
    }
  }

  Future<void> _loadRelated(int productId) async {
    if (_loadingMore) return;

    setState(() => _loadingMore = true);

    try {
      final apiClient = ref.read(api.apiClientProvider);

      final res = await apiClient.getList(
        'products/$productId/related/',
        fromJson: (json) => Product.fromJson(json),
      );

      setState(() {
        _related.addAll(res);
        _loadingMore = false;
      });
    } catch (e) {
      debugPrint("❌ RELATED ERROR: $e");
      setState(() => _loadingMore = false);
    }
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadRelated(widget.productId);
    });

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >
          _scrollController.position.maxScrollExtent - 200) {
        _loadRelated(widget.productId);
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final productAsync =
        ref.watch(productDetailsProvider(widget.productId));

    final auth = ref.watch(authProvider);
    final AnalyticsService analytics = AnalyticsService();

    return Material(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: productAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),

        error: (e, _) => Center(child: Text("Error: $e")),

        data: (product) {
          final isOwner = auth.user?.id == product.ownerId;
          final isLoggedIn = auth.isAuthenticated;

          // 📊 TRACK EVENT: Screen viewed by user
          if (!_hasLoggedView) {
            analytics.logEvent('product_view_${product.id}');
            _hasLoggedView = true;
          }

          final images = product.images.isNotEmpty
              ? product.images
              : [product.safeImage];

          return Stack(
            children: [
              DefaultTabController(
                length: 2,
                child: CustomScrollView(
                  controller: _scrollController,
                  slivers: [

                    // ================= IMAGE CAROUSEL FRAME
                    SliverToBoxAdapter(
                      child: SizedBox(
                        height: 340,
                        child: Stack(
                          alignment: Alignment.bottomCenter,
                          children: [
                            PageView.builder(
                              itemCount: images.length,
                              onPageChanged: (i) {
                                setState(() => _currentIndex = i);
                              },
                              itemBuilder: (_, i) {
                                return CachedNetworkImage(
                                  imageUrl: images[i],
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                );
                              },
                            ),
                            if (images.length > 1)
                              Positioned(
                                bottom: AppSpacing.md,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: List.generate(
                                    images.length,
                                    (index) => AnimatedContainer(
                                      duration: const Duration(milliseconds: 200),
                                      margin: const EdgeInsets.symmetric(horizontal: 4),
                                      height: 6,
                                      width: _currentIndex == index ? 16 : 6,
                                      decoration: BoxDecoration(
                                        color: _currentIndex == index
                                            ? AppColors.primary(context)
                                            : Colors.white.withOpacity(0.6),
                                        borderRadius: BorderRadius.circular(3),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),

                    // ================= INFO BLOCK
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              product.name,
                              style: AppTypography.displaySmall,
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            Text(
                              "MWK ${product.price}",
                              style: AppTypography.headlineLarge.copyWith(
                                color: AppColors.mangoOrange,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.sm),

                            // ================= INVENTORY STOCK BADGE
                            Row(
                              children: [
                                AppBadge(
                                  text: product.stock > 0
                                      ? "${product.stock} items in stock"
                                      : "Out of stock",
                                  type: product.stock > 0
                                      ? BadgeType.success
                                      : BadgeType.error,
                                ),
                              ],
                            ),
                            const SizedBox(height: AppSpacing.sm),

                            // ================= STAR RATING AND REVIEW ROW DISPLAY
                            Row(
                              children: [
                                ...List.generate(5, (index) {
                                  final currentStarValue = index + 1;
                                  if (product.rating >= currentStarValue) {
                                    return const Icon(Icons.star_rounded, color: Colors.amber, size: 22);
                                  } else if (product.rating > currentStarValue - 1 && product.rating < currentStarValue) {
                                    return const Icon(Icons.star_half_rounded, color: Colors.amber, size: 22);
                                  } else {
                                    return Icon(Icons.star_border_rounded, color: Colors.grey.shade400, size: 22);
                                  }
                                }),
                                const SizedBox(width: 6),
                                Text(
                                  "(${product.totalReviews} ${product.totalReviews == 1 ? 'review' : 'reviews'})",
                                  style: AppTypography.bodyMedium.copyWith(
                                    color: Colors.grey.shade600,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: AppSpacing.md),

                            // ================= SHOP INFO COMPONENT CARD
                            AppCard(
                              padding: const EdgeInsets.all(AppSpacing.md),
                              onTap: () {
                                analytics.logEvent('product_view_shop_click_${product.shopId}');
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => ShopDetailsScreen(shopId: product.shopId),
                                  ),
                                );
                              },
                              child: Row(
                                children: [
                                  Icon(Icons.storefront, color: AppColors.mangoOrange),
                                  const SizedBox(width: AppSpacing.sm),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          product.shopName,
                                          style: AppTypography.titleLarge,
                                        ),
                                        const SizedBox(height: 2),
                                        Row(
                                          children: [
                                            const Icon(Icons.location_on_outlined, size: 14, color: Colors.grey),
                                            const SizedBox(width: 4),
                                            Text(
                                              product.shopDistrict ?? 'Unknown',
                                              style: AppTypography.bodySmall.copyWith(color: Colors.grey),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  const Icon(Icons.chevron_right, color: Colors.grey),
                                ],
                              ),
                            ),
                            const SizedBox(height: AppSpacing.lg),

                            // ================= TAB BAR SECTION
                            TabBar(
                              labelColor: AppColors.primary(context),
                              unselectedLabelColor: Colors.grey,
                              indicatorColor: AppColors.primary(context),
                              tabs: const [
                                Tab(text: "Description"),
                                Tab(text: "Reviews"),
                              ],
                            ),
                            const SizedBox(height: AppSpacing.md),

                            // Dynamic section bound to TabController state
                            Builder(
                              builder: (context) {
                                final tabController = DefaultTabController.of(context);
                                return AnimatedBuilder(
                                  animation: tabController,
                                  builder: (context, child) {
                                    if (tabController.index == 0) {
                                      return Text(
                                        product.description,
                                        style: AppTypography.bodyMedium.copyWith(
                                          color: Colors.grey.shade700,
                                          height: 1.5,
                                        ),
                                      );
                                    } else {
                                      return ReviewSectionWidget(
                                        targetType: 'product',
                                        targetId: product.id,
                                        isOwner: isOwner,
                                      );
                                    }
                                  },
                                );
                              },
                            ),
                            const SizedBox(height: AppSpacing.lg),
                          ],
                        ),
                      ),
                    ),

                    // ================= RELATED PRODUCTS LIST
                    if (_related.isNotEmpty)
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.all(AppSpacing.md),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Related Products",
                                style: AppTypography.headlineMedium,
                              ),
                              const SizedBox(height: AppSpacing.md),

                              SizedBox(
                                height: 270,
                                child: ListView.separated(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: _related.length,
                                  separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.sm),
                                  itemBuilder: (context, index) {
                                    final p = _related[index];
                                    return SizedBox(
                                      width: 170,
                                      child: ProductCard(product: p),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    const SliverToBoxAdapter(
                      child: SizedBox(height: 120),
                    ),
                  ],
                ),
              ),

              // ================= EXPANDABLE SPEED DIAL FAB SYSTEM =================
              Positioned(
                bottom: 50,
                right: 10,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 🛒 PERMANENT CART BUTTON (Shared matching code pattern with ProductCard)
                    if (product.isInStock && !isOwner) ...[
                      AppFab(
                        heroTag: "cart",
                        icon: Icons.shopping_cart,
                        tooltip: "Add to Cart",
                        onPressed: () {
                          if (!isLoggedIn) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const LoginScreen()),
                            );
                            return;
                          }

                          // 📊 TRACK EVENT: Add to Cart button clicked
                          analytics.logEvent('product_add_to_cart_click_${product.id}');

                          ref.read(addToCartProvider).call(product, 1);
                          AppToast.success(context, "ADDED TO CART");
                        },
                      ),
                      const SizedBox(height: AppSpacing.sm),
                    ],

                    // Wrap optional elements inside AnimatedSize for smooth expanding dropdown transitions
                    AnimatedSize(
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeInOut,
                      child: Column(
                        children: [
                          if (_isMenuOpen) ...[
                            // ❤️ FAVORITE
                            if (!isOwner) ...[
                              AppFab(
                                heroTag: "fav",
                                icon: Icons.favorite_border,
                                tooltip: "Favorite",
                                onPressed: () {
                                  analytics.logEvent('product_fav_click_${product.id}');
                                  AppToast.success(context, "ADDED TO FAVORITES");
                                },
                              ),
                              const SizedBox(height: AppSpacing.sm),
                            ],

                            // 💬 WHATSAPP
                            AppFab(
                              heroTag: "whatsapp",
                              icon: FontAwesomeIcons.whatsapp,
                              tooltip: "Chat on WhatsApp",
                              onPressed: () {
                                if (product.phoneNumber.isNotEmpty) {
                                  analytics.logEvent('product_whatsapp_click_${product.id}');
                                  _openWhatsApp(product.phoneNumber);
                                } else {
                                  AppToast.info(context, "Shop phone number is unavailable");
                                }
                              },
                            ),
                            const SizedBox(height: AppSpacing.sm),

                            // 🔗 SHARE BUTTON
                            AppFab(
                              heroTag: "share_product",
                              icon: Icons.share_outlined,
                              tooltip: "Share Product",
                              onPressed: () async {
                                final String productUrl = kIsWeb 
                                    ? "${Uri.base.origin}/product/${product.id}"
                                    : "https://mangobackend-yayy.onrender.com/product/${product.id}";

                                final String shareMessage = "Check out ${product.name} on Mangochi Marketplace!\nPrice: MWK ${product.price}\n\nView details here: $productUrl";
                                
                                analytics.logEvent('product_shared_${product.id}');

                                final box = context.findRenderObject() as RenderBox?;
                                await Share.share(
                                  shareMessage,
                                  subject: 'Look what I found on Mangochi!',
                                  sharePositionOrigin: box != null ? box.localToGlobal(Offset.zero) & box.size : null,
                                );
                              },
                            ),
                            const SizedBox(height: AppSpacing.sm),

                            // 🏪 SHOP
                            AppFab(
                              heroTag: "shop",
                              icon: Icons.storefront,
                              tooltip: "View Shop",
                              onPressed: () {
                                analytics.logEvent('product_view_shop_fab_click_${product.shopId}');
                                final tabsScreen = MainTabsScreen.of(context);
                                if (tabsScreen != null) {
                                  tabsScreen.navigateToShopDetails(product.shopId);
                                  } else {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (_) => ShopDetailsScreen(shopId: product.shopId)),);
                                  }
                                  },
                                  ),

                            // ✏️ EDIT (OWNER ONLY)
                            if (isOwner) ...[
                              const SizedBox(height: AppSpacing.sm),
                              AppFab(
                                heroTag: "edit",
                                icon: Icons.edit,
                                tooltip: "Edit Product",
                                onPressed: () {
                                  analytics.logEvent('product_edit_click_${product.id}');
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => EditProductScreen(product: product),
                                    ),
                                  );
                                },
                              ),
                            ],
                            const SizedBox(height: AppSpacing.sm),
                          ],
                        ],
                      ),
                    ),

                    // 🔘 PRIMARY TOGGLE BUTTON (Dotted Menu)
                    AppFab(
                      heroTag: "menu_toggle",
                      icon: _isMenuOpen ? Icons.close : Icons.more_vert,
                      tooltip: "Show Options",
                      onPressed: () {
                        setState(() {
                          _isMenuOpen = !_isMenuOpen;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}