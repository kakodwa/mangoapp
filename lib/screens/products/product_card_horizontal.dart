// lib/widgets/products/product_card_horizontal.dart

// 1. Dart & Flutter Core Packages
import 'package:flutter/material.dart';

// 2. Third-Party Packages
import 'package:flutter_riverpod/flutter_riverpod.dart';

// 3. Project Imports

// Providers
import '../../providers/auth_provider.dart';
import '../../providers/products_provider.dart';

// Models
import '../../models/product_model.dart';
import '../../models/product_variant_model.dart'; 

// Screens & Layouts
import '../auth/login_screen.dart';
import '../main_tabs_screen.dart'; 
import '../products/edit_product_screen.dart';
import 'product_details_screen.dart';

// Widgets & Sub-components
import '../../widgets/capitalize_text.dart';

// Utils & Services
import '../../services/analytics_service.dart';
import '../../utils/app_toast.dart';

// Design System & Theme
import '../../theme/app_colors.dart';
import '../../theme/design_system/app_card.dart';
import '../../theme/design_system/app_icon_button.dart';
import '../../theme/design_system/app_image_card.dart';
import '../../theme/design_system/app_spacing.dart';
import '../../theme/design_system/app_typography.dart';

class ProductCardHorizontal extends ConsumerWidget {
  final Product product;

  const ProductCardHorizontal({
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

    final AnalyticsService analytics = AnalyticsService();

    final String baseCategory = product.category.length > 15 
        ? '${product.category.substring(0, 15)}...' 
        : product.category;

    final String formattedCategory = capitalizeText(baseCategory);
    final String formattedName = capitalizeText(product.name);

    final ImageProvider? imageProvider = product.hasImage 
        ? NetworkImage(product.safeImage) 
        : null;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: imageProvider != null
          ? FutureBuilder<ColorScheme>(
              future: ColorScheme.fromImageProvider(provider: imageProvider),
              builder: (context, snapshot) {
                // Extracts dominant palette from image or falls back to standard surface
                final dominantColor = snapshot.data?.surfaceContainerHighest ?? 
                    Theme.of(context).colorScheme.surfaceContainer;

                return _buildCardContent(
                  context: context,
                  ref: ref,
                  cardBackgroundColor: dominantColor.withOpacity(0.90),
                  primaryTextColor: _getContrastColor(dominantColor),
                  secondaryTextColor: _getContrastColor(dominantColor).withOpacity(0.70),
                  isLoggedIn: isLoggedIn,
                  isOwner: isOwner,
                  isFav: isFav,
                  analytics: analytics,
                  formattedCategory: formattedCategory,
                  formattedName: formattedName,
                );
              },
            )
          : _buildCardContent(
              context: context,
              ref: ref,
              cardBackgroundColor: Theme.of(context).colorScheme.surface.withOpacity(0.90),
              primaryTextColor: Theme.of(context).colorScheme.onSurface,
              secondaryTextColor: Theme.of(context).colorScheme.onSurfaceVariant,
              isLoggedIn: isLoggedIn,
              isOwner: isOwner,
              isFav: isFav,
              analytics: analytics,
              formattedCategory: formattedCategory,
              formattedName: formattedName,
            ),
    );
  }

  /// Calculates dynamic text contrast color to guarantee readability on top of dynamic image palettes
  Color _getContrastColor(Color bg) {
    return ThemeData.estimateBrightnessForColor(bg) == Brightness.dark
        ? Colors.white
        : const Color(0xFF1C1B1F);
  }

