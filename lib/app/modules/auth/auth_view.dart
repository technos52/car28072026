import 'package:auto_size_text/auto_size_text.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_images.dart';
import '../../../core/constants/app_color.dart';
import '../../../core/utils/size.dart';
import '../../../core/utils/ts.dart';
import 'controller/auth_controller.dart';

class AuthView extends GetView<AuthController> {
  const AuthView({super.key});

  @override
  Widget build(BuildContext context) {
    final double screenWidth = Get.width;
    final double horizontalPadding = screenWidth * 0.06;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final double maxWidth = constraints.maxWidth;
            final bool isNarrow = maxWidth < 380;
            final double buttonHeight = isNarrow ? 44 : 52;
            final double spacing = isNarrow ? 12 : 16;

            final double imageSize = maxWidth > constraints.maxHeight ? constraints.maxHeight * 0.4 : maxWidth * 0.8;

            return SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 24),
                child: Column(
                  children: <Widget>[
                    Image.asset(
                      AppImage.logo,
                      width: imageSize,
                      height: imageSize,
                      fit: BoxFit.contain,
                    ),
                    AutoSizeText(
                      "Let's you in",
                      maxLines: 1,
                      style: Ts.bold32(color: AppColor.secondary),
                      minFontSize: 22,
                    ),
                    Hbox(24),
                    _ThirdPartyButton(
                      icon: FontAwesomeIcons.google,
                      label: 'Continue with Google',
                      height: buttonHeight,
                      onPressed: () => controller.signInWithGoogle(),
                    ),
                    Hbox(spacing),
                    if (!kIsWeb && Platform.isIOS) ...[
                      _ThirdPartyButton(
                        icon: FontAwesomeIcons.apple,
                        label: 'Continue with Apple',
                        height: buttonHeight,
                        onPressed: () => controller.signInWithApple(),
                      ),
                      Hbox(spacing * 2),
                    ],
                    Row(
                      children: <Widget>[
                        const Expanded(child: Divider(height: 1)),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Text(
                            'OR',
                            style: Ts.regular14(color: AppColor.gray500),
                          ),
                        ),
                        const Expanded(child: Divider(height: 1)),
                      ],
                    ),
                    Hbox(spacing * 2),
                    _ThirdPartyButton(
                      icon: FontAwesomeIcons.phone,
                      label: 'Continue with Phone',
                      height: buttonHeight,
                      onPressed: () {
                        Get.toNamed('/phone');
                      },
                    ),
                    Hbox(spacing * 2),
                    _ThirdPartyButton(
                      icon: FontAwesomeIcons.userSecret,
                      label: 'Demo Login',
                      height: buttonHeight,
                      onPressed: () => controller.continueAsGuest(),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _ThirdPartyButton extends StatelessWidget {
  final FaIconData icon;
  final String label;
  final double height;
  final VoidCallback? onPressed;

  const _ThirdPartyButton({
    required this.icon,
    required this.label,
    required this.height,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: height,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: AppColor.gray300),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          padding: const EdgeInsets.symmetric(horizontal: 18),
          alignment: Alignment.center,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FaIcon(icon, color: AppColor.secondary, size: height * 0.42),
            SizedBox(width: height * 0.22),
            Text(label, style: Ts.medium16(color: Colors.black)),
          ],
        ),
      ),
    );
  }
}
