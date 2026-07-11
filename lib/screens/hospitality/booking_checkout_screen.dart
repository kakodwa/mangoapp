import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../models/room_model.dart';
import '../../models/requests/booking_create_request.dart';
import '../../providers/api_provider.dart';

import '../../widgets/web_footer.dart';
import '../main_tabs_screen.dart'; // Added to use tab matrix routing hooks
import '../payments/payment_checkout_screen.dart';
import '../../theme/design_system/app_spacing.dart';
import '../../theme/design_system/app_card.dart';
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

      /// 2. OPEN PAYMENT SCREEN MATCHING TABS CHECKOUT ENGINE FLOW
      final tabsScreen = MainTabsScreen.of(context);

      if (tabsScreen != null) {
        // ✅ FIXED: Routes directly inside the tab slot view framework engine at index 42
        tabsScreen.navigateToPayment(
          transactionId: bookingId,
          amount: widget.room.pricePerNight,
          purpose: "booking",
          referenceType: "booking",
          onSuccess: (payment) {
            // Track successful terminal payments matching the record hook
            _analyticsService.logEvent('booking_payment_success_$bookingId');
          },
        );
      } else {
        // Standard context route stack fallback execution if running outside main tabs container
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => PaymentCheckoutScreen(
              transactionId: bookingId,
              amount: widget.room.pricePerNight,
              purpose: "booking",
              referenceType: "booking",
              onSuccess: (payment) {
                _analyticsService.logEvent('booking_payment_success_$bookingId');
                Navigator.pop(context); // close payment view overlay
                MainTabsScreen.of(context)?.setSelectedIndex(14);
              },
            ),
          ),
        );
      }
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
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isDesktop = screenWidth >= 900;

    Widget checkoutFormContent = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppCard(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            children: [
              ListTile(
                title: const Text('Check In', style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(
                  checkIn != null ? formatDate(checkIn!) : 'Select date',
                  style: TextStyle(color: checkIn != null ? Colors.black : Colors.grey),
                ),
                trailing: Icon(Icons.calendar_month, color: Theme.of(context).colorScheme.primary),
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
              const Divider(),
              ListTile(
                title: const Text('Check Out', style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(
                  checkOut != null ? formatDate(checkOut!) : 'Select date',
                  style: TextStyle(color: checkOut != null ? Colors.black : Colors.grey),
                ),
                trailing: Icon(Icons.calendar_month, color: Theme.of(context).colorScheme.primary),
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
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: loading ? null : submitBooking,
            child: loading
                ? CircularProgressIndicator(color: Theme.of(context).colorScheme.surface)
                : const Text("Proceed To Payment", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ),
        ),
      ],
    );

    return Material(
      color: const Color(0xFFF5F7FA),
      child: CustomScrollView(
        slivers: [
          const SliverToBoxAdapter(
            child: SizedBox(height: AppSpacing.lg),
          ),
          
          SliverToBoxAdapter(
            child: Center(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 1200),
                padding: const EdgeInsets.all(AppSpacing.md),
                child: isDesktop
                    ? Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 5,
                            child: AppCard(
                              padding: const EdgeInsets.all(AppSpacing.lg),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("Booking Summary", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary)),
                                  const SizedBox(height: AppSpacing.sm),
                                  Text(widget.room.title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                                  Text("Room Type: ${widget.room.roomType.toUpperCase()}", style: TextStyle(color: Colors.grey.shade600)),
                                  const SizedBox(height: AppSpacing.md),
                                  Text("Price Per Night: MWK ${widget.room.pricePerNight}", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.green)),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.xl),
                          Expanded(flex: 6, child: checkoutFormContent),
                        ],
                      )
                    : Column(
                        children: [
                          AppCard(
                            padding: const EdgeInsets.all(AppSpacing.md),
                            child: ListTile(
                              leading: Icon(Icons.hotel, color: Theme.of(context).colorScheme.primary),
                              title: Text(widget.room.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                              subtitle: Text("MWK ${widget.room.pricePerNight} / Night", style: const TextStyle(color: Colors.green, fontWeight: FontWeight.w600)),
                            ),
                          ),
                          const SizedBox(height: AppSpacing.md),
                          checkoutFormContent,
                        ],
                      ),
              ),
            ),
          ),
          
          const SliverToBoxAdapter(child: SizedBox(height: 120)),
          
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