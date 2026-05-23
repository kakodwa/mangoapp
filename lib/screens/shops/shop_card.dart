import 'package:flutter/material.dart';
import '../../models/shop_model.dart';
<<<<<<< HEAD
import '../../theme/design_system/app_badge.dart';
import '../../theme/design_system/app_icon_button.dart';
import '../../theme/design_system/app_spacing.dart';
=======
>>>>>>> 0cfc4702230a362924a138a5e87e31febed75a63
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
<<<<<<< HEAD
        Navigator.push(
          context,
=======
        Navigator.of(context).push(
>>>>>>> 0cfc4702230a362924a138a5e87e31febed75a63
          PageRouteBuilder(
            transitionDuration: const Duration(milliseconds: 250),
            pageBuilder: (_, __, ___) =>
                ShopDetailsScreen(shopId: shop.id),
            transitionsBuilder: (_, animation, __, child) {
              return FadeTransition(
                opacity: animation,
                child: ScaleTransition(
<<<<<<< HEAD
                  scale: Tween(begin: 0.95, end: 1.0).animate(
                    CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
                  ),
=======
                  scale: Tween(begin: 0.98, end: 1.0).animate(animation),
>>>>>>> 0cfc4702230a362924a138a5e87e31febed75a63
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

<<<<<<< HEAD
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
=======
                  // 🏷 CATEGORY (glass badge)
                  Positioned(
                    top: 10,
                    left: 10,
                    child: _badge(
                      text: shop.category,
                      color: Colors.orange,
                    ),
                  ),

                  // ✅ VERIFIED
                  Positioned(
                    top: 10,
                    right: 10,
                    child: _badge(
                      text: shop.isActive ? "VERIFIED" : "INACTIVE",
                      color: shop.isActive ? Colors.green : Colors.red,
                    ),
                  ),

                  // ⚡ QUICK ACTIONS (TikTok style)
                  Positioned(
                    bottom: 10,
                    right: 10,
                    child: Column(
                      children: [
                        _circleIcon(Icons.store),
                        const SizedBox(height: 8),
                        _circleIcon(Icons.favorite_border),
                        const SizedBox(height: 8),
                        _circleIcon(Icons.share_outlined),
>>>>>>> 0cfc4702230a362924a138a5e87e31febed75a63
                      ],
                    ),
                  ),
                ],
              ),

              // ================= INFO =================
              Padding(
<<<<<<< HEAD
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // SHOP NAME + PRODUCT COUNT
=======
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 🏪 SHOP NAME + PRODUCT COUNT
>>>>>>> 0cfc4702230a362924a138a5e87e31febed75a63
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            shop.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
<<<<<<< HEAD
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
=======
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Text(
                          "${shop.productCount ?? 0} products",
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
>>>>>>> 0cfc4702230a362924a138a5e87e31febed75a63
                        ),
                      ],
                    ),

<<<<<<< HEAD
                    const SizedBox(height: AppSpacing.xs),

                    // LOCATION + RATING
                    Row(
                      children: [
                        Icon(Icons.location_on,
                            size: 13,
                            color: Colors.grey.shade600),
                        const SizedBox(width: 3),
=======
                    const SizedBox(height: 6),

                    // 📍 LOCATION + ⭐ RATING
                    Row(
                      children: [
                        const Icon(Icons.location_on,
                            size: 14, color: Colors.grey),
                        const SizedBox(width: 4),
>>>>>>> 0cfc4702230a362924a138a5e87e31febed75a63
                        Expanded(
                          child: Text(
                            shop.district,
                            overflow: TextOverflow.ellipsis,
<<<<<<< HEAD
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
=======
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.star,
                            size: 14, color: Colors.amber),
                        const SizedBox(width: 4),
                        Text(
                          "${shop.rating}",
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
>>>>>>> 0cfc4702230a362924a138a5e87e31febed75a63
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

<<<<<<< HEAD
}
=======
  // ================= GLASS BADGE =================
  Widget _badge({required String text, required Color color}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.8),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  // ================= QUICK ACTION =================
  Widget _circleIcon(IconData icon) {
    return Container(
      padding: const EdgeInsets.all(7),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.4),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, size: 18, color: Colors.white),
    );
  }
}
>>>>>>> 0cfc4702230a362924a138a5e87e31febed75a63
