import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_images.dart';
import 'controller/splash_controller.dart';

class SplashView extends GetView<SplashController> {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: GetBuilder<SplashController>(
            init: SplashController(),
            builder: (controller) {
              return AnimatedBuilder(
                animation: controller.animationController,
                builder: (context, child) {
                  return Transform.scale(
                    scale: controller.scaleAnimation.value,
                    child: child,
                  );
                },
                child: Image.asset(
                  AppImage.logo,
                  width: Get.width * 0.5,
                  height: Get.height * 0.5,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    print('Error loading logo: $error');
                    return Container(
                      width: Get.width * 0.5,
                      height: Get.height * 0.5,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.car_rental,
                        size: 80,
                        color: Colors.grey,
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
