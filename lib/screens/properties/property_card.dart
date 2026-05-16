import 'package:flutter/material.dart';
import '../../models/property_model.dart';
import '../../theme/app_colors.dart';
import 'property_details_screen.dart';
import 'property_card.dart';

class PropertyCard extends StatefulWidget {
  final Property property;

  const PropertyCard({super.key, required this.property});

  @override
  State<PropertyCard> createState() => _PropertyCardState();
}

class _PropertyCardState extends State<PropertyCard>
    with SingleTickerProviderStateMixin {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final property = widget.property;

    final listingText =property.listingPurpose == 'rent' ? 'FOR RENT' : 'FOR SALE';
    final listingColor = property.listingPurpose == 'rent' ? Colors.blue : Colors.green;

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
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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
                    child: SizedBox(
                      height: 200,
                      width: double.infinity,
                      child: property.images.isNotEmpty
                          ? Image.network(
                              property.images.first.image,
                              fit: BoxFit.cover,
                            )
                          : Container(
                              color: Colors.grey.shade200,
                              child: const Icon(Icons.home, size: 40),
                            ),
                    ),
                  ),

                  // TYPE BADGE
                  Positioned(
                    top: 12,
                    left: 12,
                    child: _glassBadge(
                      text: property.propertyType.toUpperCase(),
                      color: AppColors.mangoOrange,
                    ),
                  ),

                  // STATUS
                  Positioned(
                    top: 12,
                    right: 12,
                    child: _glassBadge(
                      text: property.status.toUpperCase(),
                      color: Colors.black,
                    ),
                  ),
                ],
              ),

              Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ================= PRICE + LISTING TYPE =================
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${property.currency} ${property.price.toStringAsFixed(0)}',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColors.mangoOrange,
                          ),
                        ),

                        // 🔥 NEW: FOR SALE / RENT BADGE
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: listingColor,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            listingText,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 6),

                    Text(
                      property.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 6),

                    Row(
                      children: [
                        Icon(Icons.location_on,
                            size: 14, color: Colors.grey.shade600),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            '${property.city}, ${property.district}',
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
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

  Widget _glassBadge({required String text, required Color color}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.75),
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
}