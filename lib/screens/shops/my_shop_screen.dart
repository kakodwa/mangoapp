import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/shops_provider.dart';
import '../../providers/products_provider.dart';
import '../../providers/api_provider.dart';
import 'edit_shop_screen.dart';
import '../products/edit_product_screen.dart';
import '../products/product_details_screen.dart';
import '../products/add_product_screen.dart';
import '../../widgets/main_app_bar.dart';
import '../../theme/app_colors.dart';
import '../../core/api/api_client.dart';

class MyShopScreen extends ConsumerWidget {
  const MyShopScreen({super.key});

  String fixImageUrl(String? url) {
    if (url == null || url.isEmpty) return '';
    if (url.startsWith('http')) return url;
    return "${ApiClient.host}$url";
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final myShopAsync = ref.watch(userShopsProvider);

    return Scaffold(
      appBar: const MainAppBar(title: 'My Shop'),

      // ================= FLOATING BUTTONS =================
      floatingActionButton: myShopAsync.maybeWhen(
        data: (shops) {
          if (shops.isEmpty) return null;

          final shop = shops.first;

          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [

              // ✏️ EDIT SHOP
              FloatingActionButton(
                heroTag: "edit_shop",
                backgroundColor:AppColors.leafGreen,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => EditShopScreen(shop: shop),
                    ),
                  );
                },
                child: const Icon(Icons.edit),
              ),

              const SizedBox(height: 12),

              // ➕ ADD PRODUCT
              FloatingActionButton(
                heroTag: "add_product",
                backgroundColor:AppColors.mangoOrange,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AddProductScreen(),
                    ),
                  );
                },
                child: const Icon(Icons.add),
              ),
            ],
          );
        },
        orElse: () => null,
      ),

      body: myShopAsync.when(
        data: (shops) {
          if (shops.isEmpty) {
            return const Center(
              child: Text(
                "You have not created a shop yet.",
                style: TextStyle(fontSize: 16),
              ),
            );
          }

          final shop = shops.first;
          final productsAsync =
              ref.watch(productsByShopProvider(shop.id));

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                // ================= BANNER =================
                Stack(
                  children: [
                    Container(
                      height: 180,
                      width: double.infinity,
                      color: Colors.grey.shade300,
                      child: (shop.banner != null && shop.banner!.isNotEmpty)
                          ? Image.network(
                              fixImageUrl(shop.banner),
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return const Center(
                                  child: Icon(Icons.store, size: 60),
                                );
                              },
                            )
                          : const Center(
                              child: Icon(Icons.store, size: 60),
                            ),
                    ),

                    Positioned(
                      bottom: -3,
                      left: 16,
                      child: CircleAvatar(
                        radius: 35,
                        backgroundColor: Colors.white,
                        child: (shop.logo != null && shop.logo!.isNotEmpty)
                            ? ClipOval(
                                child: Image.network(
                                  fixImageUrl(shop.logo),
                                  width: 60,
                                  height: 60,
                                  fit: BoxFit.cover,
                                ),
                              )
                            : const Icon(Icons.store),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 40),

                // ================= SHOP INFO =================
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        shop.name,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(shop.description),

                      const SizedBox(height: 20),

                      const Text(
                        "Contact Information",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 10),

                      ListTile(
                        leading: const Icon(Icons.phone),
                        title: const Text("Phone"),
                        subtitle: Text(shop.phoneNumber),
                        contentPadding: EdgeInsets.zero,
                      ),

                      ListTile(
                        leading: const Icon(Icons.email),
                        title: const Text("Email"),
                        subtitle: Text(shop.email),
                        contentPadding: EdgeInsets.zero,
                      ),

                      ListTile(
                        leading: const Icon(Icons.location_on),
                        title: const Text("Location"),
                        subtitle:
                            Text("${shop.address}, ${shop.city}"),
                        contentPadding: EdgeInsets.zero,
                      ),
                    ],
                  ),
                ),

                // ================= PRODUCTS =================
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    "Products",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                productsAsync.when(
                  data: (products) {
                    if (products.isEmpty) {
                      return const Padding(
                        padding: EdgeInsets.all(16),
                        child: Text("No products yet"),
                      );
                    }

                    return ListView.builder(
                      shrinkWrap: true,
                      physics:
                          const NeverScrollableScrollPhysics(),
                      itemCount: products.length,
                      itemBuilder: (context, index) {
                        final product = products[index];
                        return Card(
  margin: const EdgeInsets.symmetric(
      horizontal: 16, vertical: 6),
  child: ListTile(
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ProductDetailsScreen(
            productId: product.id,
          ),
        ),
      );
    },

    leading: (product.image != null && product.image!.isNotEmpty)
    ? Image.network(
        fixImageUrl(product.image),
        width: 50,
        height: 50,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return const Icon(Icons.image_not_supported);
        },
      )
    : const Icon(
        Icons.image_not_supported,
        size: 30,
        color: Colors.grey,
      ),

    title: Text(product.name),
    subtitle: Text("MWK ${product.price}"),

    trailing: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: const Icon(Icons.edit, color: Colors.blue),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    EditProductScreen(product: product),
              ),
            );
          },
        ),
        IconButton(
          icon: const Icon(Icons.delete, color: Colors.red),
          onPressed: () async {
            await ref
                .read(apiClientProvider)
                .delete("products/${product.id}/");

            ref.invalidate(productsByShopProvider(shop.id));
          },
        ),
      ],
    ),
  ),
);
                      },
                    );
                  },

                  // 🔥 IMPROVED ERROR UI
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),

                  error: (e, _) => Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        const Icon(Icons.error,
                            color: Colors.red, size: 40),
                        const SizedBox(height: 10),
                        Text(
                          "Failed to load products:\n$e",
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),
              ],
            ),
          );
        },

        loading: () =>
            const Center(child: CircularProgressIndicator()),

        error: (error, _) => Center(
          child: Text(
            "Error: $error",
            style: const TextStyle(color: Colors.red),
          ),
        ),
      ),
    );
  }
}