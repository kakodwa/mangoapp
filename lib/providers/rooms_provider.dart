import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/room_model.dart';
import 'api_provider.dart';

final roomsProvider =
    FutureProvider.family<List<Room>, int>((ref, lodgeId) async {
  final api = ref.watch(apiClientProvider);

  return api.getList(
    'rooms/?lodge=$lodgeId',
    fromJson: (json) => Room.fromJson(json),
  );
});