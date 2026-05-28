import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/product_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/products_provider.dart';

import 'product_details_screen.dart';
import '../auth/login_screen.dart';
import '../products/edit_product_screen.dart';

import '../../utils/app_toast.dart';

class ProductCard extends ConsumerWidget {
  final Product product;

  const ProductCard({super.key, required this.product});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    final auth = ref.watch(authProvider);
    final isLoggedIn = auth.isAuthenticated;

    final isOwner =
        auth.user?.id != null && auth.user!.id == product.ownerId;

    final favorites = ref.watch(favoriteProvider);
    final isFav = favorites.contains(product.id);

    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) =>
                ProductDetailsScreen(productId: product.id),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // ================= IMAGE =================
            Expanded(
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(24),
                    ),
                    child: SizedBox.expand(
                      child: product.hasImage
                          ? Image.network(
                              product.safeImage,
                              fit: BoxFit.cover,
                            )
                          : Container(
                              color: Colors.grey.shade100,
                              child: const Icon(
                                Icons.image_outlined,
                                size: 45,
                                color: Colors.grey,
                              ),
                            ),
                    ),
                  ),

                  // gradient overlay
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.18),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // ================= FROSTED GLASS CATEGORY BADGE =================
                  Positioned(
                    top: 12,
                    left: 12,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(
                          sigmaX: 10,
                          sigmaY: 10,
                        ),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF2E7D32)
                                .withOpacity(0.65),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.25),
                              width: 1,
                            ),
                          ),
                          child: Text(
                            product.category,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // FAVORITE
                  Positioned(
                    top: 12,
                    right: 12,
                    child: GestureDetector(
                      onTap: () async {
                        if (!isLoggedIn) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const LoginScreen(),
                            ),
                          );
                          return;
                        }

                        await ref
                            .read(favoriteProvider.notifier)
                            .toggle(product.id);

                        AppToast.info(
                          context,
                          isFav
                              ? "Removed from favorites"
                              : "Added to favorites",
                        );
                      },
                      child: const Icon(
                        Icons.favorite_border,
                        color: Colors.white,
                        size: 22,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ================= INFO =================
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  // PRODUCT NAME
                  Text(
                    product.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      height: 1.3,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // ================= PRICE + ACTION =================
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [

                      // PRICE
                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [

                            if (product.hasDiscount)
                              Text(
                                "MWK ${product.originalPrice?.toStringAsFixed(0)}",
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey,
                                  decoration:
                                      TextDecoration.lineThrough,
                                ),
                              ),

                            Text(
                              "MWK ${product.price.toStringAsFixed(0)}",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: theme.primaryColor,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(width: 12),

                      // ACTION ICON
                      GestureDetector(
                        onTap: isOwner
                            ? () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        EditProductScreen(
                                      product: product,
                                    ),
                                  ),
                                );
                              }
                            : product.isInStock
                                ? () {
                                    if (!isLoggedIn) {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) =>
                                              const LoginScreen(),
                                        ),
                                      );
                                      return;
                                    }

                                    ref
                                        .read(addToCartProvider)
                                        .call(product, 1);

                                    AppToast.success(
                                      context,
                                      "Added to cart",
                                    );
                                  }
                                : null,
                        child: Icon(
                          isOwner
                              ? Icons.edit_rounded
                              : Icons.shopping_cart_outlined,
                          size: 23,
                          color: isOwner
                              ? const Color(0xFF2E7D32)
                              : product.isInStock
                                  ? const Color(0xFFFF8C00)
                                  : Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}