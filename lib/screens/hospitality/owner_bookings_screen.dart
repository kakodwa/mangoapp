import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/owner_bookings_provider.dart';
import '../../widgets/hospitality/owner_booking_card.dart';
import '../../widgets/main_app_bar.dart';

class OwnerBookingsScreen extends ConsumerWidget {
  const OwnerBookingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookingsAsync = ref.watch(ownerBookingsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Owner Bookings'),),
      body: bookingsAsync.when(
        data: (bookings) {
          if (bookings.isEmpty) {
            return const Center(child: Text("No bookings found"));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: bookings.length,
            itemBuilder: (context, index) {
              return OwnerBookingCard(booking: bookings[index]);
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(e.toString())),
      ),
    );
  }
}