import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../constants/app_color.dart';
import 'ts.dart';

class Toast {
  static void show({
    required String message,
    Color? backgroundColor,
    Color? textColor,
    Duration duration = const Duration(milliseconds: 500),
    SnackPosition position = SnackPosition.BOTTOM,
  }) {
    Get.snackbar(
      '',
      message,
      snackPosition: position,
      backgroundColor: backgroundColor ?? AppColor.secondary,
      colorText: textColor ?? Colors.white,
      duration: duration,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      borderRadius: 8,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      messageText: Text(
        message,
        style: Ts.regular14(color: textColor ?? Colors.white),
        textAlign: TextAlign.center,
      ),
      titleText: const SizedBox.shrink(),
      isDismissible: true,
      dismissDirection: DismissDirection.horizontal,
      forwardAnimationCurve: Curves.easeOutBack,
      reverseAnimationCurve: Curves.easeInBack,
    );
  }

  static void showSuccess(String message) {
    show(
      message: message,
      backgroundColor: AppColor.success,
      textColor: Colors.white,
      duration: const Duration(milliseconds: 500),
    );
  }

  static void showError(String message) {
    show(
      message: message,
      backgroundColor: AppColor.error,
      textColor: Colors.white,
      duration: const Duration(milliseconds: 500),
    );
  }

  static void showInfo(String message) {
    show(
      message: message,
      backgroundColor: AppColor.secondary,
      textColor: Colors.white,
      duration: const Duration(milliseconds: 750),
    );
  }

  static void showLoading(String message) {
    show(
      message: message,
      backgroundColor: AppColor.secondary,
      textColor: Colors.white,
      duration: const Duration(milliseconds: 2500),
    );
  }
}

