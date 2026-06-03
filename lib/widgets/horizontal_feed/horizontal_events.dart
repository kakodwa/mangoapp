import 'package:flutter/material.dart';

import '../../models/event_model.dart';
import '../events/event_card.dart';

class HorizontalEvents extends StatelessWidget {
  final List<EventModel> events;
  final bool showHeader;

  const HorizontalEvents({
    super.key,
    required this.events,
    this.showHeader = true,
  });

  @override
  Widget build(BuildContext context) {
    if (events.isEmpty) {
      return const SizedBox();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showHeader)
          const Padding(
            padding: EdgeInsets.all(12),
            child: Text(
              "Upcoming Events",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

        SizedBox(
          height: 375,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: events.length,
            itemBuilder: (_, index) {
              return SizedBox(
                width:320,
                child: EventCard(
                  event: events[index],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}