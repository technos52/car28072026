import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Toast {
  static void showSuccess(String message) {
    _showSnackBar('Success', message, Colors.green);
  }

  static void showError(String message) {
    _showSnackBar('Error', message, Colors.red);
  }

  static void showInfo(String message) {
    _showSnackBar('Info', message, const Color(0xFF6366F1));
  }

  static void _showSnackBar(String title, String message, Color bgColor) {
    // Check if we have an overlay context to prevent "No Overlay" error
    if (Get.overlayContext == null) {
      print('TOAST: [$title] $message');
      return;
    }

    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: bgColor,
      colorText: Colors.white,
      duration: const Duration(seconds: 4),
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
    );
  }
}
