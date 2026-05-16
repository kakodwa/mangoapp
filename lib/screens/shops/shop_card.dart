import 'package:flutter/material.dart';
import '../../models/shop_model.dart';
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
        Navigator.of(context).push(
          PageRouteBuilder(
            transitionDuration: const Duration(milliseconds: 250),
            pageBuilder: (_, __, ___) =>
                ShopDetailsScreen(shopId: shop.id),
            transitionsBuilder: (_, animation, __, child) {
              return FadeTransition(
                opacity: animation,
                child: ScaleTransition(
                  scale: Tween(begin: 0.98, end: 1.0).animate(animation),
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
                      ],
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
                    // 🏪 SHOP NAME + PRODUCT COUNT
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            shop.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
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
                        ),
                      ],
                    ),

                    const SizedBox(height: 6),

                    // 📍 LOCATION + ⭐ RATING
                    Row(
                      children: [
                        const Icon(Icons.location_on,
                            size: 14, color: Colors.grey),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            shop.district,
                            overflow: TextOverflow.ellipsis,
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