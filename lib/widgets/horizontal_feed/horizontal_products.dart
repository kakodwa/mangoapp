import 'package:flutter/material.dart';

import '../../models/product_model.dart';
import '../../screens/products/product_card.dart';


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
      return const SizedBox();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showHeader)
          const Padding(
            padding: EdgeInsets.all(12),
            child: Text(
              "Recommended Products",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          Padding(
  padding: const EdgeInsets.only(bottom: 16), // 👈 bottom space here
  child: SizedBox(
    height: 250,
    child: ListView.separated(
      scrollDirection: Axis.horizontal,
      itemCount: products.length,
      separatorBuilder: (_, __) => const SizedBox(width: 12),
      itemBuilder: (_, index) {
        return SizedBox(
          width: 180,
          child: ProductCard(
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