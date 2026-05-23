import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/shops_provider.dart';
import '../../providers/products_provider.dart';
import '../../widgets/main_app_bar.dart';
import '../../widgets/shop_map_modal.dart';
import '../../theme/app_colors.dart';
import '../products/product_card.dart';
import '../../models/shop_model.dart';
import 'shop_card.dart';

class ShopDetailsScreen extends ConsumerWidget {
  final int shopId;

  const ShopDetailsScreen({Key? key, required this.shopId})
      : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final shopAsync = ref.watch(shopDetailsProvider(shopId));
    final productsAsync = ref.watch(productsByShopProvider(shopId));

    // ✅ RELATED SHOPS
    final relatedShopsAsync =
        ref.watch(relatedShopsProvider(shopId));

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),

      appBar: shopAsync.when(
        data: (shop) => MainAppBar(title: shop.name),
        loading: () => const MainAppBar(title: 'Loading...'),
        error: (_, __) => const MainAppBar(title: 'Shop'),
      ),

      body: shopAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(
            color: AppColors.mangoOrange,
          ),
        ),

        error: (e, _) => Center(
          child: Text("Error: $e"),
        ),

        data: (shop) {
          return Stack(
            children: [

              CustomScrollView(
                slivers: [

                  // ================= HEADER
                  SliverAppBar(
                    expandedHeight: 220,
                    pinned: false,
                    automaticallyImplyLeading: true,
                    flexibleSpace: FlexibleSpaceBar(
                      background: Stack(
                        fit: StackFit.expand,
                        children: [

                          shop.banner != null
                              ? Image.network(
                                  shop.banner!,
                                  fit: BoxFit.cover,
                                )
                              : Container(
                                  color: Colors.grey.shade300,
                                  child: const Icon(
                                    Icons.store,
                                    size: 80,
                                  ),
                                ),

                          Container(
                            color: Colors.black.withOpacity(0.35),
                          ),

                          Positioned(
                            top: 40,
                            left: 16,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: AppColors.mangoOrange,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                shop.category,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),

                          Positioned(
                            top: 40,
                            right: 16,
                            child: Row(
                              children: [
                                Icon(
                                  shop.status == 'approved'
                                      ? Icons.verified
                                      : Icons.lock,
                                  color: shop.status == 'approved'
                                      ? Colors.green
                                      : Colors.red,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  shop.status == 'approved'
                                      ? "Verified"
                                      : "Pending",
                                  style: const TextStyle(
                                      color: Colors.white),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // ================= SHOP INFO
                  SliverToBoxAdapter(
                    child: Container(
                      margin: const EdgeInsets.all(16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 10,
                          )
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 26,
                                backgroundColor: Colors.grey.shade200,
                                backgroundImage: shop.logo.isNotEmpty
                                    ? NetworkImage(shop.logo)
                                    : null,
                                child: shop.logo.isEmpty
                                    ? const Icon(Icons.store)
                                    : null,
                              ),
                              const SizedBox(width: 12),

                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      shop.name,
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        const Icon(Icons.location_on,
                                            size: 14,
                                            color: Colors.grey),
                                        const SizedBox(width: 4),
                                        Text(shop.district),
                                        const SizedBox(width: 12),
                                        const Icon(Icons.star,
                                            size: 14,
                                            color:
                                                AppColors.mangoOrange),
                                        const SizedBox(width: 4),
                                        Text("${shop.rating}"),
                                      ],
                                    ),
                                  ],
                                ),
                              ),

                              Text(
                                "${shop.productCount ?? 0} items",
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(shop.description),
                        ],
                      ),
                    ),
                  ),

                  // ================= PRODUCTS TITLE
                  const SliverToBoxAdapter(
                    child: Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        "Products",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  const SliverToBoxAdapter(
                      child: SizedBox(height: 10)),

                  // ================= PRODUCTS GRID
                  productsAsync.when(
                    loading: () => const SliverToBoxAdapter(
                      child: Center(
                          child: CircularProgressIndicator()),
                    ),
                    error: (e, _) => SliverToBoxAdapter(
                      child: Center(child: Text("Error: $e")),
                    ),
                    data: (products) {
                      return SliverPadding(
                        padding: const EdgeInsets.all(12),
                        sliver: SliverGrid(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              return ProductCard(
                                  product: products[index]);
                            },
                            childCount: products.length,
                          ),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                            childAspectRatio: 0.60,
                          ),
                        ),
                      );
                    },
                  ),

                  // ================= RELATED SHOPS TITLE
                  const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                      child: Text(
                        "Related Shops",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  // ================= RELATED SHOPS
                  SliverToBoxAdapter(
                    child: relatedShopsAsync.when(
                      loading: () => const Padding(
                        padding: EdgeInsets.all(16),
                        child: Center(
                            child: CircularProgressIndicator()),
                      ),
                      error: (e, _) => Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text("Error: $e"),
                      ),
                      data: (shops) {
                        if (shops.isEmpty) {
                          return const Padding(
                            padding: EdgeInsets.all(16),
                            child:
                                Text("No related shops found"),
                          );
                        }

                        return SizedBox(
                          height:280,
                          child: ListView.separated(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16),
                            scrollDirection: Axis.horizontal,
                            itemCount: shops.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(width: 10),
                                itemBuilder: (context, index) {
                                  return SizedBox(
                                    width: 280,
                                    child: ShopCard(
                                      shop: shops[index],
                                      ),
                                    );
                                  },
                          ),
                        );
                      },
                    ),
                  ),

                  const SliverToBoxAdapter(
                      child: SizedBox(height: 100)),
                ],
              ),

              // ================= FLOATING ACTIONS
              Positioned(
                bottom: 20,
                right: 16,
                child: Column(
                  children: [
                    FloatingActionButton.small(
                      heroTag: "fav",
                      backgroundColor: Colors.red,
                      onPressed: () {},
                      child: const Icon(Icons.favorite),
                    ),
                    const SizedBox(height: 12),
                    FloatingActionButton(
                      heroTag: "map",
                      backgroundColor: AppColors.mangoOrange,
                      onPressed: () {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          builder: (_) => ShopMapModal(
                            shopLat: shop.latitude,
                            shopLng: shop.longitude,
                          ),
                        );
                      },
                      child: const Icon(Icons.map),
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