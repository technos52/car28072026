import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:get_storage/get_storage.dart';
import '../../../../core/database/database_service.dart';
import '../../../../core/services/remote_service.dart';
import '../../../services/auth_service.dart';
import '../../../routes/app_routes.dart';

class ProfileMenuController extends GetxController {
  final RxList<dynamic> userCars = <dynamic>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool areDocumentsUploaded = false.obs;
  final RxBool isDocumentVerified = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadUserCars();
    checkDocumentVerificationStatus();
  }

  Future<void> checkDocumentVerificationStatus() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        areDocumentsUploaded.value = false;
        isDocumentVerified.value = false;
        return;
      }

      if (!Get.isRegistered<RemoteService>()) {
        Get.put(RemoteService());
      }
      final remoteService = Get.find<RemoteService>();

      // Try fetching from remote first
      Map<String, dynamic>? remoteKycDoc;
      try {
        remoteKycDoc = await remoteService.getKycDocument(user.uid);
      } catch (e) {
        print(
          'Error fetching remote KYC document in ProfileMenuController: $e',
        );
      }

      if (remoteKycDoc != null) {
        final panPath = remoteKycDoc['panPath']?.toString() ?? '';
        final aadhaarPath = remoteKycDoc['aadhaarPath']?.toString() ?? '';
        final addressProofPath =
            remoteKycDoc['addressProofPath']?.toString() ?? '';

        final allDocsUploaded =
            panPath.isNotEmpty &&
            panPath.startsWith('http') &&
            aadhaarPath.isNotEmpty &&
            aadhaarPath.startsWith('http') &&
            addressProofPath.isNotEmpty &&
            addressProofPath.startsWith('http');

        areDocumentsUploaded.value = allDocsUploaded;
        isDocumentVerified.value =
            allDocsUploaded && (remoteKycDoc['isVerified'] == true);

        // Sync to local database silently
        if (!Get.isRegistered<DatabaseService>()) {
          await Get.putAsync<DatabaseService>(() async => DatabaseService());
        }
        try {
          final databaseService = Get.find<DatabaseService>();
          await databaseService.saveKycDocument(
            id: user.uid,
            userId: user.uid,
            panPath: panPath,
            aadhaarPath: aadhaarPath,
            addressProofPath: addressProofPath,
            isVerified: remoteKycDoc['isVerified'] == true,
          );
        } catch (e) {
          print('Error syncing KYC to local DB: $e');
        }
        return;
      }

      // Fallback to local database if remote fails or is null
      if (!Get.isRegistered<DatabaseService>()) {
        await Get.putAsync<DatabaseService>(() async => DatabaseService());
      }
      final databaseService = Get.find<DatabaseService>();
      final kycDoc = await databaseService.getKycDocument(user.uid);

      if (kycDoc != null) {
        final allDocsUploaded =
            kycDoc.panPath != null &&
            kycDoc.panPath!.isNotEmpty &&
            kycDoc.aadhaarPath != null &&
            kycDoc.aadhaarPath!.isNotEmpty &&
            kycDoc.addressProofPath != null &&
            kycDoc.addressProofPath!.isNotEmpty;
        areDocumentsUploaded.value = allDocsUploaded;
        isDocumentVerified.value = allDocsUploaded && kycDoc.isVerified;
      } else {
        areDocumentsUploaded.value = false;
        isDocumentVerified.value = false;
      }
    } catch (e) {
      print('Error checking document verification status: $e');
      areDocumentsUploaded.value = false;
      isDocumentVerified.value = false;
    }
  }

  Future<void> loadUserCars() async {
    try {
      isLoading.value = true;
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        if (!Get.isRegistered<DatabaseService>()) {
          await Get.putAsync<DatabaseService>(() async => DatabaseService());
        }
        if (!Get.isRegistered<RemoteService>()) {
          Get.put(RemoteService());
        }
        final databaseService = Get.find<DatabaseService>();
        final remoteService = Get.find<RemoteService>();

        // Load from Firestore first, then sync to local DB
        try {
          final firestoreCars = await remoteService.getUserCars(user.uid);
          for (var carData in firestoreCars) {
            // Handle imageUrls array or single imageUrl
            String? imageUrlToSave;
            if (carData['imageUrls'] != null && carData['imageUrls'] is List) {
              // Convert array to JSON string for local DB
              final imageUrls = carData['imageUrls'] as List;
              imageUrlToSave = jsonEncode(imageUrls);
            } else if (carData['imageUrl'] != null) {
              imageUrlToSave = carData['imageUrl'] as String;
            }

            await databaseService.saveCar(
              id: carData['id'] as String,
              userId: user.uid,
              make: carData['make'] as String? ?? '',
              model: carData['model'] as String? ?? '',
              year: carData['year'] as String? ?? '',
              price: carData['price'] as String? ?? '',
              imageUrl: imageUrlToSave,
              description: carData['description'] as String?,
              isAvailable: carData['isAvailable'] as bool? ?? true,
            );
          }
        } catch (e) {
          print('Error loading from Firestore: $e');
        }

        final cars = await databaseService.getUserCars(user.uid);
        userCars.assignAll(cars);
      }
    } catch (e) {
      print('Error loading user cars: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshCars() async {
    await loadUserCars();
  }

  Future<void> refreshUserData() async {
    // This method can be called to refresh user data when profile is updated
    await checkDocumentVerificationStatus();
  }

  Future<void> deleteAccount() async {
    try {
      isLoading.value = true;
      Get.snackbar('Processing', 'Permanently deleting your account...', 
          showProgressIndicator: true, snackPosition: SnackPosition.TOP);
      
      // 1. Delete remote data via AuthService (includes Firebase Auth user deletion)
      final authService = Get.find<AuthService>();
      await authService.deleteAccount();
      
      // 2. Clear local database
      if (Get.isRegistered<DatabaseService>()) {
        final databaseService = Get.find<DatabaseService>();
        await databaseService.clearAllData();
      }
      
      // 3. Clear persistent storage
      try {
        await GetStorage().erase();
      } catch (_) {}
      
      // 4. Success message and redirect
      Get.snackbar(
        'Success',
        'Your account has been deleted.',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      // Give a tiny moment for user to see success before redirecting
      await Future.delayed(const Duration(milliseconds: 1500));
      
      Get.offAllNamed(AppRoutes.auth);
    } catch (e) {
      print('Account deletion failed: $e');
      Get.snackbar(
        'Action Required',
        e.toString().replaceAll('Exception: ', ''),
        backgroundColor: Colors.orange,
        colorText: Colors.white,
        duration: const Duration(seconds: 5),
      );
    } finally {
      isLoading.value = false;
    }
  }
}
