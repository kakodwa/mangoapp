import 'dart:io';
import 'package:permission_handler/permission_handler.dart';

Future<bool> requestStoragePermission() async {

  if (Platform.isAndroid) {

    await Permission.photos.request();
    await Permission.videos.request();
    await Permission.audio.request();
  }

  final storage = await Permission.storage.request();
  final manage = await Permission.manageExternalStorage.request();

  return storage.isGranted || manage.isGranted;
}