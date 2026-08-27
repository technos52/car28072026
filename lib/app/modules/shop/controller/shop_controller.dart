import 'package:DealMatee/app/routes/app_routes.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/database/database_service.dart';
import '../../../../core/services/remote_service.dart';
import '../../../../core/services/signup_progress_service.dart';
import '../../../../core/services/storage_service.dart';

class ShopController extends GetxController {
  final TextEditingController shopNameController = TextEditingController();
  final TextEditingController ownerNameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController stateController = TextEditingController();
  final TextEditingController pincodeController = TextEditingController();

  final RxBool isSaving = false.obs;
  final RxString logoPath = ''.obs;
  final RxBool isOwnerNamePrefilled = false.obs;
  final RxBool isEmailPrefilled = false.obs;
  final RxBool isPhonePrefilled = false.obs;

  @override
  void onInit() {
    super.onInit();
    // Clear previous data if controller is being reused
    try { shopNameController.clear(); } catch (_) {}
    try { ownerNameController.clear(); } catch (_) {}
    try { phoneController.clear(); } catch (_) {}
    try { emailController.clear(); } catch (_) {}
    try { addressController.clear(); } catch (_) {}
    try { cityController.clear(); } catch (_) {}
    try { stateController.clear(); } catch (_) {}
    try { pincodeController.clear(); } catch (_) {}
    logoPath.value = '';
    isOwnerNamePrefilled.value = false;
    isEmailPrefilled.value = false;
    isPhonePrefilled.value = false;

    shopNameController.addListener(_saveProgress);
    ownerNameController.addListener(_saveProgress);
    phoneController.addListener(_saveProgress);
    emailController.addListener(_saveProgress);
    addressController.addListener(_saveProgress);
    cityController.addListener(_saveProgress);
    stateController.addListener(_saveProgress);
    pincodeController.addListener(_saveProgress);
  }

  bool _isLoadingData = false;

  void loadData() {
    if (!_isLoadingData) {
      _isLoadingData = true;
      // Reset state before loading
      try { shopNameController.clear(); } catch (_) {}
      try { ownerNameController.clear(); } catch (_) {}
      try { phoneController.clear(); } catch (_) {}
      try { emailController.clear(); } catch (_) {}
      try { addressController.clear(); } catch (_) {}
      try { cityController.clear(); } catch (_) {}
      try { stateController.clear(); } catch (_) {}
      try { pincodeController.clear(); } catch (_) {}
      logoPath.value = '';
      isOwnerNamePrefilled.value = false;
      isEmailPrefilled.value = false;
      isPhonePrefilled.value = false;

      _loadSavedData()
          .then((_) {
            _isLoadingData = false;
            print('Shop data loading completed');
          })
          .catchError((error) {
            _isLoadingData = false;
            print('Error loading shop data: $error');
          });
    }
  }

