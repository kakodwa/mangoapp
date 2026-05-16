import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/product_model.dart';
import '../../providers/products_provider.dart';
import 'product_details_screen.dart';
import '../../providers/auth_provider.dart';
import '../auth/login_screen.dart';
import '../products/edit_product_screen.dart';
import '../../theme/design_system/app_card.dart';
import '../../utils/app_toast.dart';

class ProductCard extends ConsumerWidget {
  final Product product;

  const ProductCard({Key? key, required this.product}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    final authState = ref.watch(authProvider);
    final isLoggedIn = authState.isAuthenticated;

    final favorites = ref.watch(favoriteProvider);
    final isFav = favorites.contains(product.id);

    final currentUserId = authState.user?.id;
    final isOwner =
        currentUserId != null && product.ownerId == currentUserId;

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) =>
                ProductDetailsScreen(productId: product.id),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // ================= IMAGE =================
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                  child: SizedBox(
                    height: 150,
                    width: double.infinity,
                    child: product.hasImage
                        ? Image.network(
                            product.safeImage,
                            fit: BoxFit.cover,
                          )
                        : Container(
                            color: Colors.grey.shade200,
                            child: Icon(
                              Icons.image,
                              color: Colors.grey.shade400,
                              size: 40,
                            ),
                          ),
                  ),
                ),

                // DARK OVERLAY FOR MODERN LOOK
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.black.withOpacity(0.0),
                          Colors.black.withOpacity(0.2),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ),

                // CATEGORY BADGE
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.black.withOpacity(0.65),
                    ),
                    child: Text(
                      product.category,
                      style: const TextStyle(
                        fontSize: 11,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),

                // FAVORITE BUTTON
                if (!isOwner)
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

                        final updatedFav = await ref
                            .read(favoriteProvider.notifier)
                            .toggle(product.id);

                        AppToast.info(
                          context,
                          updatedFav
                              ? 'Added to favorites'
                              : 'Removed from favorites',
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.15),
                              blurRadius: 10,
                              offset: const Offset(0, 2),
                            )
                          ],
                        ),
                        child: Icon(
                          isFav
                              ? Icons.favorite
                              : Icons.favorite_border,
                          size: 20,
                          color: isFav ? Colors.red : Colors.grey.shade600,
                        ),
                      ),
                    ),
                  ),
              ],
            ),

            // ================= INFO =================
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  Text(
                    product.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      height: 1.3,
                      fontSize: 15,
                      color: const Color(0xFF212121),
                    ),
                  ),

                  const SizedBox(height: 8),

                  // RATING
                  Row(
                    children: [
                      const Icon(Icons.star,
                          size: 15, color: Color(0xFFFFC107)),
                      const SizedBox(width: 5),
                      Text(
                        product.rating.toString(),
                        style: theme.textTheme.labelSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        "(${product.totalReviews} reviews)",
                        style: const TextStyle(
                          color: Color(0xFF999999),
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  // PRICE + ACTION
                  Row(
                    children: [
                      // LEFT SIDE (takes remaining space safely)
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (product.hasDiscount)
                              Text(
                                'MWK ${product.originalPrice?.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  decoration: TextDecoration.lineThrough,
                                  fontSize: 12,
                                  color: Color(0xFFBBBBBB),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),

                            Text(
                              'MWK ${product.price.toStringAsFixed(2)}',
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).primaryColor,
                                letterSpacing: 0.3,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(width: 10),

                      // RIGHT BUTTON (fixed safe area)
                      _circleButton(
                        icon: isOwner
                            ? Icons.edit
                            : Icons.shopping_cart_outlined,
                        color: isOwner
                            ? const Color(0xFF1976D2)
                            : (product.isInStock ? const Color(0xFFFF8C00) : Colors.grey),
                        onTap: isOwner
                            ? () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => EditProductScreen(product: product),
                                  ),
                                );
                              }
                            : product.isInStock
                                ? () {
                                    if (!isLoggedIn) {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => const LoginScreen(),
                                        ),
                                      );
                                      return;
                                    }

                                    ref.read(addToCartProvider).call(product, 1);

                                    AppToast.success(
                                      context,
                                      '${product.name} added to cart',
                                    );
                                  }
                                : null,
                      ),
                    ],
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================= BUTTON =================
  Widget _circleButton({
    required IconData icon,
    required Color color,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color.withOpacity(0.15),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 2),
            )
          ],
        ),
        child: Icon(icon, size: 20, color: color),
      ),
    );
  }
}
