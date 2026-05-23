import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/requests/booking_create_request.dart';
import '../models/booking_model.dart';
import 'api_provider.dart';

final bookingsProvider =
    FutureProvider.autoDispose<List<Booking>>((ref) async {
  final api = ref.watch(apiClientProvider);

  return api.getList(
    'bookings/',
    fromJson: (json) => Booking.fromJson(json),
  );
});


final createBookingProvider =
    FutureProvider.family.autoDispose<Map<String, dynamic>, BookingParams>(
  (ref, params) async {
    final api = ref.watch(apiClientProvider);

    final response = await api.post(
      'bookings/',
      data: {
        "room": params.roomId,
        "check_in_date": params.checkInDate,
        "check_out_date": params.checkOutDate,
      },
      fromJson: (json) => json,
    );

    return response;
  },
);