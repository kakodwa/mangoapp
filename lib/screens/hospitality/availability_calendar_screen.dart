import 'package:flutter/material.dart';

import '../../widgets/hospitality/availability_calendar.dart';

class AvailabilityCalendarScreen extends StatelessWidget {
  final int roomId;

  const AvailabilityCalendarScreen({
    super.key,
    required this.roomId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Availability Calendar'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: AvailabilityCalendar(
          roomId: roomId,
        ),
      ),
    );
  }
}