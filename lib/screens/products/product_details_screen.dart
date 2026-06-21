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
import '../../models/product_variant_model.dart'; // ✅ Imported your variant model

import '../products/product_card.dart';

import '../shops/shop_details_screen.dart';
import '../main_tabs_screen.dart';
import '../products/edit_product_screen.dart';
import '../auth/login_screen.dart';

import '../../widgets/app_fab.dart';
import '../../widgets/reviews/review_section_widget.dart';
import '../../widgets/web_footer.dart';

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

class _ProductDetailsScreenState extends ConsumerState<ProductDetailsScreen> {
  int _currentIndex = 0;
  final PageController _imagePageController = PageController();

  // related products
  final ScrollController _scrollController = ScrollController();
  final List<Product> _related = [];
  bool _loadingMore = false;
  
  // Track viewed state to avoid duplicate triggers during local UI builds
  bool _hasLoggedView = false;

  // State variable to manage the dynamic FAB expansion menu
  bool _isMenuOpen = false;

  // ✅ 1. Added state properties to track selected variant across product loads
  LocalProductVariant? _selectedVariant;
  int? _lastInitializedProductId;

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

  void _openFullScreenGallery(List<String> images, int initialIndex) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FullScreenImageGallery(
          images: images,
          initialIndex: initialIndex,
        ),
      ),
    );
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
    _imagePageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final productAsync = ref.watch(productDetailsProvider(widget.productId));
    final auth = ref.watch(authProvider);
    final AnalyticsService analytics = AnalyticsService();
    
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isDesktop = screenWidth >= 900;

    return productAsync.when(
      loading: () => const Center(
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.xl),
          child: CircularProgressIndicator(),
        ),
      ),

      error: (e, _) => Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Text("Error: $e"),
        ),
      ),

      data: (product) {
        final isOwner = auth.user?.id == product.ownerId;
        final isLoggedIn = auth.isAuthenticated;

        // ✅ 2. Reset or initialize the active variant when product changes
        if (_lastInitializedProductId != product.id) {
          _lastInitializedProductId = product.id;
          _selectedVariant = product.variants.isNotEmpty ? product.variants.first : null;
        }

        if (!_hasLoggedView) {
          analytics.logEvent('product_view_${product.id}');
          _hasLoggedView = true;
        }

        final images = product.images.isNotEmpty
            ? product.images
            : [product.safeImage];

        Widget buildImageCarousel(double carouselHeight) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: carouselHeight,
                child: Stack(
                  alignment: Alignment.bottomCenter,
                  children: [
                    PageView.builder(
                      controller: _imagePageController,
                      itemCount: images.length,
                      onPageChanged: (i) {
                        setState(() => _currentIndex = i);
                      },
                      itemBuilder: (_, i) {
                        return GestureDetector(
                          onTap: () => _openFullScreenGallery(images, i),
                          child: MouseRegion(
                            cursor: SystemMouseCursors.click,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(isDesktop ? 12 : 0),
                              child: CachedNetworkImage(
                                imageUrl: images[i],
                                fit: BoxFit.cover,
                                width: double.infinity,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    if (images.length > 1 && !isDesktop)
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
              if (images.length > 1 && isDesktop) ...[
                const SizedBox(height: AppSpacing.sm),
                SizedBox(
                  height: 80,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: images.length,
                    separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.sm),
                    itemBuilder: (context, idx) {
                      final isSelected = _currentIndex == idx;
                      return GestureDetector(
                        onTap: () {
                          setState(() => _currentIndex = idx);
                          _imagePageController.animateToPage(
                            idx,
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        },
                        child: Container(
                          width: 80,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: isSelected ? AppColors.mangoOrange : Colors.grey.shade300,
                              width: isSelected ? 2.5 : 1.0,
                            ),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: CachedNetworkImage(
                              imageUrl: images[idx],
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ],
          );
        }

        // ✅ 3. Helper to format dynamic attributes map cleanly to display strings
        String formatAttributes(Map<String, dynamic> attributes) {
          if (attributes.isEmpty) return "Standard Option";
          return attributes.entries.map((e) => "${e.key}: ${e.value}").join(", ");
        }

        // ✅ 4. New Widget to render option chips horizontally with stock validation
        Widget buildVariantSelector(List<LocalProductVariant> variants) {
          if (variants.isEmpty) return const SizedBox.shrink();

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Available Options",
                style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: AppSpacing.xs),
              SizedBox(
                height: 46,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: variants.length,
                  separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.sm),
                  itemBuilder: (context, index) {
                    final variant = variants[index];
                    final isSelected = _selectedVariant == variant;

                    return ChoiceChip(
                      label: Text(
                        formatAttributes(variant.attributes),
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.black87,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                      selected: isSelected,
                      selectedColor: AppColors.mangoOrange,
                      backgroundColor: Colors.grey.shade100,
                      checkmarkColor: Colors.white,
                      onSelected: (bool selected) {
                        setState(() {
                          _selectedVariant = selected ? variant : null;
                        });
                      },
                    );
                  },
                ),
              ),
              if (_selectedVariant != null) ...[
                const SizedBox(height: AppSpacing.xs),
                Row(
                  children: [
                    Icon(Icons.inventory_2_outlined, size: 14, color: Colors.grey.shade600),
                    const SizedBox(width: 4),
                    Text(
                      "Stock for this option: ${_selectedVariant!.stock} items left",
                      style: AppTypography.bodySmall.copyWith(color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: AppSpacing.md),
            ],
          );
        }

        Widget buildProductInfo() {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                product.name,
                style: isDesktop ? AppTypography.displayMedium : AppTypography.displaySmall,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                "MWK ${product.price}",
                style: AppTypography.headlineLarge.copyWith(
                  color: AppColors.mangoOrange,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),

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

              // ✅ 5. Injected Variant selector into layout flow here
              buildVariantSelector(product.variants),

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

              DefaultTabController(
                length: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
                  ],
                ),
              ),
            ],
          );
        }

        Widget buildRelatedProducts() {
          if (_related.isEmpty) return const SizedBox.shrink();
          return Padding(
            padding: EdgeInsets.symmetric(
              vertical: AppSpacing.md,
              horizontal: isDesktop ? 0 : AppSpacing.md,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Related Products",
                  style: AppTypography.headlineMedium,
                ),
                const SizedBox(height: AppSpacing.md),
                SizedBox(
                  height: 280,
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
          );
        }

        return Stack(
          children: [
            Positioned.fill(
              child: SingleChildScrollView(
                controller: _scrollController,
                child: Column(
                  children: [
                    Center(
                      child: Container(
                        constraints: const BoxConstraints(maxWidth: 1200),
                        padding: isDesktop
                            ? const EdgeInsets.symmetric(horizontal: 24, vertical: 32)
                            : EdgeInsets.zero,
                        child: isDesktop
                            ? Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    flex: 5,
                                    child: buildImageCarousel(500),
                                  ),
                                  const SizedBox(width: 40),
                                  Expanded(
                                    flex: 6,
                                    child: buildProductInfo(),
                                  ),
                                ],
                              )
                            : Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  buildImageCarousel(340),
                                  Padding(
                                    padding: const EdgeInsets.all(AppSpacing.md),
                                    child: buildProductInfo(),
                                  ),
                                ],
                              ),
                      ),
                    ),
                    Center(
                      child: Container(
                        constraints: const BoxConstraints(maxWidth: 1200),
                        padding: isDesktop ? const EdgeInsets.symmetric(horizontal: 24) : EdgeInsets.zero,
                        child: buildRelatedProducts(),
                      ),
                    ),
                    const SizedBox(height: 120),
                    const WebFooter(),
                  ],
                ),
              ),
            ),

            Positioned(
              bottom: 50,
              right: isDesktop ? (screenWidth - 1200 > 0 ? (screenWidth - 1200) / 2 + 24 : 24) : 10,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
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
                        
                        analytics.logEvent('product_add_to_cart_click_${product.id}');
                        ref.read(addToCartProvider).call(product, 1);
                        AppToast.success(context, "ADDED TO CART");
                      },
                    ),
                    const SizedBox(height: AppSpacing.sm),
                  ],

                  AnimatedSize(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeInOut,
                    child: Column(
                      children: [
                        if (_isMenuOpen) ...[
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
                                  MaterialPageRoute(builder: (_) => ShopDetailsScreen(shopId: product.shopId)),
                                );
                              }
                            },
                          ),

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
    );
  }
}

