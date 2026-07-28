import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

// 1. Dart & Flutter Core Packages
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

// 2. Third-Party Packages
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

// 3. Project Imports
import '../../providers/api_provider.dart' as api;
import '../../providers/auth_provider.dart';
import '../../providers/products_provider.dart';
import '../../providers/shops_provider.dart';

import '../../models/product_model.dart';
import '../../models/product_variant_model.dart'; 

import '../auth/login_screen.dart';
import '../main_tabs_screen.dart';
import '../products/edit_product_screen.dart';
import '../products/product_card.dart';
import '../shops/shop_details_screen.dart';

import '../../widgets/app_fab.dart';
import '../../widgets/reviews/review_section_widget.dart';
import '../../widgets/update.dart';
import '../../widgets/web_footer.dart';

import '../../services/analytics_service.dart';
import '../../utils/app_snackbar.dart';
import '../../utils/app_toast.dart';

import '../../theme/app_colors.dart';
import '../../theme/design_system/app_badge.dart';
import '../../theme/design_system/app_card.dart';
import '../../theme/design_system/app_spacing.dart';
import '../../theme/design_system/app_typography.dart';

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

  final ScrollController _scrollController = ScrollController();
  final List<Product> _related = [];
  bool _loadingMore = false;
  
  bool _hasLoggedView = false;
  LocalProductVariant? _selectedVariant;
  int? _lastInitializedProductId;

  void _openWhatsApp(String phone) async {
    final uri = Uri.parse("https://wa.me/$phone");

    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      AppToast.info(context, "Could not open WhatsApp");
    }
  }

  void _navigateToShop(int shopId, AnalyticsService analytics) {
    analytics.logEvent('product_view_shop_click_$shopId');
    final tabsScreen = MainTabsScreen.of(context);
    if (tabsScreen != null) {
      tabsScreen.navigateToShopDetails(shopId);
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => ShopDetailsScreen(shopId: shopId)),
      );
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

  Future<void> _shareProduct(Product product, AnalyticsService analytics) async {
    analytics.logEvent('product_shared_${product.id}');

    final String productUrl = kIsWeb
        ? "${Uri.base.origin}/product/${product.id}"
        : "https://malatrade.com/product/${product.id}";

    final String shareMessage =
        "🛍️ ${product.name}\n"
        "💰 Price: MWK ${product.price}\n"
        "🏪 Shop: ${product.shopName}\n\n"
        "View this product on MalaTrade:\n$productUrl";

    final box = context.findRenderObject() as RenderBox?;
    final sharePositionOrigin =
        box != null ? box.localToGlobal(Offset.zero) & box.size : null;

    try {
      if (product.images.isNotEmpty) {
        final imageUrl = product.images.first;
        final response = await http.get(Uri.parse(imageUrl));

        if (response.statusCode == 200) {
          final tempDir = await getTemporaryDirectory();
          final extension = imageUrl
              .split('.')
              .last
              .split('?')
              .first
              .toLowerCase();

          final validExtension =
              ['jpg', 'jpeg', 'png', 'webp'].contains(extension)
                  ? extension
                  : 'jpg';

          final file = await File(
            '${tempDir.path}/shared_product_${product.id}.$validExtension',
          ).create();

          await file.writeAsBytes(response.bodyBytes);

          await Share.shareXFiles(
            [XFile(file.path)],
            text: shareMessage,
            sharePositionOrigin: sharePositionOrigin,
          );
          return;
        }
      }

      await Share.share(
        shareMessage,
        sharePositionOrigin: sharePositionOrigin,
      );
    } catch (e) {
      debugPrint("Product share failed: $e");
      await Share.share(
        shareMessage,
        sharePositionOrigin: sharePositionOrigin,
      );
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
    _imagePageController.dispose();
    super.dispose();
  }

  String formatAttributes(Map<String, dynamic> attributes) {
    if (attributes.isEmpty) return "Standard Option";

    final validEntries = attributes.entries.where((e) {
      final key = e.key.toString().trim().toUpperCase();
      final val = e.value?.toString().trim().toUpperCase() ?? '';

      if (val.isEmpty || val == "N/A" || val == "NONE" || val == "NULL") {
        return false;
      }
      if (key == "N/A" || key.isEmpty) {
        return false;
      }
      return true;
    }).map((e) => "${e.key}: ${e.value}").toList();

    if (validEntries.isEmpty) return "Standard Option";
    return validEntries.join(", ");
  }

  Widget buildVariantSelector(List<LocalProductVariant> variants) {
    if (variants.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Available Options",
            style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: AppSpacing.xs),
          ChoiceChip(
            label: const Text("Standard Option"),
            selected: true,
            selectedColor: AppColors.mangoOrange,
            backgroundColor: Colors.grey.shade100,
            checkmarkColor: Colors.white,
            labelStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            onSelected: (_) {},
          ),
          const SizedBox(height: AppSpacing.md),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Available Options",
          style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: AppSpacing.xs),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.xs,
          children: variants.map((variant) {
            final isSelected = _selectedVariant == variant;
            final bool isOutOfStock = variant.stock <= 0;

            final attrText = formatAttributes(variant.attributes);

            return ChoiceChip(
              label: Text(
                attrText + (isOutOfStock ? " (Out of Stock)" : ""),
                style: TextStyle(
                  color: isSelected
                      ? Colors.white
                      : (isOutOfStock ? Colors.grey.shade400 : Colors.black87),
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  decoration: isOutOfStock ? TextDecoration.lineThrough : null,
                ),
              ),
              selected: isSelected,
              selectedColor: AppColors.mangoOrange,
              backgroundColor: Colors.grey.shade100,
              checkmarkColor: Colors.white,
              onSelected: isOutOfStock
                  ? null
                  : (bool selected) {
                      setState(() {
                        _selectedVariant = selected ? variant : null;
                      });
                    },
            );
          }).toList(),
        ),
        if (_selectedVariant != null) ...[
          const SizedBox(height: AppSpacing.sm),
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

  @override
  Widget build(BuildContext context) {
    final productAsync = ref.watch(productDetailsProvider(widget.productId));
    final auth = ref.watch(authProvider);
    final AnalyticsService analytics = AnalyticsService();

    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isDesktop = screenWidth >= 900;

    return productAsync.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(
        body: Center(child: Text("Error loading product: $e")),
      ),
      data: (product) {
        final isOwner = auth.user?.id == product.ownerId;
        final isLoggedIn = auth.isAuthenticated;

        if (_lastInitializedProductId != product.id) {
          _lastInitializedProductId = product.id;
          _selectedVariant =
              product.variants.isNotEmpty ? product.variants.first : null;
        }

        if (!_hasLoggedView) {
          analytics.logEvent('product_view_${product.id}');
          _hasLoggedView = true;
        }

        final images = product.images.isNotEmpty
            ? product.images
            : [product.safeImage];

        Widget buildImageCarousel(double carouselHeight) {
          final double thumbnailSize = isDesktop ? 80 : 64;

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

                    // Active Index Indicator Pill
                    if (images.length > 1)
                      Positioned(
                        bottom: AppSpacing.md,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.55),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            "${_currentIndex + 1} / ${images.length}",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              // Image Previews (Thumbnails) for Mobile and Desktop
              if (images.length > 1) ...[
                const SizedBox(height: AppSpacing.sm),
                SizedBox(
                  height: thumbnailSize,
                  child: ListView.separated(
                    padding: EdgeInsets.symmetric(
                      horizontal: isDesktop ? 0 : AppSpacing.md,
                    ),
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
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: thumbnailSize,
                          height: thumbnailSize,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.mangoOrange
                                  : Colors.grey.shade300,
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

        Widget buildProductInfo() {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                product.name,
                style: isDesktop
                    ? AppTypography.displayMedium
                    : AppTypography.displaySmall,
              ),
              const SizedBox(height: AppSpacing.xs),

              Wrap(
                spacing: AppSpacing.xs,
                runSpacing: AppSpacing.xs,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Chip(
                    elevation: 0,
                    backgroundColor: Colors.orange.shade50,
                    side: BorderSide(color: Colors.orange.shade200),
                    labelPadding: const EdgeInsets.symmetric(horizontal: 4),
                    avatar: Icon(Icons.grid_view_rounded,
                        size: 14, color: Colors.orange.shade700),
                    label: Text(
                      product.category,
                      style: AppTypography.bodySmall.copyWith(
                        color: Colors.orange.shade900,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  if (product.subCategory.isNotEmpty) ...[
                    Icon(Icons.chevron_right_rounded,
                        size: 16, color: Colors.grey.shade400),
                    Chip(
                      elevation: 0,
                      backgroundColor: Colors.orange.shade100,
                      side: BorderSide(color: Colors.orange.shade300),
                      labelPadding: const EdgeInsets.symmetric(horizontal: 4),
                      avatar: Icon(Icons.category_outlined,
                          size: 14, color: Colors.orange.shade600),
                      label: Text(
                        product.subCategory,
                        style: AppTypography.bodySmall.copyWith(
                          color: Colors.orange.shade800,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                  if (product.brand.isNotEmpty) ...[
                    Icon(Icons.chevron_right_rounded,
                        size: 16, color: Colors.grey.shade400),
                    Chip(
                      elevation: 0,
                      backgroundColor: Colors.orange.shade50,
                      side: BorderSide(color: Colors.orange.shade200),
                      labelPadding: const EdgeInsets.symmetric(horizontal: 4),
                      avatar: Icon(Icons.label_outline_rounded,
                          size: 14, color: Colors.orange.shade700),
                      label: Text(
                        product.brand,
                        style: AppTypography.bodySmall.copyWith(
                          color: Colors.orange.shade900,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: AppSpacing.sm),

              if (product.deliveryDuration.isNotEmpty) ...[
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: Colors.blueGrey.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blueGrey.shade100),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.local_shipping_outlined,
                          color: Colors.blueGrey.shade700, size: 18),
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        "Estimated Delivery: ",
                        style: AppTypography.bodySmall.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.blueGrey.shade900),
                      ),
                      Text(
                        product.deliveryDuration,
                        style: AppTypography.bodySmall.copyWith(
                            color: Colors.blueGrey.shade700,
                            fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
              ],

              Text(
                "MWK ${product.price}",
                style: AppTypography.displaySmall.copyWith(
                  color: AppColors.mangoOrange,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
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
                      return const Icon(Icons.star_rounded,
                          color: Colors.amber, size: 22);
                    } else if (product.rating > currentStarValue - 1 &&
                        product.rating < currentStarValue) {
                      return const Icon(Icons.star_half_rounded,
                          color: Colors.amber, size: 22);
                    } else {
                      return Icon(Icons.star_border_rounded,
                          color: Colors.grey.shade400, size: 22);
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

              buildVariantSelector(product.variants),

              AppCard(
                padding: const EdgeInsets.all(AppSpacing.md),
                onTap: () => _navigateToShop(product.shopId, analytics),
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
                              const Icon(Icons.location_on_outlined,
                                  size: 14, color: Colors.grey),
                              const SizedBox(width: 4),
                              Text(
                                product.shopDistrict ?? 'Unknown',
                                style: AppTypography.bodySmall
                                    .copyWith(color: Colors.grey),
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
                        final tabController =
                            DefaultTabController.of(context);
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
                    separatorBuilder: (_, __) =>
                        const SizedBox(width: AppSpacing.sm),
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

        return Scaffold(
          body: SingleChildScrollView(
            controller: _scrollController,
            child: Column(
              children: [
                Center(
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 1200),
                    padding: isDesktop
                        ? const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 32)
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
                    padding: isDesktop
                        ? const EdgeInsets.symmetric(horizontal: 24)
                        : EdgeInsets.zero,
                    child: buildRelatedProducts(),
                  ),
                ),
                const SizedBox(height: 40),

                // Web/Desktop Footer (Visible across Web and Responsive viewports)
                const WebFooter(),
              ],
            ),
          ),

          // Dynamic Action Bottom Bar
          bottomNavigationBar: SafeArea(
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.xs,
                vertical: 4.0,
              ),
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // 1. Favorite (Shoppers Only)
                  if (!isOwner) ...[
                    IconButton(
                      visualDensity: VisualDensity.compact,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(minWidth: 38, minHeight: 38),
                      icon: const Icon(Icons.favorite_border, size: 22),
                      tooltip: "Favorite",
                      onPressed: () {
                        analytics.logEvent('product_fav_click_${product.id}');
                        AppToast.success(context, "ADDED TO FAVORITES");
                      },
                    ),
                  ],

                  // 2. WhatsApp
                  IconButton(
                    visualDensity: VisualDensity.compact,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(minWidth: 38, minHeight: 38),
                    icon: const FaIcon(FontAwesomeIcons.whatsapp, color: Color(0xFF25D366), size: 20),
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

                  // 3. Share
                  IconButton(
                    visualDensity: VisualDensity.compact,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(minWidth: 38, minHeight: 38),
                    icon: const Icon(Icons.share_outlined, size: 22),
                    tooltip: "Share Product",
                    onPressed: () => _shareProduct(product, analytics),
                  ),

                  // 4. View Shop
                  IconButton(
                    visualDensity: VisualDensity.compact,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(minWidth: 38, minHeight: 38),
                    icon: const Icon(Icons.storefront_outlined, size: 22),
                    tooltip: "View Shop",
                    onPressed: () => _navigateToShop(product.shopId, analytics),
                  ),

                  const SizedBox(width: AppSpacing.xs),

                  // 5. Dynamic Action Button: "Edit Item" for Owner OR "Add to Cart" for Shoppers
                  Expanded(
                    child: SizedBox(
                      height: 42,
                      child: isOwner
                          ? ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.mangoOrange,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              icon: const Icon(Icons.edit, size: 18),
                              label: const Text(
                                "Edit Item",
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                              ),
                              onPressed: () {
                                analytics.logEvent('product_edit_click_${product.id}');
                                MainTabsScreen.of(context)?.navigateToEditProduct(product);
                              },
                            )
                          : (product.isInStock
                              ? ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.mangoOrange,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(horizontal: 12),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  icon: const Icon(Icons.shopping_cart, size: 18),
                                  label: const Text(
                                    "Add to Cart",
                                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                  ),
                                  onPressed: () {
                                    if (!isLoggedIn) {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (_) => const LoginScreen()),
                                      );
                                      return;
                                    }

                                    if (product.variants.isNotEmpty && _selectedVariant == null) {
                                      AppToast.info(context, "Please select an option first");
                                      return;
                                    }

                                    analytics.logEvent('product_add_to_cart_click_${product.id}');
                                    ref.read(addToCartProvider).call(product, 1, _selectedVariant);
                                    AppToast.success(context, "ADDED TO CART");
                                  },
                                )
                              : const ElevatedButton(
                                  onPressed: null,
                                  child: Text("Out of Stock"),
                                )),
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