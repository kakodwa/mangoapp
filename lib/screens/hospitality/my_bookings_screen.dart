import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/bookings_provider.dart';
import '../../widgets/hospitality/booking_card.dart';

// Design System Imports
import '../../theme/design_system/app_loader.dart';
import '../../theme/design_system/app_info_box.dart';
import '../../theme/design_system/app_spacing.dart';
import '../../theme/design_system/app_typography.dart';
import '../../widgets/app_scaffold.dart';

// First-letter capitalization extension string utility
extension CapitalizeString on String {
  String toCapitalized() {
    if (isEmpty) return this;
    final lower = toLowerCase();
    return "${lower[0].toUpperCase()}${lower.substring(1)}";
  }
}

class MyBookingsScreen extends ConsumerWidget {
  const MyBookingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookingsAsync = ref.watch(bookingsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Text(
          'My bookings'.toCapitalized(),
          style: AppTypography.headlineMedium,
        ),
      ),
      body: bookingsAsync.when(
        data: (bookings) {
          if (bookings.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: AppInfoBox(
                  type: AppInfoType.info,
                  message: "No bookings found".toCapitalized(),
                ),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(AppSpacing.md),
            itemCount: bookings.length,
            itemBuilder: (context, index) {
              return Padding(
                // FIXED: Changed from EdgeInsets.vertical to EdgeInsets.symmetric
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxs),
                child: BookingCard(booking: bookings[index]),
              );
            },
          );
        },
        loading: () => Center(
          child: AppLoader.inline(),
        ),
        error: (e, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: AppInfoBox(
              type: AppInfoType.error,
              message: e.toString().toCapitalized(),
            ),
          ),
        ),
      ),
    );
  }
}