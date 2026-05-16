import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'api_provider.dart';
import '../models/wallet.dart';

final walletProvider = FutureProvider<Wallet>((ref) async {
  final api = ref.watch(apiClientProvider);

 final response = await api.get(
  'wallet/balance/',
  fromJson: (json) => json,
);
  return Wallet.fromJson(response);
});


final walletTransactionsProvider =
    FutureProvider<List<WalletTransaction>>((ref) async {
  final api = ref.watch(apiClientProvider);

  final response = await api.getList(
    'wallet/transactions/',
    fromJson: (json) => WalletTransaction.fromJson(json),
  );

  return response;
});

