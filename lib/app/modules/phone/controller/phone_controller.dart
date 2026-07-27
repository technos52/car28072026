import 'package:DealMatee/app/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../services/auth_service.dart';
import '../../../../core/models/country_code.dart';
import '../../otp/controller/otp_controller.dart';
import '../../../../core/services/remote_service.dart';

class PhoneController extends GetxController {
  final Rx<CountryCode> selectedCountry = CountryCode.getDefault().obs;
  final RxString phoneNumber = ''.obs;
  final TextEditingController phoneController = TextEditingController();
  final RxBool isSending = false.obs;
  // store latest verification id if needed by UI flows
  String? get lastVerificationId =>
      _resendToken == null ? null : _cachedVerificationId;
  String? _cachedVerificationId;
  int? _resendToken;

  void setPhone(String value) {
    phoneNumber.value = value;
  }

  Future<void> submit() async {
    final String digits = phoneNumber.value.replaceAll(RegExp(r"[^0-9]"), "");
    if (digits.length != 10) {
      Get.snackbar(
        'Error',
        'Please enter a valid 10-digit phone number',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    final String fullPhone = '${selectedCountry.value.dialCode}$digits';
    isSending.value = true;

    // Navigate immediately for better UX - don't wait for SMS
    Get.toNamed(
      AppRoutes.otp,
      arguments: {
        'phoneNumber': fullPhone,
        'verificationId': '', // Will be set when codeSent callback fires
        'resendToken': null,
        'isSending': true, // Flag to show loading on OTP screen
      },
    );

    // Don't await - let it run in background while user sees OTP screen
    final AuthService auth = Get.isRegistered<AuthService>()
        ? Get.find<AuthService>()
        : Get.put<AuthService>(AuthService(), permanent: true);

    auth.verifyPhoneNumber(
      phoneNumber: fullPhone,
      verificationCompleted: (PhoneAuthCredential credential) async {
        try {
          final userCredential = await FirebaseAuth.instance
              .signInWithCredential(credential);
          final user = userCredential.user;

          if (user != null) {
            // Check if user is new or existing
            final authService = Get.find<AuthService>();
            final isExisting = await authService.isExistingUser(user);

            if (isExisting) {
              // Existing user - go to home
              Get.offAllNamed(AppRoutes.root);
            } else {
              // New user - go to profile setup
              Get.offAllNamed(
                AppRoutes.profile,
                arguments: {'onboarding': true},
              );
            }
          }
        } catch (e) {
          Get.snackbar('Error', e.toString());
        }
      },
      verificationFailed: (FirebaseAuthException error) {
        isSending.value = false;

        // Don't show session-expired errors - they're usually stale callbacks after successful verification
        if (error.code.contains('session-expired') ||
            (error.message?.contains('session-expired') ?? false)) {
          print('Ignoring stale session-expired error from phone controller');
          // Check if user is already authenticated (verification succeeded via another path)
          if (FirebaseAuth.instance.currentUser != null) {
            return; // User already authenticated, ignore this error
          }
        }

        if (Get.currentRoute == AppRoutes.otp) {
          if (Get.isRegistered<OtpController>()) {
            final otpCtrl = Get.find<OtpController>();
            // Don't process errors if already verified
            if (otpCtrl.isVerified.value || otpCtrl.isDisposed) {
              return;
            }
            final verificationId =
                Get.arguments['verificationId']?.toString() ?? '';
            if (verificationId.isNotEmpty) {
              otpCtrl.verificationId = verificationId;
              otpCtrl.isWaitingForSms.value = false;
              otpCtrl.startTimer();
              return;
            }
          }
          Get.back();
        }

        // Only show non-session-expired errors
        if (!error.code.contains('session-expired') &&
            !(error.message?.contains('session-expired') ?? false)) {
          Get.snackbar(
            'Verification failed',
            error.message ?? error.code,
            snackPosition: SnackPosition.TOP,
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
        }
      },
      codeSent: (String verificationId, int? resendToken) {
        _cachedVerificationId = verificationId;
        _resendToken = resendToken;
        isSending.value = false;
        // Update arguments if we're on OTP screen
        if (Get.currentRoute == AppRoutes.otp) {
          Get.arguments['verificationId'] = verificationId;
          Get.arguments['resendToken'] = resendToken;
          Get.arguments['isSending'] = false;
          // Update the OTP controller if it exists
          if (Get.isRegistered<OtpController>()) {
            final otpCtrl = Get.find<OtpController>();
            otpCtrl.verificationId = verificationId;
            otpCtrl.resendToken = resendToken;
            otpCtrl.isWaitingForSms.value = false;
            otpCtrl.startTimer();
          }
        }
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        _cachedVerificationId = verificationId;
        isSending.value = false;
        if (Get.currentRoute == AppRoutes.otp) {
          Get.arguments['verificationId'] = verificationId;
          Get.arguments['isSending'] = false;
          if (Get.isRegistered<OtpController>()) {
            final otpCtrl = Get.find<OtpController>();
            otpCtrl.verificationId = verificationId;
            otpCtrl.isWaitingForSms.value = false;
            otpCtrl.startTimer();
          }
        }
      },
      forceResendingToken: _resendToken,
    );
  }

  Future<void> continueAsGuest() async {
    isSending.value = true;
    try {
      final auth = Get.find<AuthService>();
      final userCred = await auth.signInAnonymously();
      
      final user = userCred.user;
      if (user != null) {
        if (!Get.isRegistered<RemoteService>()) {
          Get.put(RemoteService());
        }
        final remoteService = Get.find<RemoteService>();
        
        await remoteService.saveUser(
          id: user.uid,
          name: "Demo User",
          email: "demo@dealmatee.com",
          phone: "9999999999",
          gender: "Male",
        );

        await remoteService.saveShop(
          id: "${user.uid}_shop",
          userId: user.uid,
          shopName: "Demo Dealership",
          ownerName: "Demo User",
          phone: "9999999999",
          email: "demo@dealmatee.com",
          address: "123 Demo Street",
          city: "Demo City",
          state: "Demo State",
          pincode: "111111",
        );

        await remoteService.saveCar(
          id: "${user.uid}_car_1",
          userId: user.uid,
          make: "Toyota",
          model: "Camry",
          year: "2023",
          price: "2500000",
          description: "This is a prefilled demo car.",
          isAvailable: true,
        );
      }

      Get.offAllNamed(AppRoutes.root);
    } catch (e) {
      Get.snackbar('Error', 'Failed to continue as guest: $e');
    } finally {
      isSending.value = false;
    }
  }

  @override
  void onClose() {
    phoneController.dispose();
    super.onClose();
  }

  bool get isLoading => isSending.value;
  bool get isInProgress => isSending.value;
}
