// lib/providers/events/events_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/api/api_client.dart';
import '../../models/event_model.dart';

final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient();
});

final eventsProvider =
    FutureProvider<List<EventModel>>((ref) async {

  final api = ref.read(apiClientProvider);

  return api.getList(
    'events/',
    fromJson: (json) => EventModel.fromJson(json),
  );
});


final myEventsProvider =
    FutureProvider<List<EventModel>>((ref) async {

  final api = ref.read(apiClientProvider);

  return api.getList(
    'events/?mine=true',
    fromJson: (json) => EventModel.fromJson(json),
  );
});