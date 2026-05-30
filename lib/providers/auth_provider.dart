import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../core/api/api_client.dart';
import '../models/user_model.dart';

final apiClientProvider = Provider((ref) => ApiClient());

final authProvider =
    StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref.watch(apiClientProvider));
});

class AuthState {
  final bool isLoading;
  final bool isAuthenticated;
  final User? user;
  final String? error;

  AuthState({
    this.isLoading = false,
    this.isAuthenticated = false,
    this.user,
    this.error,
  });

  AuthState copyWith({
    bool? isLoading,
    bool? isAuthenticated,
    User? user,
    String? error,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      user: user ?? this.user,
      error: error,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final ApiClient _apiClient;
  final _secureStorage = const FlutterSecureStorage();

  AuthNotifier(this._apiClient) : super(AuthState()) {
    _checkAuthStatus();
  }

  // ============================
  // ✅ ERROR FORMATTER
  // ============================
  String formatDioError(dynamic error) {
    final msg = error.toString();

    if (msg.contains('401')) {
      return 'Incorrect username or password';
    }

    if (msg.contains('400')) {
      return 'Invalid request. Check your input';
    }

    if (msg.contains('500')) {
      return 'Server error. Try again later';
    }

    if (msg.contains('SocketException') || msg.contains('network')) {
      return 'No internet connection';
    }

    return 'Something went wrong. Try again';
  }

  Future<void> _checkAuthStatus() async {
    final token = await _secureStorage.read(key: 'access_token');

    if (token != null) {
      try {
        final userData = await _apiClient.get(
          'users/me/',
          fromJson: (json) => json,
        );

        state = state.copyWith(
          isAuthenticated: true,
          user: User.fromJson(userData),
        );
      } catch (_) {
        await _secureStorage.delete(key: 'access_token');
        await _secureStorage.delete(key: 'refresh_token');
      }
    }
  }

  // ============================
  // ✅ REGISTER
  // ============================
  Future<void> register({
    required String username,
    required String phoneNumber,
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String userType,
    String? district,
    String? gender,
    String? dateOfBirth,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final response = await _apiClient.register(
        username: username,
        email: email,
        password: password,
        firstName: firstName,
        lastName: lastName,
        userType: userType,
        phoneNumber: phoneNumber,
        district: district,
        gender: gender,
        dateOfBirth: dateOfBirth,
      );

      await _apiClient.saveTokens(
        response['access'],
        response['refresh'],
      );

      state = state.copyWith(
        isLoading: false,
        isAuthenticated: true,
        user: User.fromJson(response['user']),
      );
    } catch (e) {
      // 🔥 CHANGED HERE
      state = state.copyWith(
        isLoading: false,
        error: formatDioError(e),
      );
    }
  }

  // ============================
  // ✅ LOGIN
  // ============================
  Future<void> login({
    required String username,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final response = await _apiClient.login(
        username: username,
        password: password,
      );

      await _apiClient.saveTokens(
        response['access'],
        response['refresh'],
      );

      final userData = await _apiClient.get(
        'users/me/',
        fromJson: (json) => json,
      );

      state = state.copyWith(
        isLoading: false,
        isAuthenticated: true,
        user: User.fromJson(userData),
      );
    } catch (e) {
      // 🔥 CHANGED HERE
      state = state.copyWith(
        isLoading: false,
        error: formatDioError(e),
      );
    }
  }

  // ============================
  // ✅ LOGOUT
  // ============================
  Future<void> logout() async {
    state = state.copyWith(isLoading: true);

    try {
      await _apiClient.logout();
      state = AuthState();
    } catch (e) {
      // 🔥 CHANGED HERE
      state = state.copyWith(
        isLoading: false,
        error: formatDioError(e),
      );
    }
  }

  // ============================
  // ✅ UPDATE PROFILE
  // ============================
  Future<void> updateProfile(Map<String, dynamic> data) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final response = await _apiClient.put(
        'users/update_profile/',
        data: data,
        fromJson: (json) => json,
      );

      state = state.copyWith(
        isLoading: false,
        user: User.fromJson(response),
      );
    } catch (e) {
      // 🔥 CHANGED HERE
      state = state.copyWith(
        isLoading: false,
        error: formatDioError(e),
      );
    }
  }
}