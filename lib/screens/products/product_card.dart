// lib/widgets/products/product_card.dart

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
import '../../utils/price_helper.dart';
import '../../widgets/capitalize_text.dart';

// Design System Imports
import '../../theme/design_system/app_card.dart';
import '../../theme/design_system/app_image_card.dart';
import '../../theme/design_system/app_icon_button.dart';
import '../../theme/app_colors.dart';
import '../../theme/design_system/app_typography.dart';
import '../../theme/design_system/app_spacing.dart';

// Analytics Import
import '../../services/analytics_service.dart';

class ProductCard extends ConsumerWidget {
  final Product product;

  const ProductCard({
    super.key,
    required this.product,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);
    final isLoggedIn = auth.isAuthenticated;

    final isOwner = auth.user?.id != null && auth.user!.id == product.ownerId;

    final favorites = ref.watch(favoriteProvider);
    final isFav = favorites.contains(product.id);
    
    final subTextColor = Theme.of(context).colorScheme.onSurfaceVariant;
    
    // Instantiate Analytics Service
    final AnalyticsService analytics = AnalyticsService();

    // Truncate category string to max 15 characters safely before formatting casing
    final String baseCategory = product.category.length > 15 
        ? '${product.category.substring(0, 15)}...' 
        : product.category;

    final String formattedCategory = capitalizeText(baseCategory);
    final String formattedName = capitalizeText(product.name);

    return Padding(
      padding: const EdgeInsets.only(
        left: 0.0,
        right: 0.0,
        bottom: AppSpacing.xs,
      ),
      child: AppCard(
        padding: EdgeInsets.zero,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ProductDetailsScreen(productId: product.id),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min, 
          children: [
            // ================= SQUARE IMAGE + BADGES SECTION =================
            AspectRatio(
              aspectRatio: 1,
              child: AppImageCard(
                imageUrl: product.hasImage ? product.safeImage : null,
                height: double.infinity,
                borderRadius: 14,
                placeholderIcon: Icons.image_outlined,
                badges: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: AppColors.leafGreen.withOpacity(0.85),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      formattedCategory,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.4,
                      ),
                    ),
                  ),
                  AppIconButton(
                    icon: isFav ? Icons.favorite : Icons.favorite_border,
                    style: IconButtonStyle.ghost,
                    color: Colors.white,
                    size: 28,
                    iconSize: 20,
                    onTap: () async {
                      if (!isLoggedIn) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const LoginScreen()),
                        );
                        return;
                      }

                      // 📊 TRACK EVENT: Favorite button clicked
                      analytics.logEvent('product_favorite_toggle_${product.id}');

                      await ref.read(favoriteProvider.notifier).toggle(product.id);

                      AppToast.info(
                        context,
                        isFav 
                            ? "REMOVED FROM FAVORITES" 
                            : "ADDED TO FAVORITES",
                      );
                    },
                  ),
                ],
              ),
            ),

            // ================= INFO CONTENT SECTION =================
            // ================= INFO CONTENT SECTION =================
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.sm,
                  AppSpacing.xs,
                  AppSpacing.sm,
                  AppSpacing.xs, 
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start, 
                  children: [
                    Text(
                      formattedName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis, 
                      style: AppTypography.titleMedium.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    
                    const SizedBox(height: 2), 

                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center, 
                      children: [
                        Expanded(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (product.hasDiscount)
                                Text(
                                  "MWK ${formatPrice(product.originalPrice ?? 0)}",
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTypography.bodySmall.copyWith(
                                    color: subTextColor,
                                    decoration: TextDecoration.lineThrough,
                                    fontSize: 10,
                                  ),
                                ),
                              // ✅ FIXED: Removed the invalid WidgetRef() instantiation wrapper completely
                              FittedBox(
                                fit: BoxFit.scaleDown,
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  "MWK ${formatPrice(product.price)}",
                                  maxLines: 1,
                                  style: AppTypography.titleMedium.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primary(context),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: AppSpacing.xxs),
                        AppIconButton(
                          icon: isOwner ? Icons.edit_rounded : Icons.shopping_cart_outlined,
                          style: IconButtonStyle.ghost,
                          size: 32,
                          iconSize: 19,
                          color: isOwner
                              ? AppColors.leafGreen
                              : (product.isInStock ? AppColors.mangoOrange : subTextColor),
                          onTap: isOwner
                              ? () {
                                  // 📊 TRACK EVENT: Owner Edit button clicked
                                  analytics.logEvent('product_owner_edit_click_${product.id}');

                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => EditProductScreen(product: product),
                                    ),
                                  );
                                }
                              : (product.isInStock
                                  ? () {
                                      if (!isLoggedIn) {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(builder: (_) => const LoginScreen()),
                                        );
                                        return;
                                      }

                                      // 📊 TRACK EVENT: Add to Cart button clicked
                                      analytics.logEvent('product_add_to_cart_click_${product.id}');

                                      ref.read(addToCartProvider).call(product, 1);
                                      AppToast.success(context, "ADDED TO CART");
                                    }
                                  : null),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}