import 'package:flutter/material.dart';

import '../../models/shop_model.dart';
import '../../screens/shops/shop_card.dart';

class HorizontalShops extends StatefulWidget {
  final List<Shop> shops;
  final bool showHeader;

  const HorizontalShops({
    super.key,
    required this.shops,
    this.showHeader = true,
  });

  @override
  State<HorizontalShops> createState() => _HorizontalShopsState();
}

class _HorizontalShopsState extends State<HorizontalShops> {
  final ScrollController _scrollController = ScrollController();

  void _scrollLeft() {
    _scrollController.animateTo(
      _scrollController.offset - 320, // Scrolls one card width
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _scrollRight() {
    _scrollController.animateTo(
      _scrollController.offset + 320, // Scrolls one card width
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.shops.isEmpty) {
      return const SizedBox();
    }

    final bool isDesktop = MediaQuery.of(context).size.width >= 900;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.showHeader)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Popular Shops",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (isDesktop)
                    Row(
                      children: [
                        IconButton(
                          splashRadius: 24,
                          icon: const Icon(
                            Icons.arrow_back_ios_new_rounded,
                            size: 28, // Extra bold size
                            color: Colors.orange,
                          ),
                          onPressed: _scrollLeft,
                          tooltip: 'Scroll Left',
                        ),
                        const SizedBox(width: 4),
                        IconButton(
                          splashRadius: 24,
                          icon: const Icon(
                            Icons.arrow_forward_ios_rounded,
                            size: 28, // Extra bold size
                            color: Colors.orange,
                          ),
                          onPressed: _scrollRight,
                          tooltip: 'Scroll Right',
                        ),
                      ],
                    ),
                ],
              ),
            ),

          SizedBox(
            height: 280,
            child: Stack(
              children: [
                ListView.builder(
                  controller: _scrollController,
                  scrollDirection: Axis.horizontal,
                  itemCount: widget.shops.length,
                  itemBuilder: (_, index) {
                    return SizedBox(
                      width: 320,
                      child: ShopCard(
                        shop: widget.shops[index],
                      ),
                    );
                  },
                ),

                // Floating Extra-Bold Orange Arrows (active when section header is hidden)
                if (isDesktop && !widget.showHeader) ...[
                  Positioned(
                    left: 0,
                    top: 0,
                    bottom: 0,
                    child: Center(
                      child: IconButton(
                        padding: EdgeInsets.zero,
                        splashRadius: 24,
                        icon: const Icon(
                          Icons.chevron_left_rounded,
                          color: Colors.orange,
                          size: 36, // Extra thick stroke
                        ),
                        onPressed: _scrollLeft,
                      ),
                    ),
                  ),
                  Positioned(
                    right: 0,
                    top: 0,
                    bottom: 0,
                    child: Center(
                      child: IconButton(
                        padding: EdgeInsets.zero,
                        splashRadius: 24,
                        icon: const Icon(
                          Icons.chevron_right_rounded,
                          color: Colors.orange,
                          size: 36, // Extra thick stroke
                        ),
                        onPressed: _scrollRight,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}