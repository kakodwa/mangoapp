// lib/screens/products/product_details_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../providers/products_provider.dart';
import '../../providers/shops_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/api_provider.dart' as api;

import '../../models/product_model.dart';

import '../products/product_card.dart';

import '../shops/shop_details_screen.dart';
import '../products/edit_product_screen.dart';
import '../auth/login_screen.dart';

import '../../widgets/app_fab.dart';
import '../../widgets/main_app_bar.dart';

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
  final int _quantity = 1;
  int _currentIndex = 0;

  // related products
  final ScrollController _scrollController = ScrollController();
  final List<Product> _related = [];
  bool _loadingMore = false;
  
  // Track viewed state to avoid duplicate triggers during local UI builds
  bool _hasLoggedView = false;

  void _toast(String msg) {
    AppToast.info(context, msg);
  }

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

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: productAsync.when(
          data: (p) => Text(p.name),
          loading: () => const Text('Loading...'),
          error: (_, __) => const Text('Product'),
        ),
      ),

      body: productAsync.when(
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
              CustomScrollView(
                controller: _scrollController,
                slivers: [

                  // ================= IMAGE CAROUSEL
                  SliverAppBar(
                    automaticallyImplyLeading: false,
                    expandedHeight: 340,
                    pinned: false,
                    flexibleSpace: FlexibleSpaceBar(
                      background: Stack(
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
                          // Slider Modern Dot Indicators Layout
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

                          Row(
                            children: [
                              const Icon(Icons.star_rounded, color: Colors.amber, size: 20),
                              const SizedBox(width: 4),
                              Text(
                                "${product.rating} (${product.totalReviews})",
                                style: AppTypography.bodyMedium,
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

                          Text(
                            "Description",
                            style: AppTypography.headlineMedium,
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            product.description,
                            style: AppTypography.bodyMedium.copyWith(
                              color: Colors.grey.shade700,
                              height: 1.5,
                            ),
                          ),
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
                    child: SizedBox(height: 120), // Padding allowance for Floating buttons overlay space depth
                  ),
                ],
              ),

              // ================= RESTORED ORIGINAL FLOATING BUTTON UTILITY STACK
              Positioned(
                bottom: 50,
                right: 10,
                child: Column(
                  children: [

                    // 🛒 CART (PRIMARY ACTION - KEEP ORANGE)
                    if (product.isInStock && !isOwner)
                      AppFab(
                        heroTag: "cart",
                        icon: Icons.shopping_cart,
                        tooltip: "Add to Cart",
                        toastMessage: "Added to cart",
                        onPressed: () {
                          if (!isLoggedIn) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const LoginScreen()),
                            );
                            return;
                          }

                          // 📊 TRACK EVENT: Product added to cart from details page
                          analytics.logEvent('product_details_add_to_cart_${product.id}');

                          ref.read(addToCartProvider).call(product, _quantity);
                        },
                      ),
                    
                    if (product.isInStock && !isOwner)
                      const SizedBox(height: AppSpacing.sm),

                    // ❤️ FAVORITE
                    if (!isOwner)
                      AppFab(
                        heroTag: "fav",
                        icon: Icons.favorite_border,
                        tooltip: "Favorite",
                        toastMessage: "Updated favorites",
                        onPressed: () {
                          if (!isLoggedIn) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const LoginScreen()),
                            );
                            return;
                          }

                          // 📊 TRACK EVENT: Product toggled to favorite from details page
                          analytics.logEvent('product_details_favorite_toggle_${product.id}');

                          ref.read(favoriteProvider.notifier).toggle(product.id);
                        },
                      ),

                    if (!isOwner)
                      const SizedBox(height: AppSpacing.sm),

                    // 💬 WHATSAPP
                    AppFab(
                      heroTag: "whatsapp",
                      icon: FontAwesomeIcons.whatsapp,
                      tooltip: "Chat on WhatsApp",
                      toastMessage: "Opening WhatsApp...",
                      onPressed: () {
                        if (!isLoggedIn) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const LoginScreen()),
                          );
                          return;
                        }

                        final phone = product.shopPhoneNumber;

                        if (phone == null || phone.isEmpty) {
                          AppToast.info(context, "No WhatsApp number available");
                          return;
                        }

                        // 📊 TRACK EVENT: Click to contact vendor on WhatsApp
                        analytics.logEvent('product_whatsapp_contact_${product.id}');

                        _openWhatsApp(phone);
                      },
                    ),

                    const SizedBox(height: AppSpacing.sm),

                    // 🏪 SHOP
                    AppFab(
                      heroTag: "shop",
                      icon: Icons.storefront,
                      tooltip: "View Shop",
                      onPressed: () {
                        // 📊 TRACK EVENT: Navigating to shop overview from product
                        analytics.logEvent('product_view_shop_click_${product.shopId}');

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ShopDetailsScreen(shopId: product.shopId),
                          ),
                        );
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
                          // 📊 TRACK EVENT: Owner editing product from details page
                          analytics.logEvent('product_details_owner_edit_${product.id}');

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => EditProductScreen(product: product),
                            ),
                          );
                        },
                      ),
                    ],
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