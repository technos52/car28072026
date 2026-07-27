import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/services/signup_progress_service.dart';

class OnboardingMiddleware extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    return null;
  }

  @override
  GetPage? onPageCalled(GetPage? page) {
    if (page != null) {
      final progressService = Get.isRegistered<SignupProgressService>()
          ? Get.find<SignupProgressService>()
          : Get.put(SignupProgressService());
      
      if (progressService.isOnboardingRoute(page.name)) {
        progressService.setStage(page.name);
      }
    }
    return super.onPageCalled(page);
  }
}

