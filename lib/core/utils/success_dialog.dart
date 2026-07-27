import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import '../constants/app_color.dart';
import 'app_text.dart';
import 'app_button.dart';
import 'ts.dart';
import 'size.dart';

class SuccessDialogController extends GetxController with GetSingleTickerProviderStateMixin {
  late final AnimationController lottieController;

  @override
  void onInit() {
    super.onInit();
    lottieController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );
  }

  @override
  void onClose() {
    lottieController.dispose();
    super.onClose();
  }
}

class SuccessDialog {
  static void show({
    required String title,
    required String message,
    required String buttonText,
    required VoidCallback onPressed,
    bool barrierDismissible = false,
  }) {
    // Create and initialize the controller
    final controller = Get.put(SuccessDialogController());
    
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
              // Lottie Animation
              Container(
                height: Get.height * 0.3,
                width: Get.width * 0.3,
                // decoration: BoxDecoration(
                //   shape: BoxShape.circle,
                //   color: AppColor.secondary.withValues(alpha: 0.1),
                // ),
                child: Lottie.asset(
                  'assets/animations/success.json',
                  width: Get.width * 0.3,
                  height: Get.height * 0.3,
                  fit: BoxFit.contain,
                  repeat: false,
                  animate: true,
                  controller: controller.lottieController,
                  onLoaded: (composition) {
                    controller.lottieController.duration = composition.duration;
                    controller.lottieController.forward();
                  },
                ),
              ),
              const Hbox(20),
              
              // Title
              AppText(
                title,
                style: Ts.bold20(color: AppColor.secondary),
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
                  Get.delete<SuccessDialogController>();
                  if (Get.isDialogOpen ?? false) {
                    Get.back();
                  }
                  onPressed();
                },
                bgColor: AppColor.secondary,
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

  // Specific success dialog for verification completion
  static void showVerificationSuccess({ String? title, String? message, VoidCallback? onContinue}) {
    show(
      title: title ?? 'Documents Submitted! 📄',
      message: message ?? 'Your docs are submitted. You will be able to add car details once your docs is approved by admin',
      buttonText: 'Continue',
      onPressed: onContinue ?? () {
        Get.back();
      },
    );
  }

  // Generic success dialog
  static void showGenericSuccess({
    required String title,
    required String message,
    String buttonText = 'Continue',
    VoidCallback? onPressed,
  }) {
    show(
      title: title,
      message: message,
      buttonText: buttonText,
      onPressed: onPressed ?? () {
        Get.back();
      },
    );
  }
}
