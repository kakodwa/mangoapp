import 'package:flutter/material.dart';

import '../../models/property_model.dart';
import '../../screens/properties/property_card.dart';


class HorizontalProperties extends StatelessWidget {
  final List<Property> properties;
  final bool showHeader;

  const HorizontalProperties({
    super.key,
    required this.properties,
    this.showHeader = true,
  });

  @override
  Widget build(BuildContext context) {
    if (properties.isEmpty) {
      return const SizedBox();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showHeader)
          const Padding(
            padding: EdgeInsets.all(12),
            child: Text(
              "Featured Properties",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

        SizedBox(
          height: 310,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: properties.length,
            itemBuilder: (_, index) {
              return SizedBox(
                width: 320,
                child: PropertyCard(
                  property: properties[index],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}