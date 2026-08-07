// lib/providers/payment_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/api/api_client.dart';
import '../models/payment_model.dart';
import 'api_provider.dart';
import 'auth_provider.dart' hide apiClientProvider; // 👈 Prevents import collision

final myPaymentsProvider =
    FutureProvider.autoDispose<List<PaymentModel>>((ref) async {
  final authState = ref.watch(authProvider);

  // Guard clause: Prevent API call if unauthenticated
  if (!authState.isAuthenticated) {
    return [];
  }

  final api = ref.watch(apiClientProvider);

  return api.getMyPayments();
});