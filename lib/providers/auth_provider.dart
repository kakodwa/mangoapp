import 'dart:async'; // ⚡ Required for Completer
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
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
  
  // ⚡ Blocks actions until initialization finishes completely to prevent racing
  final Completer<void> _initCompleter = Completer<void>();

  AuthNotifier(this._apiClient) : super(AuthState()) {
    _checkAuthStatus();
  }

  // ============================
  // ✅ ERROR FORMATTER
  // ============================
  String formatDioError(dynamic error) {

  if (error is DioException) {

    debugPrint("========== API ERROR ==========");
    debugPrint("STATUS: ${error.response?.statusCode}");
    debugPrint("DATA:");
    debugPrint(error.response?.data.toString());
    debugPrint("===============================");

    final data = error.response?.data;

    if (data is Map<String, dynamic>) {

      // Convert Django validation errors into readable text
      return data.entries.map((entry) {
        final value = entry.value;

        if (value is List) {
          return "${entry.key}: ${value.join(', ')}";
        }

        return "${entry.key}: $value";

      }).join("\n");
    }


    if (error.response?.statusCode == 401) {
      return "Incorrect username or password";
    }

    if (error.response?.statusCode == 500) {
      return "Server error. Try again later";
    }
  }


  if (error.toString().contains('SocketException')) {
    return "No internet connection";
  }


  return "Something went wrong. Try again";
}

  Future<void> _checkAuthStatus() async {
    try {
      final token = await _secureStorage.read(key: 'access_token');

      if (token != null) {
        final userData = await _apiClient.get(
          'users/me/',
          fromJson: (json) => json,
        );

        state = state.copyWith(
          isAuthenticated: true,
          user: User.fromJson(userData),
        );
      }
    } catch (_) {
      await _clearTokens();
    } finally {
      // Signaling that initial state check is finished
      if (!_initCompleter.isCompleted) {
        _initCompleter.complete();
      }
    }
  }

  Future<void> _clearTokens() async {
    await _secureStorage.delete(key: 'access_token');
    await _secureStorage.delete(key: 'refresh_token');
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
    await _initCompleter.future;
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
      await _clearTokens();
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
    await _initCompleter.future;
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
      await _clearTokens();
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
    await _initCompleter.future;
    state = state.copyWith(isLoading: true);

    try {
      await _apiClient.logout();
      await _clearTokens();
      state = AuthState();
    } catch (e) {
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
    await _initCompleter.future;
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
      state = state.copyWith(
        isLoading: false,
        error: formatDioError(e),
      );
    }
  }
}