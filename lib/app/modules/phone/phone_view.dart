import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter/services.dart';
import '../../../core/constants/app_color.dart';
import '../../../core/constants/app_images.dart';
import '../../../core/models/country_code.dart';
import '../../../core/utils/size.dart';
import '../../../core/utils/ts.dart';
import '../../../core/utils/app_button.dart';
import '../../../core/utils/app_textfield.dart';
import '../../../core/utils/app_text.dart';
import 'controller/phone_controller.dart';

class PhoneView extends GetView<PhoneController> {
  const PhoneView({super.key});

  @override
  Widget build(BuildContext context) {
    final double screenWidth = Get.width;
    final double horizontalPadding = screenWidth * 0.06;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        surfaceTintColor: Colors.transparent,
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: true,
      ),
      resizeToAvoidBottomInset: true,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final double kb = MediaQuery.of(context).viewInsets.bottom;
          return SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(
              horizontalPadding,
              20,
              horizontalPadding,
              (kb > 0 ? kb : 16) + 20,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Center(
                  child: Image.asset(
                    AppImage.logo,
                    width: 200,
                    height: 200,
                    fit: BoxFit.contain,
                  ),
                ),
                const Hbox(20),
                AutoSizeText(
                  'OTP Verification',
                  maxLines: 1,
                  style: Ts.bold20(color: AppColor.secondary),
                  minFontSize: 18,
                ),
                const Hbox(24),
                Text('Phone Number', style: Ts.medium12(color: AppColor.gray500)),
                const Hbox(8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Country Code Selector
                    Obx(() => GestureDetector(
                      onTap: () => _showCountryPicker(context, controller),
                      child: Container(
                        height: 56,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColor.secondary),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              controller.selectedCountry.value.flag,
                              style: const TextStyle(fontSize: 20),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              controller.selectedCountry.value.dialCode,
                              style: Ts.medium16(color: AppColor.textcolor),
                            ),
                            const SizedBox(width: 4),
                            const Icon(
                              Icons.keyboard_arrow_down_rounded,
                              color: AppColor.secondary,
                              size: 20,
                            ),
                          ],
                        ),
                      ),
                    )),
                    const SizedBox(width: 8),
                    // Phone Number Input
                    Expanded(
                      child: AppTextField(
                        controller: controller.phoneController,
                        hintText: '9999999999',
                        keyboardType: TextInputType.phone,
                        maxLength: 10,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        onChanged: controller.setPhone,
                      ),
                    ),
                  ],
                ),
                const Hbox(20),
                Obx(() => AppButton(
                  text: controller.isSending.value ? 'Sending...' : 'Send OTP',
                  onPressed: controller.isSending.value ? null : controller.submit,
                  horizontalPadding: 16,
                  useGradient: false,
                  bgColor: AppColor.secondary,
                  textColor: Colors.white,
                  isFullWidth: true,
                  borderRadius: 40,
                )),
                const SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
     
    );
  }

  void _showCountryPicker(BuildContext context, PhoneController controller) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        height: Get.height * 0.7,
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: AppColor.gray300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            AppText(
              'Select Country',
              style: Ts.bold18(color: AppColor.secondary),
            ),
            const Hbox(16),
            Expanded(
              child: ListView.builder(
                itemCount: CountryCode.countries.length,
                itemBuilder: (context, index) {
                  final country = CountryCode.countries[index];
                  final isSelected = controller.selectedCountry.value.code == country.code;
                  return ListTile(
                    leading: Text(country.flag, style: const TextStyle(fontSize: 24)),
                    title: AppText(country.name, style: Ts.medium16(color: AppColor.textcolor)),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        AppText(
                          country.dialCode,
                          style: Ts.regular14(color: AppColor.gray600),
                        ),
                        if (isSelected)
                          const Icon(Icons.check, color: AppColor.primary, size: 20),
                      ],
                    ),
                    selected: isSelected,
                    onTap: () {
                      controller.selectedCountry.value = country;
                      Get.back();
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}


