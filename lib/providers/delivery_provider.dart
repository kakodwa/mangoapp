// lib/providers/delivery_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mangochi_marketplace/providers/api_provider.dart';
import 'package:mangochi_marketplace/providers/auth_provider.dart' hide apiClientProvider;

final deliveriesProvider = FutureProvider.autoDispose((ref) async {
  final authState = ref.watch(authProvider);

  // Guard Clause: Prevent API call if unauthenticated
  if (!authState.isAuthenticated) {
    return [];
  }

  final api = ref.watch(apiClientProvider);

  return api.getList(
    'deliveries/',
    fromJson: (json) => json,
  );
});