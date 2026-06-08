// lib/widgets/shops/shop_card.dart

import 'package:flutter/material.dart';
import '../../models/shop_model.dart';

// Design System Imports
import '../../theme/design_system/app_card.dart';
import '../../theme/design_system/app_image_card.dart';
import '../../theme/design_system/app_badge.dart';
import '../../theme/design_system/app_typography.dart';
import '../../theme/design_system/app_spacing.dart';

import '../../widgets/capitalize_text.dart';

import 'shop_details_screen.dart';
import '../main_tabs_screen.dart';

// Analytics Import
import '../../services/analytics_service.dart';

class ShopCard extends StatelessWidget {
  final Shop shop;

  const ShopCard({
    super.key,
    required this.shop,
  });

  @override
  Widget build(BuildContext context) {
    final subTextColor = Theme.of(context).colorScheme.onSurfaceVariant;
    final AnalyticsService analytics = AnalyticsService();

    return Padding(
      // UPDATED: Set left and right padding to 2.0
      padding: const EdgeInsets.only(
        left: 2.0,
        right: 2.0,
        bottom: AppSpacing.sm,
      ),
      child: AppCard(
        padding: EdgeInsets.zero, 
        onTap: () {
          analytics.logEvent('shop_card_click');

          // ✅ FIX: Use persistent tab state navigation shell logic
          final tabsScreen = MainTabsScreen.of(context);
          if (tabsScreen != null) {
            tabsScreen.navigateToShopDetails(shop.id);
          } else {
            // Fallback just in case this card is ever rendered standalone
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => ShopDetailsScreen(shopId: shop.id)),
            );
          }
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            AspectRatio(
              aspectRatio: 16 / 9, 
              child: AppImageCard(
                imageUrl: shop.banner,
                height: double.infinity, 
                borderRadius: 14, 
                placeholderIcon: Icons.store,
                badges: [
                  AppBadge(
                    text: shop.category.toUpperCase(),
                    type: BadgeType.primary,
                  ),
                  AppBadge(
                    text: shop.isActive ? "VERIFIED" : "INACTIVE",
                    type: shop.isActive ? BadgeType.success : BadgeType.error,
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          capitalizeText(shop.name), // UPDATED: Transformed to UPPERCASE
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.titleMedium.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Text(
                        "${shop.productCount ?? 0}",
                        style: AppTypography.labelSmall.copyWith(
                          color: subTextColor,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: AppSpacing.xs),

                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        size: 13,
                        color: subTextColor,
                      ),
                      const SizedBox(width: AppSpacing.xxs),
                      Expanded(
                        child: Text(
                          capitalizeText(shop.district), 
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.labelSmall.copyWith(
                            color: subTextColor,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      const Icon(
                        Icons.star,
                        size: 13,
                        color: Colors.amber,
                      ),
                      const SizedBox(width: AppSpacing.xxs),
                      Text(
                        "${shop.rating}",
                        style: AppTypography.labelSmall.copyWith(
                          color: subTextColor,
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