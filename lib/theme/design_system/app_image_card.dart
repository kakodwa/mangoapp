import 'package:flutter/material.dart';

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
            // Image
            SizedBox(
              height: height,
              width: double.infinity,
              child: imageUrl != null && imageUrl!.isNotEmpty
                  ? Image.network(
                      imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) {
                        return _buildPlaceholder();
                      },
                    )
                  : _buildPlaceholder(),
            ),

            // Gradient Overlay (subtle)
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

            // Badges Container
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
