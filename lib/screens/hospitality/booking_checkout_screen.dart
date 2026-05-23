import 'package:flutter/material.dart';
<<<<<<< HEAD
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../models/room_model.dart';
import '../../models/requests/booking_create_request.dart';
import '../../providers/api_provider.dart';

import '../payments/payment_checkout_screen.dart';

class BookingCheckoutScreen extends ConsumerStatefulWidget {
=======

import '../../models/room_model.dart';
import 'booking_success_screen.dart';

class BookingCheckoutScreen extends StatefulWidget {
>>>>>>> 0cfc4702230a362924a138a5e87e31febed75a63
  final Room room;

  const BookingCheckoutScreen({
    super.key,
    required this.room,
  });

  @override
<<<<<<< HEAD
  ConsumerState<BookingCheckoutScreen> createState() =>
=======
  State<BookingCheckoutScreen> createState() =>
>>>>>>> 0cfc4702230a362924a138a5e87e31febed75a63
      _BookingCheckoutScreenState();
}

class _BookingCheckoutScreenState
<<<<<<< HEAD
    extends ConsumerState<BookingCheckoutScreen> {
  DateTime? checkIn;
  DateTime? checkOut;

  bool loading = false;

  String formatDate(DateTime date) =>
      DateFormat('yyyy-MM-dd').format(date);

  Future<void> submitBooking() async {
    if (checkIn == null || checkOut == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select dates")),
      );
      return;
    }

    setState(() => loading = true);

    try {
      final api = ref.read(apiClientProvider);

      /// 1. CREATE BOOKING
      final request = BookingParams(
        roomId: widget.room.id,
        checkInDate: formatDate(checkIn!),
        checkOutDate: formatDate(checkOut!),
      );

      print("🔥 BOOKING REQUEST => ${request.toJson()}");

      final bookingResponse = await api.post(
        'bookings/',
        data: request.toJson(),
        fromJson: (json) => json,
      );

      final bookingId = bookingResponse["id"];

      print("🔥 BOOKING CREATED => $bookingId");

      if (!mounted) return;

      /// 2. OPEN PAYMENT SCREEN
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => PaymentCheckoutScreen(
            transactionId: bookingId,
            amount: widget.room.pricePerNight,
            purpose: "booking",
            referenceType: "booking", // now FIXED

            onSuccess: (payment) {
              Navigator.pop(context); // payment screen
              Navigator.pop(context); // booking screen
            },
          ),
        ),
      );
    } catch (e) {
      print("❌ BOOKING ERROR => $e");

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Booking failed: $e")),
      );
    }

    setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Booking Checkout')),
=======
    extends State<BookingCheckoutScreen> {
  DateTime? checkIn;
  DateTime? checkOut;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Booking Checkout'),
      ),
>>>>>>> 0cfc4702230a362924a138a5e87e31febed75a63
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ListTile(
              title: const Text('Check In'),
              subtitle: Text(
<<<<<<< HEAD
                checkIn != null
                    ? formatDate(checkIn!)
                    : 'Select date',
=======
                checkIn?.toString() ?? 'Select date',
>>>>>>> 0cfc4702230a362924a138a5e87e31febed75a63
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
<<<<<<< HEAD

            ListTile(
              title: const Text('Check Out'),
              subtitle: Text(
                checkOut != null
                    ? formatDate(checkOut!)
                    : 'Select date',
=======
            ListTile(
              title: const Text('Check Out'),
              subtitle: Text(
                checkOut?.toString() ?? 'Select date',
>>>>>>> 0cfc4702230a362924a138a5e87e31febed75a63
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
<<<<<<< HEAD

            const Spacer(),

            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: loading ? null : submitBooking,
                child: loading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Proceed To Payment"),
=======
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
>>>>>>> 0cfc4702230a362924a138a5e87e31febed75a63
              ),
            ),
          ],
        ),
      ),
    );
  }
}