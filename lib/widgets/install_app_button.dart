import 'dart:async';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

// Conditional import to support web JS calls cleanly
import 'dart:js' as js; 
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

class InstallAppButton extends StatefulWidget {
  const InstallAppButton({super.key});

  @override
  State<InstallAppButton> createState() => _InstallAppButtonState();
}

class _InstallAppButtonState extends State<InstallAppButton> {
  bool _canInstall = false;
  StreamSubscription? _installAvailableSub;
  StreamSubscription? _installedSub;

  @override
  void initState() {
    super.initState();
    if (kIsWeb) {
      // Listen to PWA lifecycle events from JS
      _installAvailableSub = html.window.on['pwaInstallAvailable'].listen((_) {
        if (mounted) setState(() => _canInstall = true);
      });

      _installedSub = html.window.on['pwaInstalled'].listen((_) {
        if (mounted) setState(() => _canInstall = false);
      });
    }
  }

  @override
  void dispose() {
    _installAvailableSub?.cancel();
    _installedSub?.cancel();
    super.dispose();
  }

  void _triggerInstall() {
    if (kIsWeb) {
      try {
        js.context.callMethod('installApp');
      } catch (e) {
        debugPrint('[PWA Error] Failed to trigger install: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Hide completely on native iOS/Android apps or when install prompt isn't ready
    if (!kIsWeb || !_canInstall) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      height: 36,
      child: OutlinedButton.icon(
        onPressed: _triggerInstall,
        icon: const Icon(
          Icons.download_rounded,
          size: 18,
        ),
        label: const Text('Install'),
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFFFF8C00),
          side: const BorderSide(
            color: Color(0xFFFF8C00),
            width: 1.2,
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 8,
          ),
          visualDensity: VisualDensity.compact,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }
}