  Future<void> _loadSavedData() async {
    try {
      final dynamic args = Get.arguments;
      final bool isEdit = args is Map && args['from'] == 'edit';

      if (isEdit) {
        print('Loading shop data for edit mode...');
        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          print('User ID: ${user.uid}');
          if (!Get.isRegistered<RemoteService>()) {
            Get.put(RemoteService());
          }
          if (!Get.isRegistered<DatabaseService>()) {
            await Get.putAsync<DatabaseService>(() async => DatabaseService());
          }

          final remoteService = Get.find<RemoteService>();
          final databaseService = Get.find<DatabaseService>();

          print('Fetching shop data from Firestore...');
          final shopData = await remoteService.getUserShop(user.uid);
          print('Shop data fetched: ${shopData != null}');

          if (shopData != null) {
            if (shopData['shopName'] != null)
              shopNameController.text = shopData['shopName'].toString();
            if (shopData['ownerName'] != null)
              ownerNameController.text = shopData['ownerName'].toString();
            if (shopData['phone'] != null)
              phoneController.text = shopData['phone'].toString();
            if (shopData['email'] != null)
              emailController.text = shopData['email'].toString();
            if (shopData['address'] != null)
              addressController.text = shopData['address'].toString();
            if (shopData['city'] != null)
              cityController.text = shopData['city'].toString();
            if (shopData['state'] != null)
              stateController.text = shopData['state'].toString();
            if (shopData['pincode'] != null)
              pincodeController.text = shopData['pincode'].toString();
            if (shopData['logoUrl'] != null)
              logoPath.value = shopData['logoUrl'].toString();
            print('Shop data loaded from Firestore');
          } else {
            print(
              'Shop data not found in Firestore, checking local database...',
            );
            final localShop = await databaseService.getShop(user.uid);
            if (localShop != null) {
              shopNameController.text = localShop.shopName;
              ownerNameController.text = localShop.ownerName;
              phoneController.text = localShop.phone;
              emailController.text = localShop.email;
              addressController.text = localShop.address;
              cityController.text = localShop.city;
              stateController.text = localShop.state;
              pincodeController.text = localShop.pincode;
              print('Shop data loaded from local database');
            } else {
              print('Shop data not found');
            }
          }
          if (user.phoneNumber != null && user.phoneNumber!.isNotEmpty) {
            isPhonePrefilled.value = true;
          }
          if (user.email != null && user.email!.isNotEmpty) {
            isEmailPrefilled.value = true;
          }
        } else {
          print('No user logged in');
        }
      } else {
        final progressService = Get.isRegistered<SignupProgressService>()
            ? Get.find<SignupProgressService>()
            : Get.put(SignupProgressService());
        final savedData = progressService.getShopData();
        if (savedData != null) {
          if (savedData['shopName'] != null)
            shopNameController.text = savedData['shopName'];
          if (savedData['ownerName'] != null)
            ownerNameController.text = savedData['ownerName'];
          if (savedData['phone'] != null)
            phoneController.text = savedData['phone'];
          if (savedData['email'] != null)
            emailController.text = savedData['email'];
          if (savedData['address'] != null)
            addressController.text = savedData['address'];
          if (savedData['city'] != null)
            cityController.text = savedData['city'];
          if (savedData['state'] != null)
            stateController.text = savedData['state'];
          if (savedData['pincode'] != null)
            pincodeController.text = savedData['pincode'];
          if (savedData['logoPath'] != null)
            logoPath.value = savedData['logoPath'];
        }

        if (ownerNameController.text.isEmpty) {
          final profileData = progressService.getProfileData();
          if (profileData != null &&
              profileData['name'] != null &&
              profileData['name'].toString().isNotEmpty) {
            ownerNameController.text = profileData['name'].toString();
            isOwnerNamePrefilled.value = true;
          }
        }

        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          if (ownerNameController.text.isEmpty &&
              user.displayName != null &&
              user.displayName!.isNotEmpty) {
            ownerNameController.text = user.displayName!;
            isOwnerNamePrefilled.value = true;
          }
          if (user.email != null && user.email!.isNotEmpty) {
            if (emailController.text.isEmpty) {
              emailController.text = user.email!;
            }
            isEmailPrefilled.value = true;
          }
          if (user.phoneNumber != null && user.phoneNumber!.isNotEmpty) {
            String phoneDigits = user.phoneNumber!.replaceAll(
              RegExp(r"[^0-9]"),
              "",
            );
            if (phoneDigits.length >= 10) {
              phoneController.text = phoneDigits.substring(
                phoneDigits.length - 10,
              );
            } else if (phoneDigits.isNotEmpty) {
              phoneController.text = phoneDigits;
            }
            isPhonePrefilled.value = true;
          }
        }
      }
    } catch (e) {
      print('Error loading saved shop data: $e');
    }
  }

  void _saveProgress() {
    try {
      final progressService = Get.isRegistered<SignupProgressService>()
          ? Get.find<SignupProgressService>()
          : Get.put(SignupProgressService());
      progressService.setShopData({
        'shopName': shopNameController.text.trim(),
        'ownerName': ownerNameController.text.trim(),
        'phone': phoneController.text.trim(),
        'email': emailController.text.trim(),
        'address': addressController.text.trim(),
        'city': cityController.text.trim(),
        'state': stateController.text.trim(),
        'pincode': pincodeController.text.trim(),
        'logoPath': logoPath.value,
      });
      progressService.setStage(AppRoutes.shop);
    } catch (e) {
      print('Error saving shop progress: $e');
    }
  }

  void submit() async {
    final Map<String, dynamic>? arguments =
        Get.arguments as Map<String, dynamic>?;
    final bool isOnboarding = (arguments?['onboarding'] == true);

    // Always require logo
    if (logoPath.value.isEmpty) {
      Get.snackbar(
        'Error',
        'Please upload a shop logo',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }
    if (shopNameController.text.trim().isEmpty) {
      Get.snackbar(
        'Error',
        'Please enter shop name',
        snackPosition: SnackPosition.TOP,
      );
      return;
    }
    if (ownerNameController.text.trim().isEmpty) {
      Get.snackbar(
        'Error',
        'Please enter owner name',
        snackPosition: SnackPosition.TOP,
      );
      return;
    }
    final String phoneDigits = phoneController.text.replaceAll(
      RegExp(r"[^0-9]"),
      "",
    );
    if (phoneDigits.length != 10) {
      Get.snackbar(
        'Error',
        'Enter a valid 10-digit phone number',
        snackPosition: SnackPosition.TOP,
      );
      return;
    }
    final String email = emailController.text.trim();
    final RegExp emailRegex = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
    if (email.isEmpty) {
      Get.snackbar(
        'Error',
        'Please enter email address',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }
    if (!emailRegex.hasMatch(email)) {
      Get.snackbar(
        'Error',
        'Enter a valid email address',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }
    if (addressController.text.trim().isEmpty) {
      Get.snackbar(
        'Error',
        'Please enter shop address',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }
    if (cityController.text.trim().isEmpty) {
      Get.snackbar(
        'Error',
        'Please enter city',
        snackPosition: SnackPosition.TOP,
      );
      return;
    }
    if (stateController.text.trim().isEmpty) {
      Get.snackbar(
        'Error',
        'Please enter state',
        snackPosition: SnackPosition.TOP,
      );
      return;
    }
    if (pincodeController.text.trim().isEmpty) {
      Get.snackbar(
        'Error',
        'Please enter pincode',
        snackPosition: SnackPosition.TOP,
      );
      return;
    }
    if (!RegExp(r'^\d{6}$').hasMatch(pincodeController.text.trim())) {
      Get.snackbar(
        'Error',
        'Please enter a valid 6-digit pincode',
        snackPosition: SnackPosition.TOP,
      );
      return;
    }

    isSaving.value = true;
    try {
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

        // Upload shop image if selected
        String? shopImageUrl;
        if (logoPath.value.isNotEmpty) {
          try {
            // Ensure StorageService is registered
            if (!Get.isRegistered<StorageService>()) {
              Get.put(StorageService());
            }
            final storageService = Get.find<StorageService>();
            shopImageUrl = await storageService.uploadShopImage(
              user.uid,
              logoPath.value,
            );
            print('Shop image uploaded: $shopImageUrl');
          } catch (e) {
            print('Error uploading shop image: $e');
            // Continue without image if upload fails
          }
        }

        if (!await remoteService.userExists(user.uid)) {
          await remoteService.saveUser(
            id: user.uid,
            name: user.displayName ?? '',
            email: user.email ?? '',
            phone: phoneDigits,
            gender: '',
          );
        }

        await databaseService.saveShop(
          id: '${user.uid}_shop',
          userId: user.uid,
          shopName: shopNameController.text.trim(),
          ownerName: ownerNameController.text.trim(),
          phone: phoneDigits,
          email: emailController.text.trim(),
          address: addressController.text.trim(),
          city: cityController.text.trim(),
          state: stateController.text.trim(),
          pincode: pincodeController.text.trim(),
          logoUrl: shopImageUrl, // Use uploaded image URL
        );
        await remoteService
            .saveShop(
              id: '${user.uid}_shop',
              userId: user.uid,
              shopName: shopNameController.text.trim(),
              ownerName: ownerNameController.text.trim(),
              phone: phoneDigits,
              email: emailController.text.trim(),
              address: addressController.text.trim(),
              city: cityController.text.trim(),
              state: stateController.text.trim(),
              pincode: pincodeController.text.trim(),
              logoUrl: shopImageUrl, // Use uploaded image URL
            )
            .timeout(const Duration(seconds: 12));

        final Map<String, dynamic>? arguments =
            Get.arguments as Map<String, dynamic>?;
        final bool isOnboarding = (arguments?['onboarding'] == true);
        if (isOnboarding) {
          final progressService = Get.isRegistered<SignupProgressService>()
              ? Get.find<SignupProgressService>()
              : Get.put(SignupProgressService());
          progressService.setStage(AppRoutes.verification);
          Get.offNamed(AppRoutes.verification, arguments: {'onboarding': true});
        } else {
          // Show success message
          Get.snackbar(
            'Success',
            'Shop details updated successfully',
            snackPosition: SnackPosition.TOP,
            backgroundColor: Colors.green,
            colorText: Colors.white,
            duration: const Duration(seconds: 2),
          );

          // Navigate to profile page after successful update
          Get.offAllNamed(AppRoutes.root, arguments: {'initialIndex': 4});
        }
        isSaving.value = false;
      } else {
        throw Exception('User not authenticated');
      }
    } on TimeoutException {
      isSaving.value = false;
      Get.snackbar(
        'Network timeout',
        'Saving took too long. Please check your connection and try again.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } catch (e) {
      isSaving.value = false;
      String errorMessage = e.toString().replaceAll('Exception: ', '').trim();
      Get.snackbar(
        'Error',
        errorMessage,
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> pickLogoFromCamera() async {
    final ImagePicker picker = ImagePicker();
    final XFile? file = await picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 85,
    );
    if (file != null) {
      logoPath.value = file.path;
      _saveProgress();
    }
  }

  Future<void> pickLogoFromGallery() async {
    final ImagePicker picker = ImagePicker();
    final XFile? file = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (file != null) {
      logoPath.value = file.path;
      _saveProgress();
    }
  }

  @override
  void onClose() {
    try { shopNameController.dispose(); } catch (_) {}
    try { ownerNameController.dispose(); } catch (_) {}
    try { phoneController.dispose(); } catch (_) {}
    try { emailController.dispose(); } catch (_) {}
    try { addressController.dispose(); } catch (_) {}
    try { cityController.dispose(); } catch (_) {}
    try { stateController.dispose(); } catch (_) {}
    try { pincodeController.dispose(); } catch (_) {}
    super.onClose();
  }
}
