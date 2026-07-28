import 'package:flutter/material.dart';

import '../../models/product_model.dart';
import '../../screens/products/product_card_horizontal.dart';

class HorizontalProducts extends StatelessWidget {
  final List<Product> products;
  final bool showHeader;

  const HorizontalProducts({
    super.key,
    required this.products,
    this.showHeader = true,
  });

  @override
  Widget build(BuildContext context) {
    if (products.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showHeader)
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              "Recommended Products",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

        Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: SizedBox(
            height: 132, // Adjusted to match horizontal card height + padding
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: products.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (_, index) {
                return SizedBox(
                  width: 310, // Gives enough width for title, price & buttons side-by-side
                  child: ProductCardHorizontal(
                    product: products[index],
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}