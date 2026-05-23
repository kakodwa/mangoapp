import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/services.dart';
import '../../core/api/api_client.dart';

class AppUpdateService {
  final ApiClient api;

  AppUpdateService(this.api);

 Future<bool> checkVersion(BuildContext context) async {
  final local = await PackageInfo.fromPlatform();
  final data = await api.getAppVersion();

  final remoteVersion = data['latest_version'];
  final force = data['force_update'] ?? false;
  final maintenance = data['maintenance_mode'] ?? false;
  final message = data['message'];
  final url = data['update_url'];

  // 🔥 MAINTENANCE MODE (HIGHEST PRIORITY)
  if (maintenance == true) {
    _showMaintenanceDialog(context, message ?? "App under maintenance");
    return false;
  }

  // VERSION NULL SAFE
  if (remoteVersion == null) return true;

  // VERSION CHECK
  if (_isNewerVersion(local.version, remoteVersion)) {
    _showUpdateDialog(context, force, url);
    return !force;
  }

  return true;
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
    builder: (_) => WillPopScope(
      onWillPop: () async => false,
      child: AlertDialog(
        title: const Text("Maintenance Mode"),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              SystemNavigator.pop();
              },
            child: const Text("Exit"),
          ),
        ],
      ),
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