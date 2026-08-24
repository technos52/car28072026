import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../constants/app_color.dart';
import 'app_text.dart';
import 'app_button.dart';
import 'ts.dart';
import 'size.dart';

class ErrorDialog {
  static void show({
    String title = 'Error',
    required String message,
    String buttonText = 'OK',
    VoidCallback? onPressed,
    bool barrierDismissible = true,
  }) {
    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: Container(
          width: Get.width * 0.85,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 20,
                offset: const Offset(0, 8),
                spreadRadius: 0,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Error Icon
              Container(
                height: 80,
                width: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.red.withValues(alpha: 0.1),
                ),
                child: const Center(
                  child: Icon(
                    Icons.error_outline_rounded,
                    color: Colors.red,
                    size: 48,
                  ),
                ),
              ),
              const Hbox(20),
              
              // Title
              AppText(
                title,
                style: Ts.bold20(color: Colors.red),
                textAlign: TextAlign.center,
              ),
              const Hbox(8),
              
              // Message
              AppText(
                message,
                style: Ts.regular14(color: AppColor.gray600),
                textAlign: TextAlign.center,
              ),
              const Hbox(24),
              
              // Action Button
              AppButton(
                text: buttonText,
                onPressed: () {
                  if (Get.isDialogOpen ?? false) {
                    Get.back();
                  }
                  if (onPressed != null) {
                    onPressed();
                  }
                },
                bgColor: Colors.red,
                elevation: 0,
                useGradient: false,
                isFullWidth: true,
                borderRadius: 16,
                height: 52,
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: barrierDismissible,
      barrierColor: Colors.black.withValues(alpha: 0.5),
    );
  }
}
