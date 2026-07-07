import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../models/room_model.dart';
import '../../models/requests/booking_create_request.dart';
import '../../providers/api_provider.dart';

import '../../widgets/main_drawer.dart';
import '../../widgets/main_app_bar.dart';

import '../../widgets/web_footer.dart';

import '../payments/payment_checkout_screen.dart';
import '../../theme/design_system/app_spacing.dart';
// Import your Analytics Service (Adjust path matching your directory layout)
import '../../services/analytics_service.dart';

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

  // Static final analytics instance
  static final AnalyticsService _analyticsService = AnalyticsService();

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

    // Track the initiation of the booking API request submission
    _analyticsService.logEvent('booking_submit_attempt_room_${widget.room.id}');

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

      // Track server-side creation success before shifting down onto checkout views
      _analyticsService.logEvent('booking_created_success_$bookingId');

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
              // Track successful terminal payments matching the record hook
              _analyticsService.logEvent('booking_payment_success_$bookingId');

              Navigator.pop(context); // payment screen
              Navigator.pop(context); // booking screen
            },
          ),
        ),
      );
    } catch (e) {
      print("❌ BOOKING ERROR => $e");

      // Track failures to catch layout blockades or network drops
      _analyticsService.logEvent('booking_submit_failed_room_${widget.room.id}');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Booking failed: $e")),
      );
    }

    setState(() => loading = false);
  }

  @override
  void initState() {
    super.initState();
    // Track screen entry point initialization 
    _analyticsService.logEvent('view_booking_checkout_room_${widget.room.id}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(title: const Text('Booking Checkout'),),
      body: Padding(
        padding: EdgeInsets.all(AppSpacing.md),
        child: Column(
          children: [
            ListTile(
              title: const Text('Check In'),
              subtitle: Text(
                checkIn != null
                    ? formatDate(checkIn!)
                    : 'Select date',
              ),
              trailing: const Icon(Icons.calendar_month),
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  firstDate: DateTime.now(),
                  lastDate: DateTime(2030),
                );

                if (picked != null) {
                  _analyticsService.logEvent('booking_date_select_checkin');
                  setState(() => checkIn = picked);
                }
              },
            ),

            ListTile(
              title: const Text('Check Out'),
              subtitle: Text(
                checkOut != null
                    ? formatDate(checkOut!)
                    : 'Select date',
              ),
              trailing: const Icon(Icons.calendar_month),
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  firstDate: DateTime.now(),
                  lastDate: DateTime(2030),
                );

                if (picked != null) {
                  _analyticsService.logEvent('booking_date_select_checkout');
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
                    : const Text("Proceed To Payment"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}