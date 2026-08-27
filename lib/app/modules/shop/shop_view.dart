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
import 'controller/shop_controller.dart';
import '../../routes/app_routes.dart';

class ShopView extends GetView<ShopController> {
  const ShopView({super.key});

  @override
  Widget build(BuildContext context) {
    // Ensure controller is registered
    if (!Get.isRegistered<ShopController>()) {
      Get.put(ShopController());
    }

    final dynamic args = Get.arguments;
    final bool isEdit = args is Map && args['from'] == 'edit';
    final bool isOnboarding = args is Map && args['onboarding'] == true;

    // Ensure data is loaded after controller is created
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.loadData();
    });
    return PopScope(
      canPop: !isOnboarding,
      child: Scaffold(
        backgroundColor: Colors.white,
      appBar: AppBar(
        surfaceTintColor: Colors.transparent,
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        leading: isOnboarding
            ? null
            : IconButton(
                icon: const Icon(Icons.arrow_back, color: AppColor.secondary),
                onPressed: () {
                  Get.back();
                },
              ),
        title: Text(
          isEdit ? 'Edit Shop Details' : 'Shop Information',
          style: Ts.bold20(color: AppColor.secondary),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Hbox(8),
            Center(
              child: Stack(
                alignment: Alignment.bottomRight,
                children: [
                  Obx(() {
                    final String path = controller.logoPath.value;
                    final bool isNetworkImage =
                        path.isNotEmpty &&
                        (path.startsWith('http://') ||
                            path.startsWith('https://'));
                    final bool isLocalFile =
                        path.isNotEmpty &&
                        !isNetworkImage &&
                        (path.startsWith('/') || path.startsWith('file://'));

                    return Container(
                      width: 140,
                      height: 140,
                      decoration: BoxDecoration(
                        color: AppColor.gray100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: path.isNotEmpty
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: isNetworkImage
                                  ? CachedImage(
                                      imageUrl: path,
                                      width: 140,
                                      height: 140,
                                      fit: BoxFit.cover,
                                      errorWidget: const Icon(
                                        Icons.storefront_outlined,
                                        size: 64,
                                        color: AppColor.gray400,
                                      ),
                                    )
                                  : isLocalFile
                                  ? Image.file(
                                      File(path.replaceFirst('file://', '')),
                                      width: 140,
                                      height: 140,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) =>
                                              const Icon(
                                                Icons.storefront_outlined,
                                                size: 64,
                                                color: AppColor.gray400,
                                              ),
                                    )
                                  : const Icon(
                                      Icons.storefront_outlined,
                                      size: 64,
                                      color: AppColor.gray400,
                                    ),
                            )
                          : const Icon(
                              Icons.storefront_outlined,
                              size: 64,
                              color: AppColor.gray400,
                            ),
                    );
                  }),
                  GestureDetector(
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
                                title: Text(
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
                                  await controller.pickLogoFromCamera();
                                },
                              ),
                              ListTile(
                                leading: const Icon(
                                  Icons.photo_library_outlined,
                                  color: AppColor.secondary,
                                ),
                                title: Text(
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
                                  await controller.pickLogoFromGallery();
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                    child: Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFF2CADD6), Color(0xFF14256B)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        shape: BoxShape.circle,
                      ),
                      padding: const EdgeInsets.all(6),
                      child: const Icon(
                        Icons.camera_alt_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Hbox(8),
            // Shop logo mandatory label
            Center(
              child: Text.rich(
                const TextSpan(
                  text: 'Shop Logo',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFF0B409C)),
                  children: [
                    TextSpan(
                      text: ' *',
                      style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
            const Hbox(16),
            AppText(
              'Shop Name',
              style: Ts.medium12(color: AppColor.secondary),
              isRich: true,
              spans: [
                TextSpan(
                  text: ' *',
                  style: Ts.medium12(color: Colors.red),
                ),
              ],
            ),
            const Hbox(8),
            AppTextField(
              controller: controller.shopNameController,
              hintText: 'shop name',
              prefixIcon: Icon(
                Icons.storefront_outlined,
                color: AppColor.secondary.withValues(alpha: 0.5),
              ),
              keyboardType: TextInputType.name,
            ),
            const Hbox(16),
            AppText(
              'Shop owner name',
              style: Ts.medium12(color: AppColor.secondary),
              isRich: true,
              spans: [
                TextSpan(
                  text: ' *',
                  style: Ts.medium12(color: Colors.red),
                ),
              ],
            ),
            const Hbox(8),
            Obx(() {
              final isOwnerNamePrefilled =
                  controller.isOwnerNamePrefilled.value;
              return AppTextField(
                controller: controller.ownerNameController,
                hintText: 'Full name',
                prefixIcon: Icon(
                  Icons.person_outline_rounded,
                  color: AppColor.secondary.withValues(alpha: 0.5),
                ),
                keyboardType: TextInputType.name,
                enabled: isEdit || !isOnboarding || !isOwnerNamePrefilled,
              );
            }),
            const Hbox(16),
            AppText(
              'Shop Phone Number',
              style: Ts.medium12(color: AppColor.secondary),
              isRich: true,
              spans: [
                TextSpan(
                  text: ' *',
                  style: Ts.medium12(color: Colors.red),
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
                prefixIcon: Icon(
                  Icons.phone_outlined,
                  color: AppColor.secondary.withValues(alpha: 0.5),
                ),
                enabled: !isPhonePrefilled,
              );
            }),
            const Hbox(16),
            AppText(
              'Email',
              style: Ts.medium12(color: AppColor.secondary),
              isRich: true,
              spans: [
                TextSpan(
                  text: ' *',
                  style: Ts.medium12(color: Colors.red),
                ),
              ],
            ),
            const Hbox(8),
            Obx(() {
              final isEmailPrefilled = controller.isEmailPrefilled.value;
              return AppTextField(
                controller: controller.emailController,
                hintText: 'xxx@gmail.com',
                keyboardType: TextInputType.emailAddress,
                prefixIcon: Icon(
                  Icons.email_outlined,
                  color: AppColor.secondary.withValues(alpha: 0.5),
                ),
                enabled: !isEmailPrefilled,
              );
            }),
            const Hbox(16),
            AppText(
              'Shop Address',
              style: Ts.medium12(color: AppColor.secondary),
              isRich: true,
              spans: [
                TextSpan(
                  text: ' *',
                  style: Ts.medium12(color: Colors.red),
                ),
              ],
            ),
            const Hbox(8),
            AppTextField(
              controller: controller.addressController,
              hintText: 'Address',
              keyboardType: TextInputType.streetAddress,
              prefixIcon: Icon(
                Icons.home_outlined,
                color: AppColor.secondary.withValues(alpha: 0.5),
              ),
            ),
            const Hbox(16),
            // City, State, Pincode Row
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppText(
                        'City',
                        style: Ts.medium12(color: AppColor.secondary),
                        isRich: true,
                        spans: [
                          TextSpan(
                            text: ' *',
                            style: Ts.medium12(color: Colors.red),
                          ),
                        ],
                      ),
                      const Hbox(8),
                      AppTextField(
                        controller: controller.cityController,
                        hintText: 'City',
                        keyboardType: TextInputType.text,
                        prefixIcon: Icon(
                          Icons.location_city_outlined,
                          color: AppColor.secondary.withValues(alpha: 0.5),
                        ),
                      ),
                    ],
                  ),
                ),
                const Wbox(12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppText(
                        'State',
                        style: Ts.medium12(color: AppColor.secondary),
                        isRich: true,
                        spans: [
                          TextSpan(
                            text: ' *',
                            style: Ts.medium12(color: Colors.red),
                          ),
                        ],
                      ),
                      const Hbox(8),
                      AppTextField(
                        controller: controller.stateController,
                        hintText: 'State',
                        keyboardType: TextInputType.text,
                        prefixIcon: Icon(
                          Icons.map_outlined,
                          color: AppColor.secondary.withValues(alpha: 0.5),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Hbox(16),
            AppText(
              'Pincode',
              style: Ts.medium12(color: AppColor.secondary),
              isRich: true,
              spans: [
                TextSpan(
                  text: ' *',
                  style: Ts.medium12(color: Colors.red),
                ),
              ],
            ),
            const Hbox(8),
            AppTextField(
              controller: controller.pincodeController,
              hintText: '123456',
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              prefixIcon: Icon(
                Icons.pin_drop_outlined,
                color: AppColor.secondary.withValues(alpha: 0.5),
              ),
              maxLength: 6,
            ),
            const Hbox(24),
            Obx(
              () => AppButton(
                text: controller.isSaving.value
                    ? (isEdit ? 'Updating...' : 'Saving...')
                    : (isEdit ? 'Update' : 'Continue'),
                onPressed: controller.isSaving.value ? null : controller.submit,
                horizontalPadding: 16,
                bgColor: AppColor.secondary,
                isFullWidth: true,
                borderRadius: 24,
                useGradient: false,
                height: 56,
              ),
            ),
            const Hbox(24),
            const SizedBox(height: 20),
          ],
        ),
      ),
    ),);
  }
}
