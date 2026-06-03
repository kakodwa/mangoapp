import 'package:flutter/material.dart';

import '../../models/lodge_model.dart';
import '../hospitality/lodge_card.dart';


class HorizontalLodges extends StatelessWidget {
  final List<Lodge> lodges;
  final bool showHeader;

  const HorizontalLodges({
    super.key,
    required this.lodges,
    this.showHeader = true,
  });

  @override
  Widget build(BuildContext context) {
    if (lodges.isEmpty) {
      return const SizedBox();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showHeader)
          const Padding(
            padding: EdgeInsets.all(12),
            child: Text(
              "Recommended Lodges",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

        SizedBox(
          height: 290,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: lodges.length,
            itemBuilder: (_, index) {
              return SizedBox(
                width:320,
                child: LodgeCard(
                  lodge: lodges[index],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}