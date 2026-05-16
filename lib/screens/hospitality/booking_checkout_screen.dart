import 'package:flutter/material.dart';

import '../../models/room_model.dart';
import 'booking_success_screen.dart';

class BookingCheckoutScreen extends StatefulWidget {
  final Room room;

  const BookingCheckoutScreen({
    super.key,
    required this.room,
  });

  @override
  State<BookingCheckoutScreen> createState() =>
      _BookingCheckoutScreenState();
}

class _BookingCheckoutScreenState
    extends State<BookingCheckoutScreen> {
  DateTime? checkIn;
  DateTime? checkOut;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Booking Checkout'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ListTile(
              title: const Text('Check In'),
              subtitle: Text(
                checkIn?.toString() ?? 'Select date',
              ),
              trailing: const Icon(Icons.calendar_month),
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  firstDate: DateTime.now(),
                  lastDate: DateTime(2030),
                );

                if (picked != null) {
                  setState(() => checkIn = picked);
                }
              },
            ),
            ListTile(
              title: const Text('Check Out'),
              subtitle: Text(
                checkOut?.toString() ?? 'Select date',
              ),
              trailing: const Icon(Icons.calendar_month),
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  firstDate: DateTime.now(),
                  lastDate: DateTime(2030),
                );

                if (picked != null) {
                  setState(() => checkOut = picked);
                }
              },
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const BookingSuccessScreen(),
                    ),
                  );
                },
                child: const Text('Proceed To Payment'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}