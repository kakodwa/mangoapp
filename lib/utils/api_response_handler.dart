import 'package:flutter/material.dart';
import 'app_toast.dart';

class ApiResponseHandler {
  static bool handle(
    BuildContext context,
    Map<String, dynamic> response, {
    Function()? onSuccess,
    Function()? onError,
  }) {
    final success = response['success'] == true;
    final message = response['message'] ?? 'Unknown response';

    if (success) {
      AppToast.success(context, message);

      if (onSuccess != null) {
        onSuccess();
      }
    } else {
      AppToast.error(context, message);

      if (onError != null) {
        onError();
      }
    }

    return success;
  }
}