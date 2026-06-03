import 'package:flutter/material.dart';

import '../../models/property_model.dart';
import '../../theme/app_colors.dart';
import '../../theme/design_system/app_badge.dart';
import '../../theme/design_system/app_spacing.dart';
import 'property_details_screen.dart';

class PropertyCard extends StatefulWidget {
  final Property property;

  const PropertyCard({
    super.key,
    required this.property,
  });

  @override
  State<PropertyCard> createState() => _PropertyCardState();
}

class _PropertyCardState extends State<PropertyCard>
    with SingleTickerProviderStateMixin {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final property = widget.property;

    final listingText =
        property.listingPurpose == 'rent' ? 'FOR RENT' : 'FOR SALE';

    final listingColor = property.listingPurpose == 'rent'
        ? Theme.of(context).colorScheme.primary
        : Theme.of(context).colorScheme.secondary;

    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: () {
        Navigator.push(
          context,
          PageRouteBuilder(
            transitionDuration: const Duration(milliseconds: 250),
            pageBuilder: (_, __, ___) =>
                PropertyDetailsScreen(propertyId: property.id),
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
      child: AnimatedScale(
        duration: const Duration(milliseconds: 120),
        scale: _pressed ? 0.98 : 1.0,
        child: Container(
          margin: EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.sm,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            color: Theme.of(context).colorScheme.surface,
            boxShadow: [
              BoxShadow(
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withOpacity(0.06),
                blurRadius: 14,
                offset: const Offset(0, 6),
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
                      top: Radius.circular(18),
                    ),
                    child: AnimatedScale(
                      duration: const Duration(milliseconds: 250),
                      scale: _pressed ? 1.08 : 1.0,
                      child: SizedBox(
                        height: 170,
                        width: double.infinity,
                        child: property.images.isNotEmpty
                            ? Image.network(
                                property.images.first.image,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) {
                                  return Container(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant
                                        .withOpacity(0.25),
                                    child: const Icon(
                                      Icons.home,
                                      size: 40,
                                    ),
                                  );
                                },
                              )
                            : Container(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant
                                    .withOpacity(0.25),
                                child: const Icon(
                                  Icons.home,
                                  size: 40,
                                ),
                              ),
                      ),
                    ),
                  ),

                  // Gradient overlay
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withOpacity(0.05),
                            Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withOpacity(0.35),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                  ),

                  // BADGES
                  Positioned(
                    top: AppSpacing.sm,
                    left: AppSpacing.sm,
                    right: AppSpacing.sm,
                    child: Row(
                      children: [
                        AppBadge(
                          text: property.propertyType,
                          type: BadgeType.primary,
                          fontSize: 9,
                        ),
                        const Spacer(),
                        AppBadge(
                          text: property.status,
                          type: BadgeType.warning,
                          fontSize: 9,
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              // ================= INFO =================
              Padding(
                padding: EdgeInsets.all(AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // PRICE + LISTING TYPE
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            '${property.currency} ${property.price.toStringAsFixed(0)}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  color: AppColors.mangoOrange,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        AppBadge(
                          text: listingText,
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

                    // PROPERTY TITLE
                    Text(
                      property.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),

                    const SizedBox(height: AppSpacing.xs),

                    // LOCATION
                    Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          size: 13,
                          color: Theme.of(context)
                              .colorScheme
                              .onSurfaceVariant
                              .withOpacity(0.6),
                        ),
                        const SizedBox(width: 3),
                        Expanded(
                          child: Text(
                            '${property.city}, ${property.district}',
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context)
                                .textTheme
                                .labelSmall
                                ?.copyWith(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant
                                      .withOpacity(0.6),
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
      ),
    );
  }
}