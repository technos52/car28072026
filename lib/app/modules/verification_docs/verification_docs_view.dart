import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_color.dart';
import '../../../core/utils/ts.dart';
import '../../../core/utils/app_text.dart';
import '../../../core/utils/app_button.dart';
import '../../../core/utils/size.dart';
import '../../../core/utils/success_dialog.dart';
import '../../routes/app_routes.dart';
import '../../../core/services/signup_progress_service.dart';
import 'controller/verification_docs_controller.dart';

class VerificationDocsView extends GetView<VerificationDocsController> {
  const VerificationDocsView({super.key});

  String _fileName(String path) {
    if (path.isEmpty) return '';
    final parts = path.split(RegExp(r'[\\/]'));
    return parts.isNotEmpty ? parts.last : path;
  }

  void _showUploadSheet(String type) {
    final VerificationDocsController ctrl =
        Get.find<VerificationDocsController>();
    Get.bottomSheet(
      SafeArea(
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppText(
                'Upload Document',
                style: Ts.semiBold16(color: AppColor.textcolor),
              ),
              if (type == 'address') ...[
                const Hbox(12),
                AppText(
                  'Address Proof Type',
                  style: Ts.medium12(color: AppColor.secondary),
                ),
                const Hbox(6),
                Container(
                  decoration: BoxDecoration(
                    color: AppColor.gray100,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColor.gray300, width: 1),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  child: Obx(
                    () => DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: ctrl.selectedAddressProof.value,
                        isExpanded: true,
                        icon: const Icon(
                          Icons.keyboard_arrow_down_rounded,
                          color: AppColor.secondary,
                        ),
                        dropdownColor: AppColor.white,
                        style: Ts.regular16(color: AppColor.textcolor),
                        items: ctrl.addressProofOptions
                            .map(
                              (String option) => DropdownMenuItem<String>(
                                value: option,
                                child: Text(
                                  option,
                                  style: Ts.regular16(
                                    color: AppColor.textcolor,
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                        onChanged: (String? v) {
                          if (v != null) {
                            ctrl.selectedAddressProof.value = v;
                          }
                        },
                      ),
                    ),
                  ),
                ),
              ],
              const Hbox(12),
              Obx(() {
                String fileName = '';
                if (type == 'pan') fileName = _fileName(ctrl.panPath.value);
                if (type == 'aadhaar')
                  fileName = _fileName(ctrl.aadhaarPath.value);
                if (type == 'address')
                  fileName = _fileName(ctrl.addressPath.value);
                return InkWell(
                  onTap: () async {
                    Navigator.pop(
                      Get.context!,
                    ); // Use Navigator.pop instead of Get.back()
                    await Future.delayed(
                      const Duration(milliseconds: 100),
                    ); // Small delay
                    if (type == 'pan') await ctrl.pickPan();
                    if (type == 'aadhaar') await ctrl.pickAadhaar();
                    if (type == 'address') await ctrl.pickAddressProof();
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColor.gray300,
                        width: 1,
                        strokeAlign: BorderSide.strokeAlignInside,
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.insert_drive_file_outlined,
                          color: AppColor.gray600,
                        ),
                        const Wbox(8),
                        Expanded(
                          child: AppText(
                            fileName.isEmpty ? 'Tap to choose file' : fileName,
                            style: Ts.regular14(color: AppColor.textcolor),
                          ),
                        ),
                        const Icon(
                          Icons.upload_file_rounded,
                          color: AppColor.gray600,
                        ),
                      ],
                    ),
                  ),
                );
              }),
              const Hbox(8),
              Row(
                children: [
                  const Icon(
                    Icons.info_outline,
                    size: 16,
                    color: AppColor.gray500,
                  ),
                  const Wbox(6),
                  Expanded(
                    child: AppText(
                      'Only PDF file is supported',
                      style: Ts.regular10(color: AppColor.gray500),
                    ),
                  ),
                ],
              ),
              Obx(() {
                final bool hasFile = type == 'pan'
                    ? ctrl.panPath.value.isNotEmpty
                    : type == 'aadhaar'
                    ? ctrl.aadhaarPath.value.isNotEmpty
                    : ctrl.addressPath.value.isNotEmpty;
                if (hasFile) {
                  return Column(
                    children: [
                      const Hbox(16),
                      AppButton(
                        text: 'Remove Document',
                        onPressed: () async {
                          Navigator.pop(
                            Get.context!,
                          ); // Use Navigator.pop instead of Get.back()
                          await Future.delayed(
                            const Duration(milliseconds: 100),
                          ); // Small delay
                          try {
                            await ctrl.removeDocument(type);
                            Get.snackbar(
                              'Success',
                              'Document removed successfully',
                              snackPosition: SnackPosition.TOP,
                              backgroundColor: Colors.green,
                              colorText: Colors.white,
                              duration: const Duration(seconds: 2),
                            );
                          } catch (e) {
                            print('Error in remove document: $e');
                          }
                        },
                        bgColor: Colors.red,
                        elevation: 0,
                        useGradient: false,
                        isFullWidth: true,
                        borderRadius: 24,
                        height: 52,
                      ),
                    ],
                  );
                }
                return const SizedBox.shrink();
              }),
              const Hbox(8),
              Center(
                child: TextButton(
                  onPressed: () => Get.back(),
                  child: AppText(
                    'Cancel',
                    style: Ts.semiBold14(color: AppColor.gray600),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
    );
  }

  Widget _uploadCard({
    required String label,
    required String fileName,
    required VoidCallback onTap,
    bool isUploading = false,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: fileName.isEmpty ? AppColor.gray100 : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: fileName.isEmpty ? AppColor.gray300 : AppColor.secondary,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            if (isUploading)
              SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColor.secondary),
                ),
              )
            else
              Icon(
                fileName.isEmpty
                    ? Icons.add_circle_outline
                    : Icons.check_circle,
                color: fileName.isEmpty ? AppColor.gray600 : Colors.green,
                size: 24,
              ),
            const Wbox(12),
            Expanded(
              child: AppText(
                label,
                style: Ts.medium14(color: AppColor.secondary),
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: AppColor.gray400),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        automaticallyImplyLeading: true,
        title: AppText(
          'Document Verification',
          style: Ts.semiBold16(color: AppColor.secondary),
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Hbox(16),
            AppText(
              'ID verification',
              style: Ts.semiBold14(color: AppColor.textcolor),
            ),
            const Hbox(4),
            AppText(
              'select the documents type below to confirm your\nidentity',
              style: Ts.regular12(color: AppColor.gray500),
            ),
            const Hbox(16),
            Obx(
              () => _uploadCard(
                label: 'PAN Card',
                fileName: controller.panPath.value,
                onTap: () => _showUploadSheet('pan'),
                isUploading: controller.isUploadingPan.value,
              ),
            ),
            const Hbox(12),
            Obx(
              () => _uploadCard(
                label: 'Aadhaar Card',
                fileName: controller.aadhaarPath.value,
                onTap: () => _showUploadSheet('aadhaar'),
                isUploading: controller.isUploadingAadhaar.value,
              ),
            ),
            const Hbox(12),
            Obx(
              () => _uploadCard(
                label: 'Address Proof',
                fileName: controller.addressPath.value,
                onTap: () => _showUploadSheet('address'),
                isUploading: controller.isUploadingAddress.value,
              ),
            ),
            const Hbox(24),
            Obx(() {
              final bool allUploaded = controller.areAllDocumentsUploaded;
              return AppButton(
                text: 'Continue',
                onPressed: allUploaded
                    ? () {
                        controller.markUploadCompleted();
                        SuccessDialog.showVerificationSuccess(
                          onContinue: () {
                            final progressService =
                                Get.isRegistered<SignupProgressService>()
                                ? Get.find<SignupProgressService>()
                                : Get.put(SignupProgressService());
                            progressService.clearProgress();
                            Get.offAllNamed(AppRoutes.root);
                          },
                        );
                      }
                    : () {
                        Get.snackbar(
                          'Error',
                          'Please upload all required documents (PAN Card, Aadhaar Card, and Address Proof)',
                          snackPosition: SnackPosition.TOP,
                          backgroundColor: Colors.red,
                          colorText: Colors.white,
                        );
                      },
                bgColor: allUploaded ? AppColor.secondary : AppColor.gray400,
                elevation: 0,
                useGradient: false,
                isFullWidth: true,
                borderRadius: 24,
                height: 52,
              );
            }),
            const Hbox(20),
          ],
        ),
      ),
    );
  }
}
