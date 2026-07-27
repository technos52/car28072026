import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:dotted_border/dotted_border.dart';
import '../../../core/constants/app_color.dart';
import '../../../core/utils/ts.dart';
import '../../../core/utils/app_text.dart';
import '../../../core/utils/app_button.dart';
import '../../../core/utils/size.dart';
import 'controller/cars_controller.dart';
import '../../routes/app_routes.dart';
import '../../../core/utils/success_dialog.dart';
import '../../../core/services/signup_progress_service.dart';
import '../../../core/database/database_service.dart';
import '../../../core/services/remote_service.dart';

class CarsView extends GetView<CarsController> {
  const CarsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        automaticallyImplyLeading: true,
        title: Row(
          children: [
            AppText('Car', style: Ts.semiBold20(color: AppColor.secondary)),
            const Spacer(),
            TextButton(
              onPressed: () {
                final progressService =
                    Get.isRegistered<SignupProgressService>()
                    ? Get.find<SignupProgressService>()
                    : Get.put(SignupProgressService());
                progressService.clearProgress();
                Get.offAllNamed(AppRoutes.root);
              },
              child: AppText(
                'skip',
                style: Ts.semiBold12(color: AppColor.gray600),
              ),
            ),
          ],
        ),
        centerTitle: false,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          children: [
            Row(
              children: [
                const Icon(Icons.filter_list, color: AppColor.textcolor),
                const Wbox(6),
                AppText(
                  'Filter',
                  style: Ts.regular12(color: AppColor.textcolor),
                ),
              ],
            ),
            const Hbox(12),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.9,
                children: [
                  _carCard(
                    'KIA EV6',
                    'OWNER: SURESH',
                    'Price: ₹1 Lakh to 12 Lakh',
                    'https://media.istockphoto.com/id/2217188783/photo/suv-in-the-desert.webp?a=1&b=1&s=612x612&w=0&k=20&c=41f-oD8WE62iIC8JgIXotG8WvvOcjXuFTQq_yAPJgd8=',
                  ),
                  _addCard(),
                ],
              ),
            ),
            AppButton(
              text: 'Continue',
              onPressed: () {
                final Map<String, dynamic>? args =
                    Get.arguments as Map<String, dynamic>?;
                final bool isOnboarding = (args?['onboarding'] == true);
                SuccessDialog.showVerificationSuccess(
                  title: 'Congratulations! 🎉',
                  message:
                      'Thank you! Your registration has been successfully submitted',
                  onContinue: () {
                    Get.back();
                    if (isOnboarding) {
                      final progressService =
                          Get.isRegistered<SignupProgressService>()
                          ? Get.find<SignupProgressService>()
                          : Get.put(SignupProgressService());
                      progressService.clearProgress();
                      Get.offAllNamed(AppRoutes.root);
                    } else {
                      Get.toNamed(AppRoutes.home);
                    }
                  },
                );
              },
              bgColor: AppColor.secondary,
              elevation: 0,
              useGradient: false,
              isFullWidth: true,
              borderRadius: 24,
              height: 52,
            ),
            const Hbox(20),
          ],
        ),
      ),
    );
  }

  Widget _carCard(String title, String owner, String price, String imageUrl) {
    return GestureDetector(
      onTap: () => Get.toNamed(AppRoutes.carDetail),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFB7CAE6)),
        ),
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Hbox(10),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: Image.network(imageUrl, fit: BoxFit.cover),
              ),
            ),
            const Spacer(),
            AppText(title, style: Ts.semiBold12(color: AppColor.textcolor)),
            const Hbox(4),
            AppText(owner, style: Ts.regular10(color: AppColor.textcolor)),
            const Hbox(4),
            AppText(price, style: Ts.regular10(color: AppColor.gray600)),
          ],
        ),
      ),
    );
  }

  Widget _addCard() {
    return GestureDetector(
      onTap: () async {
        try {
          final user = FirebaseAuth.instance.currentUser;
          if (user == null) {
            Get.snackbar(
              'Error',
              'Please log in to add a car',
              snackPosition: SnackPosition.TOP,
              backgroundColor: Colors.red,
              colorText: Colors.white,
            );
            return;
          }

          try {
            if (!Get.isRegistered<DatabaseService>()) {
              await Get.putAsync<DatabaseService>(() async {
                final service = DatabaseService();
                await service.onInit();
                return service;
              });
            }
          } catch (e) {
            print('Error initializing DatabaseService: $e');
          }

          try {
            if (!Get.isRegistered<RemoteService>()) {
              Get.put(RemoteService());
            }
          } catch (e) {
            print('Error initializing RemoteService: $e');
          }

          RemoteService? remoteService;
          try {
            remoteService = Get.find<RemoteService>();
          } catch (e) {
            print('Error finding RemoteService: $e');
            Get.put(RemoteService());
            remoteService = Get.find<RemoteService>();
          }

          Map<String, dynamic>? remoteKycDoc;
          try {
            remoteKycDoc = await remoteService.getKycDocument(user.uid);
          } catch (e) {
            print('Error fetching KYC document from Firestore: $e');
          }

          bool allDocsUploaded = false;
          bool isVerified = false;

          if (remoteKycDoc != null) {
            final panPath = remoteKycDoc['panPath']?.toString() ?? '';
            final aadhaarPath = remoteKycDoc['aadhaarPath']?.toString() ?? '';
            final addressProofPath = remoteKycDoc['addressProofPath']?.toString() ?? '';
            
            allDocsUploaded = panPath.isNotEmpty &&
                panPath.startsWith('http') &&
                aadhaarPath.isNotEmpty &&
                aadhaarPath.startsWith('http') &&
                addressProofPath.isNotEmpty &&
                addressProofPath.startsWith('http');
            isVerified = remoteKycDoc['isVerified'] == true;
          } else {
            try {
              final databaseService = Get.find<DatabaseService>();
              final kycDoc = await databaseService.getKycDocument(user.uid);
              
              if (kycDoc != null) {
                final panPath = kycDoc.panPath ?? '';
                final aadhaarPath = kycDoc.aadhaarPath ?? '';
                final addressProofPath = kycDoc.addressProofPath ?? '';
                
                allDocsUploaded = panPath.isNotEmpty &&
                    panPath.startsWith('http') &&
                    aadhaarPath.isNotEmpty &&
                    aadhaarPath.startsWith('http') &&
                    addressProofPath.isNotEmpty &&
                    addressProofPath.startsWith('http');
                isVerified = kycDoc.isVerified;
              }
            } catch (e) {
              print('Error fetching KYC document from local database: $e');
            }
          }

          if (!allDocsUploaded) {
            Get.snackbar(
              'Documents Required',
              'Please upload all documents first',
              snackPosition: SnackPosition.TOP,
              backgroundColor: Colors.orange,
              colorText: Colors.white,
            );
            Get.toNamed(AppRoutes.verificationDocs, arguments: {'onboarding': false});
            return;
          }

          if (!isVerified) {
            Get.snackbar(
              'Verification Pending',
              'Your docs are submitted. You will be able to add car details once your docs is approved by admin',
              snackPosition: SnackPosition.TOP,
              backgroundColor: Colors.orange,
              colorText: Colors.white,
              duration: const Duration(seconds: 4),
            );
            return;
          }

          Get.toNamed(AppRoutes.addCar);
        } catch (e, stackTrace) {
          print('Error in _addCard onTap: $e');
          print('Stack trace: $stackTrace');
          Get.snackbar(
            'Error',
            'Something went wrong. Please try again.',
            snackPosition: SnackPosition.TOP,
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
        }
      },
      child: DottedBorder(
        color: const Color(0xFFB7CAE6),
        strokeWidth: 1.5,
        borderType: BorderType.RRect,
        radius: const Radius.circular(14),
        dashPattern: const [6, 4],
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                height: 54,
                width: 54,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFB7CAE6)),
                ),
                child: const Icon(Icons.add, color: Color(0xFFB7CAE6)),
              ),
              const Hbox(8),
              AppText(
                'Upload Your car details',
                style: Ts.regular10(color: AppColor.gray600),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
