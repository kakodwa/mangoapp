import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/api/api_client.dart';
import '../models/payment_model.dart';
import 'api_provider.dart';

final myPaymentsProvider =
    FutureProvider<List<PaymentModel>>((ref) async {

  final api = ref.read(apiClientProvider);

  return api.getMyPayments();
});