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

    try {
      final AuthService auth = Get.isRegistered<AuthService>()
          ? Get.find<AuthService>()
          : Get.put<AuthService>(AuthService(), permanent: true);

      await auth.verifyPhoneNumber(
        phoneNumber: fullPhone,
        verificationCompleted: (PhoneAuthCredential credential) async {
          try {
            final userCredential = await FirebaseAuth.instance
                .signInWithCredential(credential);
            final user = userCredential.user;

            if (user != null) {
              final authService = Get.find<AuthService>();
              final isExisting = await authService.isExistingUser(user);

              if (isExisting) {
                Get.offAllNamed(AppRoutes.root);
              } else {
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
            if (FirebaseAuth.instance.currentUser != null) {
              return;
            }
          }

          if (Get.currentRoute == AppRoutes.otp) {
            if (Get.isRegistered<OtpController>()) {
              final otpCtrl = Get.find<OtpController>();
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
          if (Get.currentRoute == AppRoutes.otp) {
            Get.arguments['verificationId'] = verificationId;
            Get.arguments['resendToken'] = resendToken;
            Get.arguments['isSending'] = false;
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
    } catch (e) {
      isSending.value = false;
      print('Phone verification call error: $e');
      if (Get.currentRoute == AppRoutes.otp) {
        Get.back();
      }
      Get.snackbar(
        'Error',
        e.toString(),
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> continueAsGuest() async {
    isSending.value = true;
    try {
      User? user;
      try {
        final auth = Get.find<AuthService>();
        final userCred = await auth.signInAnonymously();
        user = userCred.user;
      } catch (_) {}

      final uid = user?.uid ?? 'demo_guest_user';

      if (!Get.isRegistered<RemoteService>()) {
        Get.put(RemoteService());
      }
      final remoteService = Get.find<RemoteService>();

      try {
        await remoteService.saveUser(
          id: uid,
          name: "Demo Dealer",
          email: "demo@dealmatee.com",
          phone: "9999999999",
          gender: "Male",
          avatarUrl: "https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=300&q=80",
        );

        await remoteService.saveShop(
          id: "${uid}_shop",
          userId: uid,
          shopName: "DealMatee Premium Motors",
          ownerName: "Demo Dealer",
          phone: "9999999999",
          email: "demo@dealmatee.com",
          address: "Auto Hub, Link Road, Andheri West",
          city: "Mumbai",
          state: "Maharashtra",
          pincode: "400053",
        );

        await remoteService.saveKycDocument(
          id: uid,
          userId: uid,
          panPath: "https://images.unsplash.com/photo-1554224155-8d04cb21cd6c?auto=format&fit=crop&w=400&q=80",
          aadhaarPath: "https://images.unsplash.com/photo-1554224155-8d04cb21cd6c?auto=format&fit=crop&w=400&q=80",
          addressProofPath: "https://images.unsplash.com/photo-1554224155-8d04cb21cd6c?auto=format&fit=crop&w=400&q=80",
          isVerified: true,
        );

        await remoteService.saveCar(
          id: "${uid}_car_1",
          userId: uid,
          make: "Toyota",
          model: "Camry",
          year: "2023",
          price: "2500000",
          variant: "ZX Hybrid",
          fuelType: "Petrol",
          transmission: "Automatic",
          color: "Pearl White",
          kmsDriven: "18500",
          owner: "1st Owner",
          insurance: "Comprehensive",
          mileage: "19.1 kmpl",
          tankCapacity: "50 L",
          state: "Maharashtra",
          city: "Mumbai",
          pincode: "400053",
          imageUrls: [
            "https://images.unsplash.com/photo-1621007947382-bb3c3994e3fb?auto=format&fit=crop&w=800&q=80",
            "https://images.unsplash.com/photo-1549317661-bd32c8ce0db2?auto=format&fit=crop&w=800&q=80",
          ],
          description: "Pristine condition Toyota Camry Hybrid. Fully serviced at authorized dealership with complete records.",
          isAvailable: true,
        );
      } catch (_) {}

      Get.offAllNamed(AppRoutes.root);
    } catch (e) {
      Get.offAllNamed(AppRoutes.root);
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
