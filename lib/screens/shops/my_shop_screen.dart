import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/shops_provider.dart';
import '../../providers/products_provider.dart';
import '../../providers/api_provider.dart';
import '../main_tabs_screen.dart'; // Core structural coordinator layout
import 'edit_shop_screen.dart';
import '../products/edit_product_screen.dart';
import '../products/product_details_screen.dart';
import '../products/add_product_screen.dart';
import '../../widgets/app_fab.dart';
import '../../core/api/api_client.dart';

// Design System Imports
import '../../theme/design_system/app_card.dart';
import '../../theme/design_system/app_loader.dart';
import '../../theme/design_system/app_info_box.dart';
import '../../theme/design_system/app_spacing.dart';
import '../../theme/design_system/app_typography.dart';

import '../../widgets/web_footer.dart';

class MyShopScreen extends ConsumerWidget {
  const MyShopScreen({super.key});

  /// Capitalizes only the first letter of a string and sets the rest to lowercase
  String _capitalize(String text) {
    if (text.isEmpty) return text;
    final lower = text.toLowerCase();
    return "${lower[0].toUpperCase()}${lower.substring(1)}";
  }

  String fixImageUrl(String? url) {
    if (url == null || url.isEmpty) return '';
    if (url.startsWith('http')) return url;
    return "${ApiClient.host}$url";
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final myShopAsync = ref.watch(userShopsProvider);

    // Scaffold & Appbars are removed to blend into the parent MainTabs navigation frame
    return Stack(
      children: [
        myShopAsync.when(
          data: (shops) {
            if (shops.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: AppInfoBox(
                    type: AppInfoType.info,
                    message: _capitalize("You have not created a shop yet."),
                  ),
                  ),
                );
              }

            final shop = shops.first;
            final productsAsync = ref.watch(productsByShopProvider(shop.id));

            return DefaultTabController(
              length: 2,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ================= BANNER =================
                    Stack(
                      clipBehavior: Clip.none,
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
                          bottom: -30,
                          left: AppSpacing.md,
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
                                : const Icon(Icons.store, size: 30),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 40),

                    // ================= SHOP TITLE SECTION =================
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                      child: Text(
                        _capitalize(shop.name),
                        style: AppTypography.displaySmall,
                      ),
                    ),

                    const SizedBox(height: AppSpacing.sm),

                    // ================= NAVIGATION TABS =================
                    TabBar(
                      labelColor: Theme.of(context).colorScheme.primary,
                      unselectedLabelColor: Theme.of(context).colorScheme.onSurfaceVariant,
                      indicatorColor: Theme.of(context).colorScheme.primary,
                      tabs: [
                        Tab(text: _capitalize("Products")),
                        Tab(text: _capitalize("Shop Details")),
                      ],
                    ),

                    const SizedBox(height: AppSpacing.md),

                    // ================= TAB CONTENTS =================
                    Builder(
                      builder: (context) {
                        return AnimatedBuilder(
                          animation: DefaultTabController.of(context),
                          builder: (context, child) {
                            final index = DefaultTabController.of(context).index;
                            if (index == 0) {
                              // ================= TAB 1: PRODUCTS VIEW =================
                              return productsAsync.when(
                                data: (products) {
                                  if (products.isEmpty) {
                                    return Padding(
                                      padding: const EdgeInsets.all(AppSpacing.md),
                                      child: Center(
                                        child: Text(
                                          _capitalize("No products yet"),
                                          style: AppTypography.bodyMedium,
                                        ),
                                      ),
                                    );
                                  }

                                  return ListView.builder(
                                    shrinkWrap: true,
                                    physics: const NeverScrollableScrollPhysics(),
                                    itemCount: products.length,
                                    itemBuilder: (context, index) {
                                      final product = products[index];
                                      return Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: AppSpacing.md,
                                          vertical: AppSpacing.xxs,
                                        ),
                                        child: AppCard(
                                          padding: EdgeInsets.zero,
                                          child: ListTile(
                                            onTap: () {
                                              MainTabsScreen.of(context)?.navigateToProductDetails(product.id);
                                            },
                                            leading: ClipRRect(
                                              borderRadius: BorderRadius.circular(AppSpacing.xs),
                                              child: (product.image != null && product.image!.isNotEmpty)
                                                  ? Image.network(
                                                      fixImageUrl(product.image),
                                                      width: 50,
                                                      height: 50,
                                                      fit: BoxFit.cover,
                                                      errorBuilder: (context, error, stackTrace) {
                                                        return const Icon(Icons.image_not_supported);
                                                      },
                                                    )
                                                  : Icon(
                                                      Icons.image_not_supported,
                                                      size: 30,
                                                      color: Theme.of(context).colorScheme.outline,
                                                    ),
                                            ),
                                            title: Text(
                                              _capitalize(product.name),
                                              style: AppTypography.titleMedium,
                                            ),
                                            subtitle: Text(
                                              _capitalize("MWK ${product.price}"),
                                              style: AppTypography.bodyMedium,
                                            ),
                                            trailing: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                IconButton(
                                                  icon: Icon(
                                                    Icons.edit,
                                                    color: Theme.of(context).colorScheme.primary,
                                                  ),
                                                  onPressed: () {
                                                    MainTabsScreen.of(context)?.navigateToEditProduct(product);
                                                  },
                                                ),
                                                IconButton(
                                                  icon: Icon(
                                                    Icons.delete,
                                                    color: Theme.of(context).colorScheme.error,
                                                  ),
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
                                        ),
                                      );
                                    },
                                  );
                                },
                                loading: () => AppLoader.inline(),
                                error: (e, _) => Padding(
                                  padding: const EdgeInsets.all(AppSpacing.md),
                                  child: AppInfoBox(
                                    type: AppInfoType.error,
                                    message: _capitalize("Failed to load products: $e"),
                                  ),
                                ),
                              );
                            } else {
                              // ================= TAB 2: SHOP DETAILS VIEW =================
                              return Padding(
                                padding: const EdgeInsets.all(AppSpacing.md),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _capitalize("About our shop"),
                                      style: AppTypography.headlineSmall,
                                    ),
                                    const SizedBox(height: AppSpacing.xs),
                                    Text(
                                      _capitalize(shop.description),
                                      style: AppTypography.bodyMedium,
                                    ),
                                    const SizedBox(height: AppSpacing.lg),
                                    Text(
                                      _capitalize("Contact information"),
                                      style: AppTypography.headlineSmall,
                                    ),
                                    const SizedBox(height: AppSpacing.xs),
                                    ListTile(
                                      leading: const Icon(Icons.phone),
                                      title: Text(
                                        _capitalize("Phone"),
                                        style: AppTypography.titleMedium,
                                      ),
                                      subtitle: Text(
                                        shop.phoneNumber,
                                        style: AppTypography.bodyMedium,
                                      ),
                                      contentPadding: EdgeInsets.zero,
                                    ),
                                    ListTile(
                                      leading: const Icon(Icons.email),
                                      title: Text(
                                        _capitalize("Email"),
                                        style: AppTypography.titleMedium,
                                      ),
                                      subtitle: Text(
                                        shop.email.toLowerCase(),
                                        style: AppTypography.bodyMedium,
                                      ),
                                      contentPadding: EdgeInsets.zero,
                                    ),
                                    ListTile(
                                      leading: const Icon(Icons.location_on),
                                      title: Text(
                                        _capitalize("Location"),
                                        style: AppTypography.titleMedium,
                                      ),
                                      subtitle: Text(
                                        _capitalize("${shop.address}, ${shop.city}"),
                                        style: AppTypography.bodyMedium,
                                      ),
                                      contentPadding: EdgeInsets.zero,
                                    ),
                                  ],
                                ),
                              );
                            }
                          },
                        );
                      },
                    ),
                    
