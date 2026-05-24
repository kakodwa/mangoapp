import 'package:flutter/material.dart';

import '../../widgets/hospitality/availability_calendar.dart';
import '../../widgets/main_app_bar.dart';
import '../../theme/app_colors.dart';
import '../../widgets/app_scaffold.dart';
import '../../theme/design_system/app_spacing.dart';

class AvailabilityCalendarScreen extends StatelessWidget {
  final int roomId;

  const AvailabilityCalendarScreen({
    super.key,
    required this.roomId,
  });

  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: const MainAppBar(title: 'Availability Calendar'),
      body: Padding(
        padding: EdgeInsets.all(AppSpacing.md),
        child: AvailabilityCalendar(
          roomId: roomId,
        ),
      ),
    );
  }
}