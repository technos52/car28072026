import 'dart:async';
import 'package:DealMatee/app/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../services/auth_service.dart';

class OtpController extends GetxController {
  // OTP state
  final RxString enteredOtp = ''.obs;
  final RxBool isVerifying = false.obs;
  final RxBool isVerified = false.obs;

  // Timer for resend functionality
  Timer? _resendTimer;
  final RxInt timerCount = 60.obs;
  final RxBool canResend = false.obs;

  // SMS waiting state
  final RxBool isWaitingForSms = false.obs;

  // Phone verification data
  late String phoneNumber;
  String verificationId = '';
  int? resendToken;

  // Prevent multiple verifications
  bool _isProcessing = false;

  // Compatibility properties for existing UI
  bool get isDisposed =>
      false; // Always false since we don't use disposal tracking

  @override
  void onInit() {
    super.onInit();
    _initializeFromArguments();
  }

  void _initializeFromArguments() {
    final args = Get.arguments as Map<String, dynamic>? ?? {};

    phoneNumber = args['phoneNumber'] ?? '';
    verificationId = args['verificationId'] ?? '';
    resendToken = args['resendToken'];

    final bool isSending = args['isSending'] == true;

    if (isSending || verificationId.isEmpty) {
      isWaitingForSms.value = true;
      _waitForVerificationId();
    } else {
      _startResendTimer();
    }
  }

  void _waitForVerificationId() {
    // Poll for verification ID update from phone controller
    Timer.periodic(const Duration(milliseconds: 500), (timer) {
      if (timer.tick > 60) {
        // 30 seconds timeout
        timer.cancel();
        isWaitingForSms.value = false;
        _showError('Failed to send verification code. Please try again.');
        return;
      }

      final args = Get.arguments as Map<String, dynamic>? ?? {};
      final newVerificationId = args['verificationId'] ?? '';

      if (newVerificationId.isNotEmpty) {
        verificationId = newVerificationId;
        resendToken = args['resendToken'];
        isWaitingForSms.value = false;
        _startResendTimer();
        timer.cancel();
      }
    });
  }

  void _startResendTimer() {
    canResend.value = false;
    timerCount.value = 60;

    _resendTimer?.cancel();
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (timerCount.value > 0) {
        timerCount.value--;
      } else {
        canResend.value = true;
        timer.cancel();
      }
    });
  }

  // Compatibility method for phone controller
  void startTimer() => _startResendTimer();

  void onOtpChanged(String value) {
    if (_isProcessing || isVerified.value) return;

    enteredOtp.value = value;

    // Auto-verify when 6 digits entered
    if (value.length == 6) {
      verifyOtp(value);
    }
  }

  void verifyOtp([String? code]) async {
    if (_isProcessing || isVerified.value) return;

    final otpCode = code ?? enteredOtp.value;

    if (otpCode.length != 6) {
      _showError('Please enter the 6-digit verification code');
      return;
    }

    if (verificationId.isEmpty) {
      _showError('Verification session expired. Please request a new code.');
      return;
    }

    _isProcessing = true;
    isVerifying.value = true;

    try {
      // Create credential and sign in
      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: otpCode,
      );

      final userCredential = await FirebaseAuth.instance.signInWithCredential(
        credential,
      );

      if (userCredential.user == null) {
        throw Exception('Authentication failed');
      }

      // Mark as verified
      isVerified.value = true;
      isVerifying.value = false;

      // Check user status and navigate
      await _handleSuccessfulVerification(userCredential.user!);
    } on FirebaseAuthException catch (e) {
      _isProcessing = false;
      isVerifying.value = false;

      String errorMessage = 'Verification failed';
      switch (e.code) {
        case 'invalid-verification-code':
          errorMessage = 'Invalid verification code. Please try again.';
          break;
        case 'session-expired':
          errorMessage =
              'Verification session expired. Please request a new code.';
          break;
        case 'too-many-requests':
          errorMessage = 'Too many attempts. Please try again later.';
          break;
        default:
          errorMessage = e.message ?? 'Verification failed';
      }

      _showError(errorMessage);
    } catch (e) {
      _isProcessing = false;
      isVerifying.value = false;
      _showError('An unexpected error occurred. Please try again.');
    }
  }

  Future<void> _handleSuccessfulVerification(User user) async {
    try {
      final authService = Get.find<AuthService>();
      final isExisting = await authService.isExistingUser(user);

      if (isExisting) {
        // Existing user with complete profile - go to home
        Get.offAllNamed(AppRoutes.root);
      } else {
        // New user or incomplete profile - go to onboarding
        Get.offAllNamed(AppRoutes.profile, arguments: {'onboarding': true});
      }
    } catch (e) {
      // Fallback to onboarding if check fails
      Get.offAllNamed(AppRoutes.profile, arguments: {'onboarding': true});
    }
  }

  void resendCode() async {
    if (!canResend.value || _isProcessing) return;

    try {
      final authService = Get.find<AuthService>();

      await authService.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        codeSent: (String newVerificationId, int? newResendToken) {
          verificationId = newVerificationId;
          resendToken = newResendToken;
          _startResendTimer();
          _showSuccess('Verification code sent to $phoneNumber');
        },
        verificationCompleted: (PhoneAuthCredential credential) async {
          // Handle auto-verification
          try {
            final userCredential = await FirebaseAuth.instance
                .signInWithCredential(credential);
            if (userCredential.user != null) {
              isVerified.value = true;
              await _handleSuccessfulVerification(userCredential.user!);
            }
          } catch (e) {
            _showError('Auto-verification failed');
          }
        },
        verificationFailed: (FirebaseAuthException error) {
          _showError(error.message ?? 'Failed to send verification code');
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          // Timeout callback - no action needed
        },
        forceResendingToken: resendToken,
      );
    } catch (e) {
      _showError('Failed to resend code. Please try again.');
    }
  }

  void _showError(String message) {
    Get.snackbar(
      'Error',
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.red,
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
    );
  }

  void _showSuccess(String message) {
    Get.snackbar(
      'Success',
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.green,
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
    );
  }

  @override
  void onClose() {
    _resendTimer?.cancel();
    super.onClose();
  }
}
