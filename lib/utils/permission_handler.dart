import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionUtils {
  static Future<bool> requestCameraPermission() async {
    try {
      final status = await Permission.camera.request();
      return status.isGranted;
    } on PlatformException catch (e) {
      debugPrint('Camera permission error: $e');
      return false;
    }
  }

  static Future<bool> requestStoragePermission() async {
    try {
      final status = await Permission.storage.request();
      return status.isGranted;
    } on PlatformException catch (e) {
      debugPrint('Storage permission error: $e');
      return false;
    }
  }

  static Future<bool> checkCameraPermission() async {
    try {
      final status = await Permission.camera.status;
      return status.isGranted;
    } on PlatformException catch (e) {
      debugPrint('Camera permission check error: $e');
      return false;
    }
  }

  static Future<bool> checkStoragePermission() async {
    try {
      final status = await Permission.storage.status;
      return status.isGranted;
    } on PlatformException catch (e) {
      debugPrint('Storage permission check error: $e');
      return false;
    }
  }

  static Future<void> openAppSettings() async {
    await openAppSettings();
  }

  static Future<bool> requestAllMediaPermissions() async {
    try {
      final cameraStatus = await Permission.camera.request();
      final storageStatus = await Permission.storage.request();
      return cameraStatus.isGranted && storageStatus.isGranted;
    } on PlatformException catch (e) {
      debugPrint('Media permissions error: $e');
      return false;
    }
  }
}