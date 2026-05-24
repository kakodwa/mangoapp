import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/owner_booking.dart';
import 'api_provider.dart';

final ownerBookingsProvider = FutureProvider<List<OwnerBooking>>((ref) async {
  final api = ref.read(apiClientProvider);

  final result = await api.getList(
    "bookings/owner/",
    fromJson: (json) => OwnerBooking.fromJson(json),
  );

  print("OWNER BOOKINGS: $result");

  return result;
});