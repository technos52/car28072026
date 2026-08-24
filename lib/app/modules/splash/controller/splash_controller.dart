import 'dart:async';
import 'package:flutter/animation.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../routes/app_routes.dart';
import '../../../services/auth_service.dart';

class SplashController extends GetxController
    with GetSingleTickerProviderStateMixin {
  late final AnimationController animationController;
  late final Animation<double> scaleAnimation;
  Timer? _navigationTimer;
  bool _hasNavigated = false;

  @override
  void onInit() {
    super.onInit();
    print('SplashController: onInit called');
    _initializeAnimation();
    _startNavigationFlow();
  }

  void _initializeAnimation() {
    try {
      animationController = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 900),
      );

      scaleAnimation = Tween<double>(begin: 0.6, end: 1.1).animate(
        CurvedAnimation(parent: animationController, curve: Curves.easeOutBack),
      );

      // Start animation with error handling
      animationController.forward().catchError((e) {
        print('SplashController: Animation error: $e');
        _navigateWithDelay();
      });

      print('SplashController: Animation initialized and started');
    } catch (e) {
      print('SplashController: Error initializing animation: $e');
      // If animation fails, navigate immediately
      _navigateWithDelay();
    }
  }

  void _startNavigationFlow() {
    // Set up a fallback timer in case animation doesn't complete
    _navigationTimer = Timer(const Duration(seconds: 3), () {
      if (!_hasNavigated) {
        print('SplashController: Fallback timer triggered navigation');
        _checkAuthAndNavigate();
      }
    });

    // Listen for animation completion
    animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed && !_hasNavigated) {
        print('SplashController: Animation completed, starting navigation');
        _navigateWithDelay();
      }
    });
  }

  void _navigateWithDelay() {
    Timer(const Duration(milliseconds: 500), () {
      if (!_hasNavigated) {
        _checkAuthAndNavigate();
      }
    });
  }

  Future<void> _checkAuthAndNavigate() async {
    if (_hasNavigated) {
      print('SplashController: Already navigated, returning');
      return;
    }

    _hasNavigated = true;
    _navigationTimer?.cancel();

    print('SplashController: _checkAuthAndNavigate called');

    try {
      print('SplashController: Checking Firebase auth');
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        print('SplashController: No user found, navigating to auth');
        Get.offAllNamed(AppRoutes.auth);
      } else {
        print('SplashController: User found (${user.uid}), checking if fully onboarded');
        
        bool existing = false;
        if (Get.isRegistered<AuthService>()) {
          final authService = Get.find<AuthService>();
          existing = await authService.isExistingUser(user);
        } else {
          // Fallback if not registered, but normally it should be
          final authService = Get.put(AuthService());
          existing = await authService.isExistingUser(user);
        }

        if (existing) {
          print('SplashController: User is fully onboarded, navigating to root');
          Get.offAllNamed(AppRoutes.root);
        } else {
          print('SplashController: User not fully onboarded, navigating to profile');
          Get.offAllNamed(AppRoutes.profile, arguments: {'onboarding': true});
        }
      }
    } catch (e) {
      print('SplashController: Error in navigation: $e');
      // If there's any error, go to auth screen
      Get.offAllNamed(AppRoutes.auth);
    }
  }

  @override
  void onClose() {
    _navigationTimer?.cancel();
    animationController.dispose();
    super.onClose();
  }
}
