import 'package:flutter/material.dart';

import '../../models/booking_model.dart';

class BookingCard extends StatelessWidget {
  final Booking booking;

  const BookingCard({
    super.key,
    required this.booking,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              booking.bookingReference,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 8),
            Text('Check In: ${booking.checkInDate}'),
            Text('Check Out: ${booking.checkOutDate}'),
            const SizedBox(height: 8),
            Text('Status: ${booking.bookingStatus}'),
            Text('Payment: ${booking.paymentStatus}'),
            const SizedBox(height: 8),
            Text('MWK ${booking.totalAmount}'),
          ],
        ),
      ),
    );
  }
}