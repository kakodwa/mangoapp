import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/product_model.dart';
import '../../providers/products_provider.dart';
import 'product_details_screen.dart';
import '../../providers/auth_provider.dart';
import '../auth/login_screen.dart';
import '../products/edit_product_screen.dart';
import '../../theme/design_system/app_card.dart';
import '../../theme/design_system/app_badge.dart';
import '../../theme/design_system/app_icon_button.dart';
import '../../theme/design_system/app_spacing.dart';
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
          PageRouteBuilder(
            transitionDuration: const Duration(milliseconds: 250),
            pageBuilder: (_, __, ___) =>
                ProductDetailsScreen(productId: product.id),
            transitionsBuilder: (_, animation, __, child) {
              return FadeTransition(
                opacity: animation,
                child: ScaleTransition(
                  scale: Tween(begin: 0.95, end: 1.0).animate(
                    CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
                  ),
                  child: child,
                ),
              );
            },
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
                  top: AppSpacing.sm,
                  left: AppSpacing.sm,
                  child: AppBadge(
                    text: product.category,
                    type: BadgeType.primary,
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
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: const Color(0xFF212121),
                    ),
                  ),

                  //const SizedBox(height: AppSpacing.xs),

                  // RATING
                  /*Row(
                    children: [
                      const Icon(Icons.star,
                          size: 14, color: Color(0xFFFFC107)),
                      const SizedBox(width: 4),
                      Text(
                        product.rating.toString(),
                        style: theme.textTheme.labelSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        "(${product.totalReviews})",
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),*/

                  const SizedBox(height: AppSpacing.sm),

                  // PRICE + ACTION
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (product.hasDiscount)
                              Text(
                                'MWK ${product.originalPrice?.toStringAsFixed(2)}',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  decoration: TextDecoration.lineThrough,
                                  color: Colors.grey.shade500,
                                ),
                              ),

                            Text(
                              'MWK ${product.price.toStringAsFixed(2)}',
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: Theme.of(context).primaryColor,
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(width: AppSpacing.sm),

                      // Right Button
                      AppIconButton(
                        icon: isOwner ? Icons.edit : Icons.shopping_cart_outlined,
                        color: isOwner
                            ? const Color(0xFF1976D2)
                            : (product.isInStock
                                ? const Color(0xFFFF8C00)
                                : Colors.grey),
                        style: IconButtonStyle.filled,
                        onTap: isOwner
                            ? () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        EditProductScreen(product: product),
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

                                    ref
                                        .read(addToCartProvider)
                                        .call(product, 1);

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

}
