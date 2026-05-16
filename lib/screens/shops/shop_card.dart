import 'package:flutter/material.dart';
import '../../models/shop_model.dart';
import '../../theme/design_system/app_badge.dart';
import '../../theme/design_system/app_icon_button.dart';
import '../../theme/design_system/app_spacing.dart';
import 'shop_details_screen.dart';

class ShopCard extends StatefulWidget {
  final Shop shop;

  const ShopCard({Key? key, required this.shop}) : super(key: key);

  @override
  State<ShopCard> createState() => _ShopCardState();
}

class _ShopCardState extends State<ShopCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final shop = widget.shop;

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
                ShopDetailsScreen(shopId: shop.id),
            transitionsBuilder: (_, animation, __, child) {
              return FadeTransition(
                opacity: animation,
                child: ScaleTransition(
                  scale: Tween(begin: 0.95, end: 1.0).animate(
                    CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
                  ),
                  child: child,
            ),
          ),
        );
      },
      child: AnimatedScale(
        duration: const Duration(milliseconds: 120),
        scale: _pressed ? 0.98 : 1.0,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 14,
                offset: const Offset(0, 6),
              )
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
                        height:170,
                        width: double.infinity,
                        child: shop.banner != null
                            ? Image.network(
                                shop.banner!,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) {
                                  return Container(
                                    color: Colors.grey.shade200,
                                    child: const Icon(Icons.store, size: 40),
                                  );
                                },
                              )
                            : Container(
                                color: Colors.grey.shade200,
                                child: const Icon(Icons.store, size: 40),
                              ),
                      ),
                    ),
                  ),

                  // 🌫 gradient overlay
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.black.withOpacity(0.05),
                            Colors.black.withOpacity(0.35),
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
                          text: shop.category,
                          type: BadgeType.primary,
                          fontSize: 9,
                        ),
                        const Spacer(),
                        AppBadge(
                          text: shop.isActive ? "VERIFIED" : "INACTIVE",
                          type: shop.isActive
                              ? BadgeType.success
                              : BadgeType.error,
                          fontSize: 9,
                        ),
                      ],
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
                    // SHOP NAME + PRODUCT COUNT
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            shop.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ),
                        Text(
                          "${shop.productCount ?? 0}",
                          style: Theme.of(context)
                              .textTheme
                              .labelSmall
                              ?.copyWith(
                                color: Colors.grey.shade600,
                              ),
                        ),
                      ],
                    ),

                    const SizedBox(height: AppSpacing.xs),

                    // LOCATION + RATING
                    Row(
                      children: [
                        Icon(Icons.location_on,
                            size: 13,
                            color: Colors.grey.shade600),
                        const SizedBox(width: 3),
                        Expanded(
                          child: Text(
                            shop.district,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context)
                                .textTheme
                                .labelSmall
                                ?.copyWith(
                                  color: Colors.grey.shade600,
                                ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Icon(Icons.star,
                            size: 13, color: Colors.amber),
                        const SizedBox(width: 3),
                        Text(
                          "${shop.rating}",
                          style: Theme.of(context)
                              .textTheme
                              .labelSmall
                              ?.copyWith(
                                color: Colors.grey.shade600,
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
