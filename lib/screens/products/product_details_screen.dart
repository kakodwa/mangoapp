import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../providers/products_provider.dart';
import '../../providers/shops_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/main_app_bar.dart';
import '../../theme/app_colors.dart';
import '../products/product_card.dart';
import '../../providers/api_provider.dart' as api;
import '../../models/product_model.dart';
import '../shops/shop_details_screen.dart';
import '../products/edit_product_screen.dart';
import '../auth/login_screen.dart';

import '../../utils/app_toast.dart';

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
      backgroundColor: const Color(0xFFF6F7FB),

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
                      padding: const EdgeInsets.all(16),
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
  padding: const EdgeInsets.symmetric(
    horizontal: 12,
    vertical: 8,
  ),
  decoration: BoxDecoration(
    color: product.stock > 0
        ? Colors.green.withOpacity(0.1)
        : Colors.red.withOpacity(0.1),
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
            ? Colors.green
            : Colors.red,
      ),

      const SizedBox(width: 6),

      Text(
        product.stock > 0
            ? "${product.stock} items in stock"
            : "Out of stock",
        style: TextStyle(
          color: product.stock > 0
              ? Colors.green
              : Colors.red,
          fontWeight: FontWeight.bold,
        ),
      ),
    ],
  ),
),

                          const SizedBox(height: 10),

                          Row(
                            children: [
                              const Icon(Icons.star,
                                  color: Colors.amber),
                              const SizedBox(width: 4),
                              Text(
                                "${product.rating} (${product.totalReviews})",
                              ),
                            ],
                          ),

                          const SizedBox(height: 16),

                          // ================= SHOP INFO + DISTRICT
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.store,
                                        color: AppColors.mangoOrange),
                                    const SizedBox(width: 8),
                                    Text(
                                      product.shopName,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 8),

                                Row(
                                  children: [
                                    const Icon(Icons.location_on,
                                        size: 18),
                                    const SizedBox(width: 6),
                                    Text(
                                      product.shopDistrict ?? 'Unknown',
                                      style: const TextStyle(
                                          color: Colors.grey),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 16),

                          Text(product.description),
                        ],
                      ),
                    ),
                  ),

                  // ================= RELATED PRODUCTS
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Related Products",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 10),

                          SizedBox(
                            height:280,
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
                bottom: 100,
                right: 16,
                child: Column(
                  children: [

                    if (!isOwner)
                      FloatingActionButton(
                        heroTag: "fav",
                        backgroundColor: Colors.white,
                        onPressed: () {
                          if (!isLoggedIn) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const LoginScreen()),
                            );
                            return;
                          }

                          ref.read(favoriteProvider.notifier)
                              .toggle(product.id);

                          _toast("Updated favorites");
                        },
                        child: const Icon(Icons.favorite_border,
                            color: Colors.red),
                      ),

                    const SizedBox(height: 12),

                    if (product.isInStock && !isOwner)
                      FloatingActionButton(
                        heroTag: "cart",
                        backgroundColor: AppColors.mangoOrange,
                        onPressed: () {
                          if (!isLoggedIn) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const LoginScreen()),
                            );
                            return;
                          }

                          ref.read(addToCartProvider)
                              .call(product, _quantity);

                          _toast("Added to cart");
                        },
                        child: const Icon(Icons.shopping_cart),
                      ),

                    const SizedBox(height: 12),

                    FloatingActionButton(
                      heroTag: "shop",
                      backgroundColor: Colors.white,
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ShopDetailsScreen(
                              shopId: product.shopId,
                            ),
                          ),
                        );
                      },
                      child: Icon(Icons.storefront,
                          color: AppColors.mangoOrange),
                    ),

                    // ================= OWNER EDIT BUTTON (NEW BELOW SHOP)
                    if (isOwner) ...[
                      const SizedBox(height: 12),
                      FloatingActionButton(
                        heroTag: "edit",
                        backgroundColor: Colors.blue,
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  EditProductScreen(product: product),
                            ),
                          );
                        },
                        child: const Icon(Icons.edit),
                      ),
                    ]
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