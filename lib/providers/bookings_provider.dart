import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/booking_model.dart';
import 'api_provider.dart';

final bookingsProvider =
    FutureProvider.autoDispose<List<Booking>>((ref) async {
  final api = ref.watch(apiClientProvider);

  return api.getList(
    'hospitality/bookings/',
    fromJson: (json) => Booking.fromJson(json),
  );
});