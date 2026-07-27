import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import '../../../core/constants/app_color.dart';
import '../../../core/utils/ts.dart';
import '../../../core/utils/app_text.dart';
import '../../../core/utils/app_button.dart';
import '../../../core/utils/size.dart';
import 'controller/verification_controller.dart';
import '../../routes/app_routes.dart';
import '../../../core/services/signup_progress_service.dart';

class VerificationView extends GetView<VerificationController> {
  const VerificationView({super.key});

  void _showSkipWarningDialog() {
    final Map<String, dynamic>? args = Get.arguments as Map<String, dynamic>?;
    final bool isOnboarding = (args?['onboarding'] == true);
    
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
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.orange.withValues(alpha: 0.1),
                ),
                child: const Icon(
                  Icons.warning_amber_rounded,
                  color: Colors.orange,
                  size: 36,
                ),
              ),
              const Hbox(20),
              AppText(
                'Skip KYC Verification?',
                style: Ts.bold20(color: AppColor.secondary),
                textAlign: TextAlign.center,
              ),
              const Hbox(12),
              AppText(
                'Skipping KYC verification will limit your account features like adding car details. You can complete verification later from your profile.',
                style: Ts.regular14(color: AppColor.gray600),
                textAlign: TextAlign.center,
              ),
              const Hbox(24),
              Row(
                children: [
                  Expanded(
                    child: AppButton(
                      text: 'Cancel',
                      onPressed: () {
                        Get.back();
                      },
                      useGradient: false,
                      bgColor: AppColor.gray200,
                      textColor: AppColor.gray600,
                      isFullWidth: true,
                      borderRadius: 16,
                      height: 48,
                      elevation: 0,
                    ),
                  ),
                  const Wbox(12),
                  Expanded(
                    child: AppButton(
                      text: 'Skip',
                      onPressed: () {
                        Get.back();
                        if (isOnboarding) {
                          Get.offAllNamed(AppRoutes.root);
                        } else {
                          Get.back();
                        }
                      },
                      useGradient: false,
                      bgColor: Colors.orange,
                      textColor: Colors.white,
                      isFullWidth: true,
                      borderRadius: 16,
                      height: 48,
                      elevation: 0,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: true,
      barrierColor: Colors.black.withValues(alpha: 0.5),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        surfaceTintColor: Colors.transparent,
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: true,
        title: AppText('Document Verification', style: Ts.bold16(color: AppColor.secondary)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Hbox(8),
              SizedBox(
                height: Get.height * 0.35,
                child: Center(
                  child: Lottie.network(
                    controller.lottieBundleUrl,
                    width: Get.width * 0.7,
                    fit: BoxFit.contain,
                    repeat: true,
                    controller: controller.lottieController,
                    onLoaded: (composition) {
                      controller.lottieController.duration = composition.duration;
                      controller.lottieController.forward();
                    },
                  ),
                ),
              ),
              const Hbox(8),
              AppText('Document Verification', style: Ts.semiBold18(color: AppColor.secondary)),
              const Hbox(8),
              AppText(
                'To ensure the security of your account and comply with regulatory\nrequirements, we need to verify your identity.',
                style: Ts.regular14(color: AppColor.gray600),
                textAlign: TextAlign.center,
              ),
              const Hbox(20),
              AppButton(
                text: 'Start Verification',
                onPressed: () {
                  final Map<String, dynamic>? args = Get.arguments as Map<String, dynamic>?;
                  final bool isOnboarding = (args?['onboarding'] == true);
                  final progressService = Get.isRegistered<SignupProgressService>()
                      ? Get.find<SignupProgressService>()
                      : Get.put(SignupProgressService());
                  progressService.setStage(AppRoutes.verificationDocs);
                  Get.toNamed(AppRoutes.verificationDocs, arguments: {'onboarding': isOnboarding});
                },
                useGradient: false,
                isFullWidth: true,
                borderRadius: 24,
                height: 48,
                elevation: 0,
                bgColor: AppColor.secondary,
              ),
              const Hbox(12),
              AppButton(
                elevation: 0,
                text: 'skip',
                onPressed: () {
                  _showSkipWarningDialog();
                },
                useGradient: false,
                bgColor: AppColor.gray200,
                textColor: AppColor.gray600,
                isFullWidth: true,
                borderRadius: 24,
                height: 48,
              ),
              const Hbox(20),
            ],
          ),
        ),
    );
  }
}


