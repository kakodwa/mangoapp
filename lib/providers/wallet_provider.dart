// lib/providers/wallet_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'api_provider.dart';
import 'auth_provider.dart' hide apiClientProvider;

import '../core/api/api_client.dart';
import '../models/wallet.dart';
import '../models/withdrawal_model.dart';

// ==========================================
// 1. WALLET BALANCE PROVIDER
// ==========================================
final walletProvider = FutureProvider.autoDispose<Wallet>((ref) async {
  final authState = ref.watch(authProvider);

  if (authState.isLoading) {
    return Wallet(
      balance: 0.0,
      currency: 'MWK',
      totalEarnings: 0.0,
      totalWithdrawn: 0.0,
    );
  }

  if (!authState.isAuthenticated) {
    throw Exception("Authentication required. Please log in.");
  }

  final api = ref.watch(apiClientProvider);
  final response = await api.get(
    'wallet/balance/',
    fromJson: (json) => json,
  );
  return Wallet.fromJson(response);
});

// ==========================================
// 2. WALLET TRANSACTIONS STATE & NOTIFIER
// ==========================================
class WalletTransactionsState {
  final List<WalletTransaction> transactions;
  final bool isLoading;
  final bool isMoreLoading;
  final bool hasMore;
  final String? errorMessage;
  final bool isUnauthenticated;

  const WalletTransactionsState({
    required this.transactions,
    this.isLoading = false,
    this.isMoreLoading = false,
    this.hasMore = true,
    this.errorMessage,
    this.isUnauthenticated = false,
  });

  WalletTransactionsState copyWith({
    List<WalletTransaction>? transactions,
    bool? isLoading,
    bool? isMoreLoading,
    bool? hasMore,
    String? errorMessage,
    bool? isUnauthenticated,
  }) {
    return WalletTransactionsState(
      transactions: transactions ?? this.transactions,
      isLoading: isLoading ?? this.isLoading,
      isMoreLoading: isMoreLoading ?? this.isMoreLoading,
      hasMore: hasMore ?? this.hasMore,
      errorMessage: errorMessage,
      isUnauthenticated: isUnauthenticated ?? this.isUnauthenticated,
    );
  }
}

class WalletTransactionsNotifier
    extends StateNotifier<WalletTransactionsState> {
  final Ref _ref;
  final _secureStorage = const FlutterSecureStorage();
  int _currentPage = 1;

  WalletTransactionsNotifier(this._ref)
      : super(const WalletTransactionsState(transactions: [], isLoading: true)) {
    _initAndFetch();
  }

  void _initAndFetch() {
    _ref.listen<AuthState>(authProvider, (previous, next) {
      if (!next.isLoading && next.isAuthenticated) {
        fetchFirstPage();
      }
    });

    final authState = _ref.read(authProvider);
    if (!authState.isLoading) {
      fetchFirstPage();
    }
  }

  Future<void> fetchFirstPage() async {
    _currentPage = 1;
    state = state.copyWith(
      isLoading: true,
      errorMessage: null,
      isUnauthenticated: false,
    );

    try {
      final token = await _secureStorage.read(key: 'access_token');
      final authState = _ref.read(authProvider);

      if (token == null && !authState.isAuthenticated) {
        state = state.copyWith(
          isLoading: false,
          isUnauthenticated: true,
          errorMessage: "You are not logged in. Please log in to view transactions.",
        );
        return;
      }

      final api = _ref.read(apiClientProvider);
      
      // Hits GET /api/wallet/transactions/?page=1
      final response = await api.getList<WalletTransaction>(
        'wallet/transactions/?page=$_currentPage',
        fromJson: (json) => WalletTransaction.fromJson(json),
      );

      state = state.copyWith(
        transactions: response,
        isLoading: false,
        hasMore: response.length >= 10,
        isUnauthenticated: false,
      );
    } catch (e) {
      final errStr = e.toString().toLowerCase();

      // Only flag authentication error if explicit HTTP 401 occurs
      final isAuthErr = errStr.contains("401") ||
          errStr.contains("invalid_token") ||
          errStr.contains("token_not_valid");

      state = state.copyWith(
        isLoading: false,
        errorMessage: isAuthErr
            ? "Authentication session expired. Please log in again."
            : "Could not load transactions: $e",
        isUnauthenticated: isAuthErr,
      );
    }
  }

  Future<void> fetchNextPage() async {
    if (state.isLoading || state.isMoreLoading || !state.hasMore) return;

    state = state.copyWith(isMoreLoading: true);
    _currentPage++;

    try {
      final api = _ref.read(apiClientProvider);
      final newTxs = await api.getList<WalletTransaction>(
        'wallet/transactions/?page=$_currentPage',
        fromJson: (json) => WalletTransaction.fromJson(json),
      );

      if (newTxs.isEmpty) {
        state = state.copyWith(isMoreLoading: false, hasMore: false);
      } else {
        state = state.copyWith(
          transactions: [...state.transactions, ...newTxs],
          isMoreLoading: false,
          hasMore: newTxs.length >= 10,
        );
      }
    } catch (_) {
      state = state.copyWith(isMoreLoading: false, hasMore: false);
    }
  }
}

final walletTransactionsProvider = StateNotifierProvider.autoDispose<
    WalletTransactionsNotifier, WalletTransactionsState>((ref) {
  return WalletTransactionsNotifier(ref);
});

// ==========================================
// 3. WITHDRAWAL NOTIFIER & PROVIDERS
// ==========================================
class WithdrawalState {
  final bool isLoading;
  final String? errorMessage;
  final bool isSuccess;

  WithdrawalState({
    this.isLoading = false,
    this.errorMessage,
    this.isSuccess = false,
  });
}

class WithdrawalNotifier extends StateNotifier<WithdrawalState> {
  final ApiClient _apiClient;

  WithdrawalNotifier(this._apiClient) : super(WithdrawalState());

  Future<bool> requestWithdrawal({
    required double amount,
    required String payoutMethod,
    required String holderName,
    required String accountNumber,
    String? bankName,
    String? bankUuid,
    String? branch,
  }) async {
    state = WithdrawalState(isLoading: true);
    try {
      await _apiClient.submitWithdrawalRequest(
        amount: amount,
        payoutMethod: payoutMethod,
        accountHolderName: holderName,
        accountNumber: accountNumber,
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

final withdrawalProvider =
    StateNotifierProvider<WithdrawalNotifier, WithdrawalState>((ref) {
  final api = ref.watch(apiClientProvider);
  return WithdrawalNotifier(api);
});

final historicalWithdrawalsProvider =
    FutureProvider.autoDispose<List<WithdrawalModel>>((ref) async {
  final api = ref.watch(apiClientProvider);

  final response = await api.getList(
    'wallet/withdrawals/',
    fromJson: (json) => WithdrawalModel.fromJson(json),
  );

  return response;
});