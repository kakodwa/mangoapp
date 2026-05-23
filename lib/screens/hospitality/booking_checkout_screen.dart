import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../models/room_model.dart';
import '../../models/requests/booking_create_request.dart';
import '../../providers/api_provider.dart';

import '../payments/payment_checkout_screen.dart';
import '../../theme/design_system/app_spacing.dart';

class BookingCheckoutScreen extends ConsumerStatefulWidget {
  final Room room;

  const BookingCheckoutScreen({
    super.key,
    required this.room,
  });

  @override
  ConsumerState<BookingCheckoutScreen> createState() =>
      _BookingCheckoutScreenState();
}

class _BookingCheckoutScreenState
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
      appBar: AppBar(title: Text('Booking Checkout')),
      body: Padding(
        padding: EdgeInsets.all(AppSpacing.md),
        child: Column(
          children: [
            ListTile(
              title: Text('Check In'),
              subtitle: Text(
                checkIn != null
                    ? formatDate(checkIn!)
                    : 'Select date',
              ),
              trailing: Icon(Icons.calendar_month),
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
              title: Text('Check Out'),
              subtitle: Text(
                checkOut != null
                    ? formatDate(checkOut!)
                    : 'Select date',
              ),
              trailing: Icon(Icons.calendar_month),
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
              height: 48,
              child: ElevatedButton(
                onPressed: loading ? null : submitBooking,
                child: loading
                    ? CircularProgressIndicator(color: Theme.of(context).colorScheme.surface)
                    : Text("Proceed To Payment"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}