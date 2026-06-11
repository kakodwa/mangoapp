// lib/theme/design_system/app_image_card.dart

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';

class AppImageCard extends StatelessWidget {
  final String? imageUrl;
  final double height;
  final double borderRadius;
  final Widget? overlay;
  final List<Widget>? badges;
  final VoidCallback? onTap;
  final IconData? placeholderIcon;

  const AppImageCard({
    super.key,
    this.imageUrl,
    this.height = 150,
    this.borderRadius = 16,
    this.overlay,
    this.badges,
    this.onTap,
    this.placeholderIcon = Icons.image,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: Stack(
          children: [
            // ================= SHIMMER OPTIMIZED NETWORK IMAGE MIGRATION =================
            SizedBox(
              height: height,
              width: double.infinity,
              child: imageUrl != null && imageUrl!.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: imageUrl!,
                      fit: BoxFit.cover,
                      // Smoothly render a glowing placeholder box during initial server payload download
                      placeholder: (context, url) => Shimmer.fromColors(
                        baseColor: Colors.grey.shade300,
                        highlightColor: Colors.grey.shade100,
                        child: Container(
                          color: Colors.white,
                          width: double.infinity,
                          height: double.infinity,
                        ),
                      ),
                      errorWidget: (_, __, ___) {
                        return _buildPlaceholder();
                      },
                    )
                  : _buildPlaceholder(),
            ),

            // Gradient Overlay (subtle ambient drop text protection layer)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.black.withOpacity(0.0),
                      Colors.black.withOpacity(0.15),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ),

            // Custom Overlay
            if (overlay != null) Positioned.fill(child: overlay!),

            // Badges Container (Pins favorite heart buttons and category text cleanly)
            if (badges != null && badges!.isNotEmpty)
              Positioned(
                top: 10,
                left: 10,
                right: 10,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: badges!,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: Colors.grey.shade200,
      child: Icon(
        placeholderIcon,
        size: 40,
        color: Colors.grey.shade400,
      ),
    );
  }
}