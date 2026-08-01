// lib/providers/payment_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/api/api_client.dart';
import '../models/payment_model.dart';
import 'api_provider.dart';

final myPaymentsProvider =
    FutureProvider.autoDispose<List<PaymentModel>>((ref) async {
  final api = ref.read(apiClientProvider);

  // Passing a timestamp forces Dio/http client & Django backend to bypass any HTTP caching
  final timestamp = DateTime.now().millisecondsSinceEpoch;
  return api.getMyPayments(); 
});