import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/bookings_provider.dart';
import '../../widgets/hospitality/booking_card.dart';
import '../../theme/design_system/app_spacing.dart';

import '../../theme/app_colors.dart';
import '../../widgets/main_app_bar.dart';
import '../../widgets/main_drawer.dart';
import '../../widgets/app_scaffold.dart';

class MyBookingsScreen extends ConsumerWidget {
  const MyBookingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookingsAsync = ref.watch(bookingsProvider);

    return AppScaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: MainAppBar(
        title:'My Bookings',
      ),
      body: bookingsAsync.when(
        data: (bookings) {
          return ListView.builder(
            padding: EdgeInsets.all(AppSpacing.md),
            itemCount: bookings.length,
            itemBuilder: (context, index) {
              return BookingCard(booking: bookings[index]);
            },
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (e, _) => Center(
          child: Text(e.toString()),
        ),
      ),
    );
  }
}