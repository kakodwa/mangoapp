// lib/screens/hospitality/availability_calendar_screen.dart
import 'package:flutter/material.dart';

import '../../widgets/hospitality/availability_calendar.dart';
import '../../theme/design_system/app_spacing.dart';
import '../../widgets/web_footer.dart';
import '../main_tabs_screen.dart'; // Import added to use main tab navigation system hooks

class AvailabilityCalendarScreen extends StatelessWidget {
  final int roomId;

  const AvailabilityCalendarScreen({
    super.key,
    required this.roomId,
  });

  @override
  Widget build(BuildContext context) {
    // ✅ FIXED: Scaffold and redundant App Bar removed. Built inside a responsive CustomScrollView canvas.
    return Material(
      color: const Color(0xFFF5F7FA),
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Center(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 1200),
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  children: [
                    AvailabilityCalendar(
                      roomId: roomId,
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          const SliverToBoxAdapter(child: SizedBox(height: 120)),
          
          // Securely appends the responsive web footer view at the bottom of the viewport
          const SliverFillRemaining(
            hasScrollBody: false,
            child: Align(
              alignment: Alignment.bottomCenter,
              child: WebFooter(),
            ),
          ),
        ],
      ),
    );
  }
}