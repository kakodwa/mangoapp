// lib/providers/events/tickets_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/api/api_client.dart';
import '../../models/ticket_model.dart';
import 'events_provider.dart';

final myTicketsProvider =
    FutureProvider<List<TicketModel>>((ref) async {

  final api = ref.read(apiClientProvider);

  return api.getList(
    'tickets/',
    fromJson: (json) => TicketModel.fromJson(json),
  );
});


final eventTicketsProvider =
    FutureProvider.family<List<TicketModel>, int>((ref, eventId) async {

  final api = ref.read(apiClientProvider);

  return api.getList(
    'tickets/?event=$eventId',
    fromJson: (json) => TicketModel.fromJson(json),
  );
});