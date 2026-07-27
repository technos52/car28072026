import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_color.dart';
import '../../../core/utils/ts.dart';
import '../../../core/utils/size.dart';
import '../../../core/utils/app_textfield.dart';
import '../../../core/utils/app_button.dart';
import '../../../core/utils/app_text.dart';
import '../../../core/utils/cached_image.dart';
import 'controller/profile_controller.dart';

class ProfileView extends GetView<ProfileController> {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic>? arguments =
        Get.arguments as Map<String, dynamic>?;
    final bool isOnboarding = (arguments?['onboarding'] == true);

    // Ensure data is loaded after controller is created
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.loadData();
    });

    final String title = isOnboarding ? 'Owner Information' : 'Edit Profile';
    final String buttonText = isOnboarding ? 'Continue' : 'Update';

    return PopScope(
      canPop: !isOnboarding,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          surfaceTintColor: Colors.transparent,
          backgroundColor: Colors.white,
          elevation: 0,
          automaticallyImplyLeading: !isOnboarding,
          title: AppText(title, style: Ts.semiBold18(color: AppColor.secondary)),
          centerTitle: true,
        ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Hbox(20),
            // Profile Picture Section
            Center(
              child: Stack(
                children: [
                  Obx(() {
                    final String path = controller.avatarPath.value;
                    final bool isNetworkImage =
                        path.isNotEmpty &&
                        (path.startsWith('http://') ||
                            path.startsWith('https://'));
                    final bool isLocalFile =
                        path.isNotEmpty &&
                        !isNetworkImage &&
                        (path.startsWith('/') || path.startsWith('file://'));

                    return Container(
                      width: 120,
                      height: 120,
                      decoration: const BoxDecoration(shape: BoxShape.circle),
                      child: ClipOval(
                        child: path.isNotEmpty
                            ? (isNetworkImage
                                  ? CachedImage(
                                      imageUrl: path,
                                      width: 120,
                                      height: 120,
                                      fit: BoxFit.cover,
                                      errorWidget: Container(
                                        color: AppColor.gray100,
                                        child: const Icon(
                                          Icons.person,
                                          size: 60,
                                          color: AppColor.gray400,
                                        ),
                                      ),
                                    )
                                  : isLocalFile
                                  ? Image.file(
                                      File(path.replaceFirst('file://', '')),
                                      width: 120,
                                      height: 120,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) =>
                                              Container(
                                                color: AppColor.gray100,
                                                child: const Icon(
                                                  Icons.person,
                                                  size: 60,
                                                  color: AppColor.gray400,
                                                ),
                                              ),
                                    )
                                  : Container(
                                      color: AppColor.gray100,
                                      child: const Icon(
                                        Icons.person,
                                        size: 60,
                                        color: AppColor.gray400,
                                      ),
                                    ))
                            : Container(
                                color: AppColor.gray100,
                                child: const Icon(
                                  Icons.person,
                                  size: 60,
                                  color: AppColor.gray400,
                                ),
                              ),
                      ),
                    );
                  }),
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: GestureDetector(
                      onTap: () async {
                        await showModalBottomSheet(
                          context: context,
                          showDragHandle: true,
                          backgroundColor: Colors.white,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(16),
                            ),
                          ),
                          builder: (ctx) => SafeArea(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                ListTile(
                                  leading: const Icon(
                                    Icons.photo_camera_outlined,
                                    color: AppColor.secondary,
                                  ),
                                  title: AppText(
                                    'Take photo',
                                    style: Ts.regular16(
                                      color: AppColor.secondary,
                                    ),
                                  ),
                                  onTap: () async {
                                    Navigator.pop(
                                      context,
                                    ); // Use Navigator.pop instead of Get.back()
                                    await Future.delayed(
                                      const Duration(milliseconds: 100),
                                    ); // Small delay
                                    await controller.pickAvatarFromCamera();
                                  },
                                ),
                                ListTile(
                                  leading: const Icon(
                                    Icons.photo_library_outlined,
                                    color: AppColor.secondary,
                                  ),
                                  title: AppText(
                                    'Choose from gallery',
                                    style: Ts.regular16(
                                      color: AppColor.secondary,
                                    ),
                                  ),
                                  onTap: () async {
                                    Navigator.pop(
                                      context,
                                    ); // Use Navigator.pop instead of Get.back()
                                    await Future.delayed(
                                      const Duration(milliseconds: 100),
                                    ); // Small delay
                                    await controller.pickAvatarFromGallery();
                                  },
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: AppColor.gray600,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: const Icon(
                          Icons.camera_alt_rounded,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Hbox(40),

            // Full name field
            AppText(
              'Full name',
              style: Ts.regular14(color: AppColor.secondary),
              isRich: true,
              spans: [
                TextSpan(
                  text: ' *',
                  style: Ts.regular14(color: Colors.red),
                ),
              ],
            ),
            const Hbox(8),
            AppTextField(
              controller: controller.nameController,
              hintText: 'Full name',
              prefixIcon: const Icon(
                Icons.person_outline_rounded,
                color: AppColor.secondary,
              ),
              keyboardType: TextInputType.name,
            ),
            const Hbox(20),

            // Phone Number field
            AppText(
              'Phone Number',
              style: Ts.regular14(color: AppColor.secondary),
              isRich: true,
              spans: [
                TextSpan(
                  text: ' *',
                  style: Ts.regular14(color: Colors.red),
                ),
              ],
            ),
            const Hbox(8),
            Obx(() {
              final isPhonePrefilled = controller.isPhonePrefilled.value;
              return AppTextField(
                controller: controller.phoneController,
                hintText: 'Phone Number',
                keyboardType: TextInputType.phone,
                maxLength: 10,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                prefixIcon: const Icon(
                  Icons.phone_outlined,
                  color: AppColor.secondary,
                ),
                enabled: !isOnboarding || !isPhonePrefilled,
              );
            }),
            const Hbox(20),
            // Email field
            AppText('Email', style: Ts.regular14(color: AppColor.secondary)),
            const Hbox(8),
            Obx(() {
              final isEmailPrefilled = controller.isEmailPrefilled.value;
              return AppTextField(
                controller: controller.emailController,
                hintText: 'xxx@gmail.com',
                keyboardType: TextInputType.emailAddress,
                prefixIcon: const Icon(
                  Icons.email_outlined,
                  color: AppColor.secondary,
                ),
                enabled: !isOnboarding || !isEmailPrefilled,
              );
            }),
            const Hbox(20),

            // Gender dropdown
            AppText('Gender', style: Ts.regular14(color: AppColor.secondary)),
            const Hbox(8),
            Container(
              height: 56,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColor.secondary),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Obx(
                () => DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: controller.selectedGender.value,
                    isExpanded: true,
                    icon: const Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: AppColor.secondary,
                      size: 20,
                    ),
                    dropdownColor: Colors.white,
                    style: Ts.regular16(color: AppColor.secondary),
                    hint: AppText(
                      'Gender',
                      style: Ts.regular16(color: AppColor.secondary),
                    ),
                    items: controller.genders
                        .map(
                          (String g) => DropdownMenuItem<String>(
                            value: g,
                            child: AppText(
                              g,
                              style: Ts.regular16(color: AppColor.secondary),
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (String? v) {
                      if (v != null) controller.selectedGender.value = v;
                    },
                  ),
                ),
              ),
            ),

            const Hbox(40),

            // Dynamic Button
            Obx(
              () => AppButton(
                text: controller.isSaving.value
                    ? (isOnboarding ? 'Continuing...' : 'Updating...')
                    : buttonText,
                onPressed: controller.isSaving.value ? null : controller.submit,
                useGradient: false,
                bgColor: AppColor.secondary,
                isFullWidth: true,
                borderRadius: 30,
                height: 56,
              ),
            ),

            const Hbox(30),
          ],
        ),
      ),
    ),);
  }
}
