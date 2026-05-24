import 'package:flutter/material.dart';
import '../../models/owner_booking.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/api_provider.dart';

class OwnerBookingCard extends ConsumerWidget {
  final OwnerBooking booking;

  const OwnerBookingCard({
    super.key,
    required this.booking,
  });

  Color get statusColor {
    switch (booking.bookingStatus) {
      case "confirmed":
        return Colors.green;
      case "pending":
        return Colors.orange;
      case "checked_in":
        return Colors.blue;
      case "checked_out":
        return Colors.grey;
      default:
        return Colors.black45;
    }
  }

Future<void> _action(
  WidgetRef ref,
  String endpoint,
) async {
  try {
    final api = ref.read(apiClientProvider);

    final response = await api.post(
      "bookings/${booking.id}/$endpoint/",
      data: {},
      fromJson: (json) => json,
    );

    debugPrint("✅ $endpoint success: $response");

    ScaffoldMessenger.of(ref.context).showSnackBar(
      SnackBar(content: Text("$endpoint successful")),
    );
  } catch (e) {
    debugPrint("❌ $endpoint failed: $e");

    ScaffoldMessenger.of(ref.context).showSnackBar(
      SnackBar(content: Text("$endpoint failed")),
    );
  }
}

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // TOP
          Row(
            children: [
              CircleAvatar(
                backgroundColor: statusColor.withOpacity(0.2),
                child: Icon(Icons.hotel, color: statusColor),
              ),
              const SizedBox(width: 10),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      booking.customerName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      "Room ${booking.roomNumber} • ${booking.roomName}",
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  booking.bookingStatus.toUpperCase(),
                  style: TextStyle(color: statusColor),
                ),
              )
            ],
          ),

          const SizedBox(height: 12),

          Text("Ref: ${booking.bookingReference}"),
          Text("Nights: ${booking.totalNights}"),
          Text("Total: MWK ${booking.totalAmount}"),

          const SizedBox(height: 10),

          // ACTIONS
          Row(
  children: [
    if (booking.bookingStatus == "confirmed")
      ElevatedButton(
        onPressed: () => _action(ref, "check_in"),
        child: const Text("Check In"),
      ),

    const SizedBox(width: 10),

    if (booking.bookingStatus == "checked_in")
      ElevatedButton(
        onPressed: () => _action(ref, "check_out"),
        child: const Text("Check Out"),
      ),
  ],
)
        ],
      ),
    );
  }
}