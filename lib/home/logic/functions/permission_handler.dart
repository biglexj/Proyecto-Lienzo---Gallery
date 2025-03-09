import 'dart:io';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'permission_request_dialog.dart';

class PermissionHandler {
  static Future<bool> checkAndRequestPermissions(BuildContext context) async {
    if (Platform.isAndroid || Platform.isIOS) {
      // En móviles, verificamos permisos específicos
      var statusStorage = await Permission.storage.status;
      var statusPhotos = await Permission.photos.status;
      var statusVideos = await Permission.videos.status;
      var statusAudio = await Permission.audio.status;

      if (statusStorage.isDenied || statusPhotos.isDenied || statusVideos.isDenied || statusAudio.isDenied) {
        await Permission.storage.request();
        await Permission.photos.request();
        await Permission.videos.request();
        await Permission.audio.request();

        // Verificar nuevamente los estados
        statusStorage = await Permission.storage.status;
        statusPhotos = await Permission.photos.status;
        statusVideos = await Permission.videos.status;
        statusAudio = await Permission.audio.status;
      }

      return statusStorage.isGranted && statusPhotos.isGranted && statusVideos.isGranted && statusAudio.isGranted;
    } else {
      // Para desktop, verificación simple de directorio
      try {
        final directory = Directory.current;
        await directory.list().first;
        return true;
      } catch (e) {
        return await showPermissionRequestDialog(context);
      }
    }
  }

  static Future<bool> verifyDirectoryAccess(String path) async {
    try {
      final directory = Directory(path);
      await directory.list().first;
      return true;
    } catch (e) {
      return false;
    }
  }
}
