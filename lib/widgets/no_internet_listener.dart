import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

final GlobalKey<ScaffoldMessengerState>
    scaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();

class NoInternetListener extends StatefulWidget {
  final Widget child;

  const NoInternetListener({
    super.key,
    required this.child,
  });

  @override
  State<NoInternetListener> createState() =>
      _NoInternetListenerState();
}

class _NoInternetListenerState
    extends State<NoInternetListener> {

  late StreamSubscription<List<ConnectivityResult>>
      subscription;

  bool isOffline = false;

  @override
  void initState() {
    super.initState();

    checkInitialConnection();

    subscription = Connectivity()
        .onConnectivityChanged
        .listen((results) {

      final connected =
          results.isNotEmpty &&
          !results.contains(ConnectivityResult.none);

      if (!connected) {

        if (!isOffline) {

          isOffline = true;

          scaffoldMessengerKey.currentState
              ?.showSnackBar(
            const SnackBar(
              content: Text(
                'No Internet Connection',
              ),
              duration: Duration(days: 1),
            ),
          );
        }

      } else {

        if (isOffline) {

          isOffline = false;

          scaffoldMessengerKey.currentState
              ?.hideCurrentSnackBar();

          scaffoldMessengerKey.currentState
              ?.showSnackBar(
            const SnackBar(
              content: Text(
                'Internet Connected',
              ),
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    });
  }

  Future<void> checkInitialConnection() async {

    final results =
        await Connectivity().checkConnectivity();

    final connected =
        results.isNotEmpty &&
        !results.contains(ConnectivityResult.none);

    if (!connected) {

      isOffline = true;

      scaffoldMessengerKey.currentState
          ?.showSnackBar(
        const SnackBar(
          content: Text(
            'No Internet Connection',
          ),
          duration: Duration(days: 1),
        ),
      );
    }
  }

  @override
  void dispose() {
    subscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}