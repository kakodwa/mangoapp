// lib/core/services/connectivity_service.dart

import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityService {

  final Connectivity _connectivity =
      Connectivity();

  Stream<bool> get connectionStream async* {

    await for (final result
        in _connectivity.onConnectivityChanged) {

      final hasConnection =
          result != ConnectivityResult.none;

      yield hasConnection;
    }
  }

  Future<bool> checkConnection() async {

    final result =
        await _connectivity.checkConnectivity();

    return result != ConnectivityResult.none;
  }
}