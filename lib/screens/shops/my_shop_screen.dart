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
import '../../theme/design_system/app_spacing.dart';

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
      backgroundColor: const Color(0xFFF5F7FA),
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
                child: Icon(Icons.edit),
              ),

              const SizedBox(height: AppSpacing.sm),

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
                child: Icon(Icons.add),
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
                      color: Theme.of(context).colorScheme.outline.withOpacity(0.38),
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
                        backgroundColor: Theme.of(context).colorScheme.surface,
                        child: (shop.logo != null && shop.logo!.isNotEmpty)
                            ? ClipOval(
                                child: Image.network(
                                  fixImageUrl(shop.logo),
                                  width: 60,
                                  height: 60,
                                  fit: BoxFit.cover,
                                ),
                              )
                            : Icon(Icons.store),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 40),

                // ================= SHOP INFO =================
                Padding(
                  padding: EdgeInsets.all(AppSpacing.md),
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

                      const SizedBox(height: AppSpacing.md),

                      Text(
                        "Contact Information",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 10),

                      ListTile(
                        leading: Icon(Icons.phone),
                        title: Text("Phone"),
                        subtitle: Text(shop.phoneNumber),
                        contentPadding: EdgeInsets.zero,
                      ),

                      ListTile(
                        leading: Icon(Icons.email),
                        title: Text("Email"),
                        subtitle: Text(shop.email),
                        contentPadding: EdgeInsets.zero,
                      ),

                      ListTile(
                        leading: Icon(Icons.location_on),
                        title: Text("Location"),
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
  margin: EdgeInsets.symmetric(
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
          return Icon(Icons.image_not_supported);
        },
      )
    : Icon(
        Icons.image_not_supported,
        size: 30,
        color: Theme.of(context).colorScheme.outline,
      ),

    title: Text(product.name),
    subtitle: Text("MWK ${product.price}"),

    trailing: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: Icon(Icons.edit, color: Theme.of(context).colorScheme.primary),
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
          icon: Icon(Icons.delete, color: Theme.of(context).colorScheme.error),
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
                    padding: EdgeInsets.all(AppSpacing.md),
                    child: Column(
                      children: [
                        Icon(Icons.error,
                            color: Theme.of(context).colorScheme.error, size: 40),
                        const SizedBox(height: 10),
                        Text(
                          "Failed to load products:\n$e",
                          textAlign: TextAlign.center, style: TextStyle(color: Theme.of(context).colorScheme.error),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: AppSpacing.md),
              ],
            ),
          );
        },

        loading: () =>
            const Center(child: CircularProgressIndicator()),

        error: (error, _) => Center(
          child: Text(
            "Error: $error",
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
        ),
      ),
    );
  }
}