                    // ================= GLOBAL FOOTER INTEGRATION =================
                    const SizedBox(height: AppSpacing.lg),
                    const WebFooter(),
                  ],
                ),
              ),
            );
          },
          loading: () => Center(child: AppLoader.inline()),
          error: (error, _) => Center(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: AppInfoBox(
                type: AppInfoType.error,
                message: _capitalize("Error: $error"),
              ),
            ),
          ),
        ),

        // ================= FLOATING BUTTON OVERLAYS =================
        myShopAsync.maybeWhen(
          data: (shops) {
            if (shops.isEmpty) return const SizedBox.shrink();

            final shop = shops.first;

            return Positioned(
              bottom: AppSpacing.md,
              right: AppSpacing.md,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AppFab(
                    heroTag: "edit_shop",
                    icon: Icons.edit,
                    tooltip: _capitalize("Edit shop"),
                    toastMessage: _capitalize("Edit your shop"),
                    onPressed: () {
                      MainTabsScreen.of(context)?.navigateToEditShop(shop);
                    },
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  AppFab(
                    heroTag: "add_product",
                    icon: Icons.add,
                    tooltip: _capitalize("Add product"),
                    toastMessage: _capitalize("Add a new product"),
                    onPressed: () {
                      MainTabsScreen.of(context)?.navigateToAddProduct();
                    },
                  ),
                ],
              ),
            );
          },
          orElse: () => const SizedBox.shrink(),
        ),
      ],
    );
  }
}