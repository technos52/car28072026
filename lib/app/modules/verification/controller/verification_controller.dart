import 'package:flutter/material.dart';
import 'package:get/get.dart';

class VerificationController extends GetxController with GetSingleTickerProviderStateMixin {
  late final AnimationController lottieController;
  // .lottie bundle URL (zip) per user
  final String lottiesfromassets = 'assets/animations/verifications.lottie';
  final String lottieBundleUrl = 'https://lottie.host/6b02faba-ae7a-4e1b-b45c-d7cc7667db56/jVCVXdFyd9.json';
  // JSON animation for direct Lottie usage
  final String lottieAssetJson = 'assets/animations/verifications.json';

  @override
  void onInit() {
    super.onInit();
    lottieController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3), // Default duration
    );
  }

  @override
  void onClose() {
    lottieController.dispose();
    super.onClose();
  }
}


