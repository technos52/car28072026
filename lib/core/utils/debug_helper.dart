import 'package:flutter/foundation.dart';

class DebugHelper {
  static void log(String message, {String? tag}) {
    if (kDebugMode) {
      final timestamp = DateTime.now().toIso8601String();
      final tagPrefix = tag != null ? '[$tag] ' : '';
      print('$timestamp $tagPrefix$message');
    }
  }

  static void logError(
    String message, {
    Object? error,
    StackTrace? stackTrace,
  }) {
    if (kDebugMode) {
      final timestamp = DateTime.now().toIso8601String();
      print('$timestamp [ERROR] $message');
      if (error != null) {
        print('$timestamp [ERROR] Error: $error');
      }
      if (stackTrace != null) {
        print('$timestamp [ERROR] Stack trace: $stackTrace');
      }
    }
  }

  static void logImageLoad(String imageUrl, {bool success = true}) {
    if (kDebugMode) {
      final status = success ? 'SUCCESS' : 'FAILED';
      log('Image load $status: $imageUrl', tag: 'IMAGE');
    }
  }

  static void logControllerRegistration(
    String controllerName, {
    bool isRegistered = false,
  }) {
    if (kDebugMode) {
      final status = isRegistered ? 'ALREADY REGISTERED' : 'REGISTERING';
      log('Controller $status: $controllerName', tag: 'CONTROLLER');
    }
  }
}
