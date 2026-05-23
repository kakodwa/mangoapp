import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/api/api_client.dart';
import '../models/amenity_model.dart';
import 'api_provider.dart';

final amenitiesProvider = FutureProvider<List<Amenity>>((ref) async {
  final api = ref.read(apiClientProvider);

  final res = await api.get(
    "amenities/",
    fromJson: (json) => json,
  );

  final List rawList = res is List
      ? res
      : res['results'] ?? [];

  return rawList
      .map((e) => Amenity.fromJson(e))
      .toList();
});