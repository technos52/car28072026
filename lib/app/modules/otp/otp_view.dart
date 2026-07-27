import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:sms_autofill/sms_autofill.dart';
import '../../../core/constants/app_color.dart';
import '../../../core/utils/ts.dart';
import '../../../core/utils/app_button.dart';
import '../../../core/utils/app_text.dart';
import '../../../core/utils/size.dart';
import 'controller/otp_controller.dart';

class OtpView extends StatefulWidget {
  const OtpView({super.key});

  @override
  State<OtpView> createState() => _OtpViewState();
}

class _OtpViewState extends State<OtpView> with CodeAutoFill {
  final OtpController controller = Get.put(OtpController());
  final TextEditingController otpController = TextEditingController();
  String? _code;
  bool _isControllerDisposed = false;

  @override
  void initState() {
    super.initState();
    // Start listening for SMS code
    listenForCode();
    // Get app signature for debugging (optional)
    SmsAutoFill().getAppSignature
        .then((signature) {
          print('App signature: $signature');
        })
        .catchError((e) {
          print('Error getting app signature: $e');
        });
  }

  @override
  void codeUpdated() {
    if (controller.isVerified.value || controller.isDisposed) {
      return;
    }

    final String? smsCode = code;
    if (smsCode != null && smsCode.length == 6 && smsCode != _code) {
      _code = smsCode;

      if (controller.isVerified.value || controller.isDisposed) {
        return;
      }

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted ||
            _isControllerDisposed ||
            controller.isVerified.value ||
            controller.isDisposed) {
          return;
        }

        try {
          if (mounted && !_isControllerDisposed) {
            otpController.text = _code!;
            controller.enteredOtp.value = _code!;
            controller.onOtpChanged(_code!);
          }
        } catch (e) {
          if (mounted) {
            print('Error updating OTP controller: $e');
          }
        }
      });
    }
  }

  @override
  void dispose() {
    _isControllerDisposed = true;
    cancel();
    otpController.dispose();
    super.dispose();
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
        title: AppText(
          'OTP Verification',
          style: Ts.bold20(color: AppColor.secondary),
        ),
        centerTitle: true,
      ),
      resizeToAvoidBottomInset: true,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final double kb = MediaQuery.of(context).viewInsets.bottom;
          return SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(24, 0, 24, (kb > 0 ? kb : 16) + 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Hbox(40),

                // Information text
                Obx(
                  () => Text(
                    controller.isWaitingForSms.value
                        ? 'Sending verification code to ${controller.phoneNumber}...'
                        : 'Code has been send to ${controller.phoneNumber}',
                    style: Ts.regular16(color: AppColor.gray500),
                    textAlign: TextAlign.center,
                  ),
                ),

                const Hbox(40),

                // Show loading indicator while waiting for SMS
                Obx(
                  () => controller.isWaitingForSms.value
                      ? const Center(
                          child: Padding(
                            padding: EdgeInsets.all(20.0),
                            child: CircularProgressIndicator(
                              color: AppColor.secondary,
                            ),
                          ),
                        )
                      : const SizedBox.shrink(),
                ),

                Obx(
                  () => controller.isWaitingForSms.value
                      ? const Hbox(20)
                      : const SizedBox.shrink(),
                ),

                // OTP Pin Code Fields
                Obx(
                  () => controller.isWaitingForSms.value
                      ? const SizedBox.shrink()
                      : LayoutBuilder(
                          builder: (context, constraints) {
                            final double available = constraints.maxWidth;
                            const double gap = 10;
                            final double rawWidth = (available - (gap * 5)) / 6;
                            final double boxWidth = rawWidth.clamp(42, 56);
                            final double boxHeight = 56;
                            return SizedBox(
                              width: available,
                              child: PinCodeTextField(
                                appContext: context,
                                length: 6,
                                controller: otpController,
                                onChanged: controller.onOtpChanged,
                                onCompleted: (value) =>
                                    controller.verifyOtp(value),
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                pinTheme: PinTheme(
                                  shape: PinCodeFieldShape.box,
                                  borderRadius: BorderRadius.circular(12),
                                  fieldHeight: boxHeight,
                                  fieldWidth: boxWidth,
                                  activeFillColor: Colors.white,
                                  inactiveFillColor: AppColor.gray100,
                                  selectedFillColor: Colors.white,
                                  activeColor: AppColor.primary,
                                  inactiveColor: AppColor.gray300,
                                  selectedColor: AppColor.primary,
                                  borderWidth: 1.5,
                                ),
                                enableActiveFill: true,
                                keyboardType: TextInputType.number,
                                textStyle: Ts.bold20(color: AppColor.textcolor),
                                animationType: AnimationType.fade,
                                animationDuration: const Duration(
                                  milliseconds: 300,
                                ),
                                enablePinAutofill: true,
                                autoFocus: !controller.isWaitingForSms.value,
                              ),
                            );
                          },
                        ),
                ),

                Hbox(Get.height * 0.07),

                // Resend code timer
                Center(
                  child: Obx(() {
                    if (controller.canResend.value) {
                      return GestureDetector(
                        onTap: controller.resendCode,
                        child: Text(
                          'Resend Code',
                          style: Ts.medium16(color: AppColor.primary),
                        ),
                      );
                    } else {
                      return Text(
                        'Resend code in ${controller.timerCount.value}s',
                        style: Ts.regular14(color: AppColor.gray500),
                      );
                    }
                  }),
                ),
                const Hbox(24),

                // Verify Button
                Obx(
                  () => AppButton(
                    text: controller.isVerifying.value
                        ? 'Verifying...'
                        : 'Verify',
                    onPressed: controller.isVerifying.value
                        ? null
                        : controller.verifyOtp,
                    horizontalPadding: 16,
                    bgColor: AppColor.secondary,
                    useGradient: false,
                    isFullWidth: true,
                    borderRadius: 30,
                    height: 52,
                  ),
                ),

                const SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
    );
  }
}
