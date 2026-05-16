import 'package:flutter/material.dart';

import '../../widgets/hospitality/availability_calendar.dart';

class AvailabilityCalendarScreen extends StatelessWidget {
  const AvailabilityCalendarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Availability Calendar'),
      ),
      body: const AvailabilityCalendar(),
    );
  }
}