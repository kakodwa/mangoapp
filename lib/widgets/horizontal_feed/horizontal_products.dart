import 'package:flutter/material.dart';

import '../../models/product_model.dart';
import '../../screens/products/product_card_horizontal.dart';

class HorizontalProducts extends StatefulWidget {
  final List<Product> products;
  final bool showHeader;

  const HorizontalProducts({
    super.key,
    required this.products,
    this.showHeader = true,
  });

  @override
  State<HorizontalProducts> createState() => _HorizontalProductsState();
}

class _HorizontalProductsState extends State<HorizontalProducts> {
  final ScrollController _scrollController = ScrollController();

  void _scrollLeft() {
    _scrollController.animateTo(
      _scrollController.offset - 322, // 310 width + 12 separator
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _scrollRight() {
    _scrollController.animateTo(
      _scrollController.offset + 322, // 310 width + 12 separator
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
    if (widget.products.isEmpty) {
      return const SizedBox.shrink();
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
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Recommended Products",
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
                            size: 28, // 🔑 Increased size for extra boldness
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
                            size: 28, // 🔑 Increased size for extra boldness
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

          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: SizedBox(
              height: 132, // Adjusted to match horizontal card height + padding
              child: Stack(
                children: [
                  ListView.separated(
                    controller: _scrollController,
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: widget.products.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 12),
                    itemBuilder: (_, index) {
                      return SizedBox(
                        width: 310, // Gives enough width for title, price & buttons side-by-side
                        child: ProductCardHorizontal(
                          product: widget.products[index],
                        ),
                      );
                    },
                  ),

                  // Floating Extra-Bold Orange Arrows (when section header is hidden)
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
                            size: 36, // 🔑 Extra thick chevron stroke
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
                            size: 36, // 🔑 Extra thick chevron stroke
                          ),
                          onPressed: _scrollRight,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}