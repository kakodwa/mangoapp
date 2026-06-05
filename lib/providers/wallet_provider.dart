import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'api_provider.dart';
import '../core/api/api_client.dart'; // ✅ Pointing to the exact location of your class file
import '../models/wallet.dart';
import '../models/withdrawal_model.dart';

final walletProvider = FutureProvider<Wallet>((ref) async {
  final api = ref.watch(apiClientProvider);

  final response = await api.get(
    'wallet/balance/',
    fromJson: (json) => json,
  );
  return Wallet.fromJson(response);
});


final walletTransactionsProvider = FutureProvider<List<WalletTransaction>>((ref) async {
  final api = ref.watch(apiClientProvider);

  final response = await api.getList(
    'wallet/transactions/',
    fromJson: (json) => WalletTransaction.fromJson(json),
  );

  return response;
});


// State tracker for form execution status
class WithdrawalState {
  final bool isLoading;
  final String? errorMessage;
  final bool isSuccess;

  WithdrawalState({this.isLoading = false, this.errorMessage, this.isSuccess = false});
}

class WithdrawalNotifier extends StateNotifier<WithdrawalState> {
  final ApiClient _apiClient;
  
  WithdrawalNotifier(this._apiClient) : super(WithdrawalState());

  Future<bool> requestWithdrawal({
    required double amount,
    required String payoutMethod,     // ✅ Added parameter
    required String holderName,
    required String accountNumber,
    String? bankName,                // ✅ Added parameter
    String? bankUuid,                // ✅ Added parameter
    String? branch,                  // ✅ Added parameter
  }) async {
    state = WithdrawalState(isLoading: true);
    try {
      // Pass the matching names down to your ApiClient method
      await _apiClient.submitWithdrawalRequest(
        amount: amount,
        payoutMethod: payoutMethod,
        accountHolderName: holderName,
        accountNumber: accountNumber, // ✅ Corrected parameter name from bankAccountNumber
        bankName: bankName,
        bankUuid: bankUuid,
        bankBranch: branch,
      );
      state = WithdrawalState(isSuccess: true);
      return true;
    } catch (e) {
      state = WithdrawalState(errorMessage: e.toString());
      return false;
    }
  }
}

// Global Provider tracking submission state
final withdrawalProvider = StateNotifierProvider<WithdrawalNotifier, WithdrawalState>((ref) {
  final api = ref.watch(apiClientProvider); // ✅ Safely extract instance from dependency injection context
  return WithdrawalNotifier(api);
});

// Append this provider into your lib/providers/wallet_provider.dart

final historicalWithdrawalsProvider = FutureProvider<List<WithdrawalModel>>((ref) async {
  final api = ref.watch(apiClientProvider);

  // Hits: GET /api/wallet/withdrawals/
  final response = await api.getList(
    'wallet/withdrawals/',
    fromJson: (json) => WithdrawalModel.fromJson(json),
  );

  return response;
});