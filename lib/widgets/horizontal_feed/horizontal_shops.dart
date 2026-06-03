import 'package:flutter/material.dart';

import '../../models/shop_model.dart';
import '../../screens/shops/shop_card.dart';


class HorizontalShops extends StatelessWidget {
  final List<Shop> shops;
  final bool showHeader;

  const HorizontalShops({
    super.key,
    required this.shops,
    this.showHeader = true,
  });

  @override
  Widget build(BuildContext context) {
    if (shops.isEmpty) {
      return const SizedBox();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showHeader)
          const Padding(
            padding: EdgeInsets.all(12),
            child: Text(
              "Popular Shops",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

        SizedBox(
          height: 280,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: shops.length,
            itemBuilder: (_, index) {
              return SizedBox(
                width: 320,
                child: ShopCard(
                  shop: shops[index],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}