  Widget _buildCardContent({
    required BuildContext context,
    required WidgetRef ref,
    required Color cardBackgroundColor,
    required Color primaryTextColor,
    required Color secondaryTextColor,
    required bool isLoggedIn,
    required bool isOwner,
    required bool isFav,
    required AnalyticsService analytics,
    required String formattedCategory,
    required String formattedName,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: cardBackgroundColor,
        borderRadius: BorderRadius.circular(14),
      ),
      child: AppCard(
        padding: EdgeInsets.zero,
        onTap: () {
          final tabsScreen = MainTabsScreen.of(context);
          if (tabsScreen != null) {
            tabsScreen.navigateToProductDetails(product.id);
          } else {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ProductDetailsScreen(productId: product.id),
              ),
            );
          }
        },
        child: SizedBox(
          height: 120,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ================= SQUARE IMAGE + FAVORITE BUTTON =================
              SizedBox(
                width: 120,
                child: AppImageCard(
                  imageUrl: product.hasImage ? product.safeImage : null,
                  height: double.infinity,
                  borderRadius: 14,
                  placeholderIcon: Icons.image_outlined,
                  badges: [
                    AppIconButton(
                      icon: isFav ? Icons.favorite : Icons.favorite_border,
                      style: IconButtonStyle.ghost,
                      color: Colors.white,
                      size: 26,
                      iconSize: 18,
                      onTap: () async {
                        if (!isLoggedIn) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const LoginScreen()),
                          );
                          return;
                        }

                        analytics.logEvent('product_favorite_toggle_${product.id}');
                        await ref.read(favoriteProvider.notifier).toggle(product.id);

                        AppToast.info(
                          context,
                          isFav ? "REMOVED FROM FAVORITES" : "ADDED TO FAVORITES",
                        );
                      },
                    ),
                  ],
                ),
              ),

              // ================= DETAILS CONTENT =================
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
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Category Tag
                      Text(
                        formattedCategory.toUpperCase(),
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.leafGreen,
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 2),

                      // Product Title
                      Text(
                        formattedName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.titleMedium.copyWith(
                          color: primaryTextColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 2),

                      // ================= STAR RATING =================
                      Row(
                        children: [
                          ...List.generate(5, (index) {
                            final currentStarValue = index + 1;
                            if (product.rating >= currentStarValue) {
                              return const Icon(Icons.star_rounded, color: Colors.amber, size: 12);
                            } else if (product.rating > currentStarValue - 1 && product.rating < currentStarValue) {
                              return const Icon(Icons.star_half_rounded, color: Colors.amber, size: 12);
                            } else {
                              return Icon(Icons.star_border_rounded, color: secondaryTextColor, size: 12);
                            }
                          }),
                          const SizedBox(width: 4),
                          Text(
                            "(${product.totalReviews})",
                            style: AppTypography.bodySmall.copyWith(
                              color: secondaryTextColor,
                              fontSize: 9,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),

                      // ================= PRICE & CART/EDIT ACTION =================
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
                                    "MWK ${product.originalPrice ?? 0}",
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: AppTypography.bodySmall.copyWith(
                                      color: secondaryTextColor,
                                      decoration: TextDecoration.lineThrough,
                                      fontSize: 9,
                                    ),
                                  ),
                                Text(
                                  "MWK ${product.price}",
                                  maxLines: 1,
                                  style: AppTypography.titleMedium.copyWith(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                    color: AppColors.primary(context),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: AppSpacing.xxs),
                          AppIconButton(
                            icon: isOwner ? Icons.edit_rounded : Icons.shopping_cart_outlined,
                            style: IconButtonStyle.ghost,
                            size: 30,
                            iconSize: 18,
                            color: isOwner
                                ? AppColors.leafGreen
                                : (product.isInStock ? AppColors.mangoOrange : secondaryTextColor),
                            onTap: isOwner
                                ? () {
                                    analytics.logEvent('product_owner_edit_click_${product.id}');
                                    MainTabsScreen.of(context)?.navigateToEditProduct(product);
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

                                        analytics.logEvent('product_add_to_cart_click_${product.id}');

                                        dynamic defaultVariant;
                                        if (product.variants.isNotEmpty) {
                                          final inStockVariants = product.variants.where((v) => v.stock > 0);
                                          if (inStockVariants.isNotEmpty) {
                                            defaultVariant = inStockVariants.first;
                                          } else {
                                            AppToast.error(context, "All options for this product are sold out!");
                                            return;
                                          }
                                        }

                                        ref.read(addToCartProvider).call(
                                          product,
                                          1,
                                          defaultVariant,
                                        );

                                        final String optionLabel = defaultVariant != null && defaultVariant.attributes.isNotEmpty
                                            ? " (${defaultVariant.attributes.values.join(', ')})"
                                            : "";

                                        AppToast.success(context, "ADDED TO CART$optionLabel");
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
      ),
    );
  }
}