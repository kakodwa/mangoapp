import 'package:flutter/material.dart';

import '../../widgets/hospitality/availability_calendar.dart';

class AvailabilityCalendarScreen extends StatelessWidget {
<<<<<<< HEAD
  final int roomId;

  const AvailabilityCalendarScreen({
    super.key,
    required this.roomId,
  });
=======
  const AvailabilityCalendarScreen({super.key});
>>>>>>> 0cfc4702230a362924a138a5e87e31febed75a63

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Availability Calendar'),
      ),
<<<<<<< HEAD
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: AvailabilityCalendar(
          roomId: roomId,
        ),
      ),
=======
      body: const AvailabilityCalendar(),
>>>>>>> 0cfc4702230a362924a138a5e87e31febed75a63
    );
  }
}