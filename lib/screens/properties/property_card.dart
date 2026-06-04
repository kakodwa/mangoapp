// lib/widgets/properties/property_card.dart

import 'package:flutter/material.dart';
import '../../models/property_model.dart';
import '../../theme/app_colors.dart';

// Design System Imports
import '../../theme/design_system/app_card.dart';
import '../../theme/design_system/app_image_card.dart';
import '../../theme/design_system/app_badge.dart';
import '../../theme/design_system/app_typography.dart';
import '../../theme/design_system/app_spacing.dart';

import '../../widgets/capitalize_text.dart';

import 'property_details_screen.dart';

// Analytics Import
import '../../services/analytics_service.dart';

class PropertyCard extends StatelessWidget {
  final Property property;

  const PropertyCard({
    super.key,
    required this.property,
  });

  @override
  Widget build(BuildContext context) {
    final listingText = property.listingPurpose == 'rent' ? 'FOR RENT' : 'FOR SALE';

    final listingColor = property.listingPurpose == 'rent'
        ? Theme.of(context).colorScheme.primary
        : Theme.of(context).colorScheme.secondary;

    final subTextColor = Theme.of(context)
        .colorScheme
        .onSurfaceVariant
        .withOpacity(0.6);

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
          // 📊 TRACK EVENT: User tap-selected a specific property listing from a list
          analytics.logEvent('feed_property_card_click');

          Navigator.push(
            context,
            PageRouteBuilder(
              transitionDuration: const Duration(milliseconds: 250),
              pageBuilder: (_, __, ___) => PropertyDetailsScreen(propertyId: property.id),
              transitionsBuilder: (_, animation, __, child) {
                return FadeTransition(
                  opacity: animation,
                  child: ScaleTransition(
                    scale: Tween(begin: 0.95, end: 1.0).animate(
                      CurvedAnimation(
                        parent: animation,
                        curve: Curves.easeOutCubic,
                      ),
                    ),
                    child: child,
                  ),
                );
              },
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            AspectRatio(
              aspectRatio: 16 / 9,
              child: AppImageCard(
                imageUrl: property.images.isNotEmpty ? property.images.first.image : null,
                height: double.infinity,
                borderRadius: 14,
                placeholderIcon: Icons.home,
                badges: [
                  AppBadge(
                    text: property.propertyType.toLowerCase(),
                    type: BadgeType.primary,
                    fontSize: 9,
                  ),
                  AppBadge(
                    text: property.status.toLowerCase(),
                    type: BadgeType.warning,
                    fontSize: 9,
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
                          '${property.currency.toUpperCase()} ${property.price.toStringAsFixed(0)}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.titleMedium.copyWith(
                            color: AppColors.mangoOrange,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      AppBadge(
                        text: listingText.toLowerCase(),
                        customColor: listingColor,
                        fontSize: 9,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    capitalizeText(property.title), // UPDATED: Transformed to UPPERCASE
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.titleMedium.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        size: 13,
                        color: subTextColor,
                      ),
                      const SizedBox(width: 3),
                      Expanded(
                        child: Text(
                          '${capitalizeText(property.city)}, ${capitalizeText(property.district)}',
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.labelSmall.copyWith(
                            color: subTextColor,
                            letterSpacing: 0.5,
                          ),
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