class FullScreenImageGallery extends StatefulWidget {
  final List<String> images;
  final int initialIndex;

  const FullScreenImageGallery({
    Key? key,
    required this.images,
    required this.initialIndex,
  }) : super(key: key);

  @override
  State<FullScreenImageGallery> createState() => _FullScreenImageGalleryState();
}

class _FullScreenImageGalleryState extends State<FullScreenImageGallery> {
  late int _galleryIndex;
  late PageController _galleryPageController;

  @override
  void initState() {
    super.initState();
    _galleryIndex = widget.initialIndex;
    _galleryPageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _galleryPageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white, size: 28),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "${_galleryIndex + 1} / ${widget.images.length}",
          style: const TextStyle(color: Colors.white, fontSize: 18),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          PageView.builder(
            controller: _galleryPageController,
            itemCount: widget.images.length,
            onPageChanged: (index) {
              setState(() => _galleryIndex = index);
            },
            itemBuilder: (context, index) {
              return InteractiveViewer(
                minScale: 1.0,
                maxScale: 4.0,
                child: Center(
                  child: CachedNetworkImage(
                    imageUrl: widget.images[index],
                    fit: BoxFit.contain,
                    placeholder: (_, __) => const Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    ),
                  ),
                ),
              );
            },
          ),
          if (widget.images.length > 1) ...[
            if (_galleryIndex > 0)
              Positioned(
                left: 16,
                top: 0,
                bottom: 0,
                child: Center(
                  child: CircleAvatar(
                    backgroundColor: Colors.black54,
                    child: IconButton(
                      icon: const Icon(Icons.chevron_left, color: Colors.white),
                      onPressed: () {
                        _galleryPageController.previousPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      },
                    ),
                  ),
                ),
              ),
            if (_galleryIndex < widget.images.length - 1)
              Positioned(
                right: 16,
                top: 0,
                bottom: 0,
                child: Center(
                  child: CircleAvatar(
                    backgroundColor: Colors.black54,
                    child: IconButton(
                      icon: const Icon(Icons.chevron_right, color: Colors.white),
                      onPressed: () {
                        _galleryPageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      },
                    ),
                  ),
                ),
              ),
          ],
        ],
      ),
    );
  }
}