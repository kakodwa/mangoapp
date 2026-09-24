import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/services.dart';
import '../../core/api/api_client.dart';

class AppUpdateService {
  final ApiClient api;

  AppUpdateService(this.api);

Future<bool> checkVersion(BuildContext context) async {
  try {
    debugPrint('🔥 CHECK VERSION: START');

    // Get installed app version
    final local = await PackageInfo.fromPlatform();

    debugPrint('🔥 LOCAL APP VERSION: ${local.version}');

    // Get version information from backend
    final data = await api.getAppVersion();

    debugPrint('🔥 VERSION DATA FROM SERVER: $data');

    // Read server values
    final remoteVersion = data['latest_version'];
    final serverForce = data['force_update'] ?? false;

    // Force update only on installed mobile apps
    final force = !kIsWeb && serverForce;
    final maintenance = data['maintenance_mode'] ?? false;
    final message = data['message'];
    final url = data['update_url'];

    debugPrint('🔥 REMOTE VERSION: $remoteVersion');
    debugPrint('🔥 FORCE UPDATE: $force');
    debugPrint('🔥 MAINTENANCE MODE: $maintenance');
    debugPrint('🔥 MESSAGE: $message');
    debugPrint('🔥 UPDATE URL: $url');

    // ============================================================
    // MAINTENANCE MODE
    // ============================================================

    if (maintenance == true) {
      debugPrint('🚨 MAINTENANCE MODE IS ON');

      if (context.mounted) {
        _showMaintenanceDialog(
          context,
          message?.toString() ?? "App under maintenance",
        );
      }

      return false;
    }

    // ============================================================
    // NO VERSION FROM SERVER
    // ============================================================

    if (remoteVersion == null ||
        remoteVersion.toString().trim().isEmpty) {
      debugPrint(
        '⚠️ NO REMOTE VERSION FOUND - ALLOWING APP TO CONTINUE',
      );

      return true;
    }

    // ============================================================
    // VERSION CHECK
    // ============================================================

    final localVersion = local.version;
    final serverVersion = remoteVersion.toString();

    debugPrint(
      '🔍 COMPARING LOCAL $localVersion WITH SERVER $serverVersion',
    );

    final updateAvailable = _isNewerVersion(
      localVersion,
      serverVersion,
    );

    debugPrint(
      '🔥 UPDATE AVAILABLE: $updateAvailable',
    );

    // ============================================================
    // UPDATE AVAILABLE
    // ============================================================

    if (updateAvailable) {
      debugPrint('🚨 NEW VERSION AVAILABLE');

      if (context.mounted) {
        _showUpdateDialog(
          context,
          force == true,
          url?.toString(),
        );
      }

      // Force update = STOP APP
      if (force == true) {
        debugPrint(
          '🚨 FORCE UPDATE ENABLED - BLOCKING APP',
        );

        return false;
      }

      // Optional update = allow app to continue
      debugPrint(
        '✅ OPTIONAL UPDATE - ALLOWING APP TO CONTINUE',
      );

      return true;
    }

    // ============================================================
    // APP IS UP TO DATE
    // ============================================================

    debugPrint(
      '✅ APP VERSION IS UP TO DATE',
    );

    return true;
  } catch (e, stackTrace) {
    debugPrint(
      '❌ CHECK VERSION ERROR: $e',
    );

    debugPrint(
      '❌ STACK TRACE: $stackTrace',
    );

    // IMPORTANT:
    // If version checking fails, don't permanently
    // trap the user on the splash screen.
    debugPrint(
      '⚠️ VERSION CHECK FAILED - ALLOWING APP TO CONTINUE',
    );

    return true;
  }
}

  bool _isNewerVersion(String local, String remote) {
    final l = local.split('.').map(int.parse).toList();
    final r = remote.split('.').map(int.parse).toList();

    for (int i = 0; i < r.length; i++) {
      final lv = i < l.length ? l[i] : 0;
      final rv = r[i];

      if (rv > lv) return true;
      if (rv < lv) return false;
    }
    return false;
  }


void _showMaintenanceDialog(BuildContext context, String message) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (_) => AlertDialog(
      title: const Text("Maintenance Mode"),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () {
            if (kIsWeb) {
              // Web cannot close itself
              Navigator.of(context).pop();
            } else {
              // Close the installed mobile app
              SystemNavigator.pop();
            }
          },
          child: const Text("Exit"),
        ),
      ],
    ),
  );
}

// ✅ FIXED METHOD NAME (THIS WAS YOUR ERROR)
void _showUpdateDialog(
    BuildContext context,
    bool force,
    String? url,
  ) {
    showDialog(
      context: context,
      barrierDismissible: !force,
      builder: (_) => WillPopScope(
        onWillPop: () async => !force,
        child: AlertDialog(
          title: const Text("Update Available"),
          content: Text(
            force
                ? "You must update to continue using this app."
                : "A new version is available.",
          ),
          actions: [
            if (!force)
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Later"),
              ),
            TextButton(
              onPressed: () async {
  if (url != null && url.isNotEmpty) {
    final uri = Uri.parse(url);

    if (await canLaunchUrl(uri)) {
      await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
    }
  }
},
              child: const Text("Update"),
            ),
          ],
        ),
      ),
    );
  }
}