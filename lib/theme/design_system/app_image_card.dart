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
    this.placeholderIcon = Icons.image_outlined,
  });

  @override
  Widget build(BuildContext context) {
    // Sanitize image URL
    final validUrl = (imageUrl != null && imageUrl!.trim().isNotEmpty)
        ? imageUrl!.trim()
        : null;

    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: Stack(
          children: [
            // ================= SHIMMER OPTIMIZED NETWORK IMAGE =================
            SizedBox(
              height: height,
              width: double.infinity,
              child: validUrl != null
                  ? CachedNetworkImage(
                      imageUrl: validUrl,
                      fit: BoxFit.cover,
                      // 🔑 Pass headers so Apache / Namecheap does not block Dart native requests
                      httpHeaders: const {
                        'User-Agent':
                            'Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Mobile Safari/537.36',
                        'Accept':
                            'image/avif,image/webp,image/apng,image/svg+xml,image/*,*/*;q=0.8',
                      },
                      placeholder: (context, url) => Shimmer.fromColors(
                        baseColor: Colors.grey.shade300,
                        highlightColor: Colors.grey.shade100,
                        child: Container(
                          color: Colors.white,
                          width: double.infinity,
                          height: double.infinity,
                        ),
                      ),
                      // 🔑 Print the EXACT error in debug terminal when loading fails
                      errorWidget: (context, url, error) {
                        debugPrint('❌ APK Image Load Error for URL: $url');
                        debugPrint('❌ Exception details: $error');
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
      width: double.infinity,
      height: double.infinity,
      child: Center(
        child: Icon(
          placeholderIcon,
          size: 40,
          color: Colors.grey.shade400,
        ),
      ),
    );
  }
}