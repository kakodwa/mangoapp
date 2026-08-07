import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/api/api_client.dart';
import '../models/ticket_model.dart';

// Package imports avoid any relative folder path mismatches:
import 'package:mangochi_marketplace/providers/api_provider.dart';
import 'package:mangochi_marketplace/providers/auth_provider.dart' hide apiClientProvider;

final myTicketsProvider = FutureProvider<List<TicketModel>>((ref) async {
  final authState = ref.watch(authProvider);

  // Guard Clause: Do not execute API request if user is not authenticated
  if (!authState.isAuthenticated) {
    return [];
  }

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