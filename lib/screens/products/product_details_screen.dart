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

import '../../theme/design_system/app_spacing.dart';
import '../../theme/app_colors.dart';

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
  int _quantity = 1;
  int _currentIndex = 0;

  // related products
  final ScrollController _scrollController = ScrollController();
  List _related = [];
  int _page = 1;
  bool _loadingMore = false;

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
      _related.addAll(res); // ✅ NO mapping again
      _loadingMore = false;
    });
  } catch (e) {
    print("❌ RELATED ERROR: $e");
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

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: productAsync.when(
        data: (p) => MainAppBar(title: p.name),
        loading: () => const MainAppBar(title: "Loading..."),
        error: (_, __) =>
            const MainAppBar(title: "Product"),
      ),

      body: productAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),

        error: (e, _) => Center(child: Text("Error: $e")),

        data: (product) {
          final isOwner = auth.user?.id == product.ownerId;
          final isLoggedIn = auth.isAuthenticated;

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
                      background: PageView.builder(
                        itemCount: images.length,
                        onPageChanged: (i) {
                          setState(() => _currentIndex = i);
                        },
                        itemBuilder: (_, i) {
                          return CachedNetworkImage(
                            imageUrl: images[i],
                            fit: BoxFit.cover,
                          );
                        },
                      ),
                    ),
                  ),

                  // ================= INFO
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.all(AppSpacing.md),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [

                          Text(
                            product.name,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 6),

                          Text(
                            "MWK ${product.price}",
                            style: TextStyle(
                              fontSize: 18,
                              color: AppColors.mangoOrange,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 10),

// ================= STOCK
Container(
  padding: EdgeInsets.symmetric(
    horizontal: 12,
    vertical: 8,
  ),
  decoration: BoxDecoration(
    color: product.stock > 0
        ? Theme.of(context).colorScheme.secondary.withOpacity(0.1)
        : Theme.of(context).colorScheme.error.withOpacity(0.1),
    borderRadius: BorderRadius.circular(12),
  ),
  child: Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(
        product.stock > 0
            ? Icons.check_circle
            : Icons.cancel,
        size: 18,
        color: product.stock > 0
            ? Theme.of(context).colorScheme.secondary
            : Theme.of(context).colorScheme.error,
      ),

      const SizedBox(width: 6),

      Text(
        product.stock > 0
            ? "${product.stock} items in stock"
            : "Out of stock",
        style: TextStyle(
          color: product.stock > 0
              ? Theme.of(context).colorScheme.secondary
              : Theme.of(context).colorScheme.error,
          fontWeight: FontWeight.bold,
        ),
      ),
    ],
  ),
),

                          const SizedBox(height: 10),

                          Row(
                            children: [
                              Icon(Icons.star,
                                  color: Colors.amber),
                              const SizedBox(width: 4),
                              Text(
                                "${product.rating} (${product.totalReviews})",
                              ),
                            ],
                          ),

                          const SizedBox(height: AppSpacing.md),

                          // ================= SHOP INFO + DISTRICT
                          Container(
                            padding: EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.surface,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.store,
                                        color: AppColors.mangoOrange),
                                    const SizedBox(width: AppSpacing.xs),
                                    Text(
                                      product.shopName,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: AppSpacing.xs),

                                Row(
                                  children: [
                                    Icon(Icons.location_on,
                                        size: 18),
                                    const SizedBox(width: 6),
                                    Text(
                                      product.shopDistrict ?? 'Unknown',
                                      style: TextStyle(
                                          color: Theme.of(context).colorScheme.outline),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: AppSpacing.md),

                          Text(product.description),
                        ],
                      ),
                    ),
                  ),

                  // ================= RELATED PRODUCTS
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.all(AppSpacing.md),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Related Products",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 10),

                          SizedBox(
                            height:235,
                            child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                              itemCount: _related.length,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(width: 10),
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
                ],
              ),

              // ================= FLOATING BUTTONS
       Positioned(
  bottom:50,
  right:10,
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

    ref.read(addToCartProvider).call(product, _quantity);
  },
),
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

    ref.read(favoriteProvider.notifier).toggle(product.id);
  },
),

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