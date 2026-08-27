import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:DealMatee/app/routes/app_routes.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import '../../../../core/constants/firebase_config.dart';
import '../../../../core/database/database_service.dart';
import '../../../../core/services/remote_service.dart';
import '../../../../core/services/storage_service.dart';
import '../../../../core/services/signup_progress_service.dart';
import '../../home/home_controller.dart';
import 'profile_menu_controller.dart';

class ProfileController extends GetxController {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  // extra fields
  final TextEditingController addressController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController stateController = TextEditingController();
  final TextEditingController pinCodeController = TextEditingController();

  // gender dropdown
  final RxString selectedGender = ''.obs;
  final List<String> genders = <String>['Male', 'Female', 'Other'];

  final RxBool isSaving = false.obs;
  final RxString avatarPath = ''.obs;
  final RxBool isEmailPrefilled = false.obs;
  final RxBool isPhonePrefilled = false.obs;

  @override
  void onInit() {
    super.onInit();
    // Clear previous data if controller is being reused
    try { nameController.clear(); } catch (_) {}
    try { emailController.clear(); } catch (_) {}
    try { phoneController.clear(); } catch (_) {}
    avatarPath.value = '';
    selectedGender.value = 'Male';
    isEmailPrefilled.value = false;
    isPhonePrefilled.value = false;

    nameController.addListener(_saveProgress);
    emailController.addListener(_saveProgress);
    phoneController.addListener(_saveProgress);
  }

  bool _isLoadingData = false;

  void loadData() {
    if (!_isLoadingData) {
      _isLoadingData = true;
      // Reset state before loading
      try { nameController.clear(); } catch (_) {}
      try { emailController.clear(); } catch (_) {}
      try { phoneController.clear(); } catch (_) {}
      avatarPath.value = '';
      selectedGender.value = 'Male';
      isEmailPrefilled.value = false;
      isPhonePrefilled.value = false;

      _loadSavedData()
          .then((_) {
            _isLoadingData = false;
            print('Profile data loading completed');
          })
          .catchError((error) {
            _isLoadingData = false;
            print('Error loading profile data: $error');
          });
    }
  }

  Future<void> _loadSavedData() async {
    try {
      final dynamic args = Get.arguments;
      final bool isEdit = args is Map && args['from'] == 'edit';

      print('Loading profile data, isEdit: $isEdit');

      if (isEdit) {
        print('Loading user data for edit mode...');
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

          print('Fetching user data from Firestore...');
          final userData = await remoteService.getUser(user.uid);
          print('User data fetched: ${userData != null}');

          if (userData != null) {
            if (userData['name'] != null)
              nameController.text = userData['name'].toString();
            if (userData['email'] != null)
              emailController.text = userData['email'].toString();
            if (userData['phone'] != null)
              phoneController.text = userData['phone'].toString();
            if (userData['gender'] != null)
              selectedGender.value = userData['gender'].toString();
            if (userData['avatarUrl'] != null)
              avatarPath.value = userData['avatarUrl'].toString();
            print('Profile data loaded from Firestore');
          } else {
            print(
              'User data not found in Firestore, checking local database...',
            );
            final localUser = await databaseService.getUser(user.uid);
            if (localUser != null) {
              nameController.text = localUser.name;
              emailController.text = localUser.email;
              phoneController.text = localUser.phone;
              selectedGender.value = localUser.gender;
              if (localUser.avatarUrl != null)
                avatarPath.value = localUser.avatarUrl!;
              print('Profile data loaded from local database');
            } else {
              nameController.text = user.displayName ?? '';
              emailController.text = user.email ?? '';
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
        final savedData = progressService.getProfileData();
        if (savedData != null) {
          if (savedData['name'] != null)
            nameController.text = savedData['name'];
          if (savedData['email'] != null)
            emailController.text = savedData['email'];
          if (savedData['phone'] != null)
            phoneController.text = savedData['phone'];
          if (savedData['gender'] != null)
            selectedGender.value = savedData['gender'];
          if (savedData['avatarPath'] != null)
            avatarPath.value = savedData['avatarPath'];
        }

      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
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
      print('Error loading saved profile data: $e');
    }
  }

  void _saveProgress() {
    try {
      final progressService = Get.isRegistered<SignupProgressService>()
          ? Get.find<SignupProgressService>()
          : Get.put(SignupProgressService());
      progressService.setProfileData({
        'name': nameController.text.trim(),
        'email': emailController.text.trim(),
        'phone': phoneController.text.trim(),
        'gender': selectedGender.value,
        'avatarPath': avatarPath.value,
      });
      progressService.setStage(AppRoutes.profile);
    } catch (e) {
      print('Error saving profile progress: $e');
    }
  }

  void submit() async {
    final Map<String, dynamic>? arguments =
        Get.arguments as Map<String, dynamic>?;
    final bool isOnboarding = (arguments?['onboarding'] == true);

    // Require avatar for both onboarding and editing
    if (avatarPath.value.isEmpty) {
      Get.snackbar(
        'Error',
        'Please upload a profile image',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }
    if (nameController.text.trim().isEmpty) {
      Get.snackbar(
        'Error',
        'Please enter your name',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }
    final String digits = phoneController.text.replaceAll(
      RegExp(r"[^0-9]"),
      "",
    );
    if (digits.length != 10) {
      Get.snackbar(
        'Error',
        'Enter a valid 10-digit phone number',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    // Prevent duplicate accounts by checking phone number uniqueness in Firestore
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      final db = FirebaseConfig.firestoreDatabaseId != null
          ? FirebaseFirestore.instanceFor(
              app: Firebase.app(),
              databaseId: FirebaseConfig.firestoreDatabaseId!,
            )
          : FirebaseFirestore.instance;
      try {
        final querySnap = await db
            .collection('users')
            .where('phone', isEqualTo: digits)
            .get();
        if (querySnap.docs.isNotEmpty && querySnap.docs.first.id != currentUser.uid) {
          Get.snackbar(
            'Error',
            'This phone number is already registered with another account.',
            snackPosition: SnackPosition.TOP,
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
          return;
        }
      } catch (e) {
        print('Error checking phone uniqueness: $e');
      }
    }
    final String email = emailController.text.trim();
    final RegExp emailRegex = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
    if (email.isEmpty) {
      Get.snackbar(
        'Error',
        'Please enter your email address',
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
    if (selectedGender.value.isEmpty) {
      Get.snackbar(
        'Error',
        'Please select your gender',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
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
        // Ensure StorageService is registered
        if (!Get.isRegistered<StorageService>()) {
          Get.put(StorageService());
        }
        final storageService = Get.find<StorageService>();

        String avatarUrlToSave = avatarPath.value;
        final bool isLocalImage =
            avatarPath.value.isNotEmpty &&
            !avatarPath.value.startsWith('http://') &&
            !avatarPath.value.startsWith('https://');

        final Map<String, dynamic>? arguments =
            Get.arguments as Map<String, dynamic>?;
        final bool isOnboarding = (arguments?['onboarding'] == true);

        if (!isOnboarding) {
          if (avatarUrlToSave.isEmpty) {
            try {
              final existingUserData = await remoteService.getUser(user.uid);
              if (existingUserData != null &&
                  existingUserData['avatarUrl'] != null) {
                final existingAvatar = existingUserData['avatarUrl'].toString();
                if (existingAvatar.isNotEmpty) {
                  avatarUrlToSave = existingAvatar;
                }
              }
            } catch (e) {
              print('Error checking existing avatar: $e');
            }
          }
        }

        await databaseService.saveUser(
          id: user.uid,
          name: nameController.text.trim(),
          email: email,
          phone: digits,
          gender: selectedGender.value,
          avatarUrl: isLocalImage ? '' : avatarUrlToSave,
        );

        if (isOnboarding) {
          final progressService = Get.isRegistered<SignupProgressService>()
              ? Get.find<SignupProgressService>()
              : Get.put(SignupProgressService());
          progressService.setStage(AppRoutes.shop);
          Get.offNamed(AppRoutes.shop, arguments: {'onboarding': true});
          isSaving.value = false;

          if (isLocalImage) {
            final localImagePath = avatarPath.value;
            storageService
                .uploadProfileImage(user.uid, localImagePath)
                .then((uploadedUrl) {
                  databaseService
                      .saveUser(
                        id: user.uid,
                        name: nameController.text.trim(),
                        email: email,
                        phone: digits,
                        gender: selectedGender.value,
                        avatarUrl: uploadedUrl,
                      )
                      .catchError((e) {
                        print(
                          'Error updating local database with uploaded avatar: $e',
                        );
                      });

                  remoteService
                      .saveUser(
                        id: user.uid,
                        name: nameController.text.trim(),
                        email: email,
                        phone: digits,
                        gender: selectedGender.value,
                        avatarUrl: uploadedUrl,
                      )
                      .catchError((e) {
                        print('Error saving user to Firestore: $e');
                      });
                })
                .catchError((e) {
                  print('Error uploading profile image: $e');
                });
          } else {
            remoteService
                .saveUser(
                  id: user.uid,
                  name: nameController.text.trim(),
                  email: email,
                  phone: digits,
                  gender: selectedGender.value,
                  avatarUrl: avatarUrlToSave,
                )
                .catchError((e) {
                  print('Error saving user to Firestore: $e');
                });
          }

          user.updateDisplayName(nameController.text.trim()).catchError((e) {
            print('Error updating display name: $e');
          });
        } else {
          // Handle image upload if it's a local file (newly picked image)
          if (isLocalImage && avatarPath.value.isNotEmpty) {
            try {
              final uploadedUrl = await storageService.uploadProfileImage(
                user.uid,
                avatarPath.value,
              );
              avatarUrlToSave = uploadedUrl;
            } catch (e) {
              print('Error uploading profile image: $e');
              // Continue with existing avatar if upload fails
            }
          }

          await remoteService.saveUser(
            id: user.uid,
            name: nameController.text.trim(),
            email: email,
            phone: digits,
            gender: selectedGender.value,
            avatarUrl: avatarUrlToSave,
          );

          await user.updateDisplayName(nameController.text.trim());

          // Update all necessary UI components
          try {
            // Refresh HomeController if registered
            if (Get.isRegistered<HomeController>()) {
              final homeController = Get.find<HomeController>();
              await homeController.refreshUserData();
            }

            // Refresh ProfileMenuController if registered
            if (Get.isRegistered<ProfileMenuController>()) {
              final profileMenuController = Get.find<ProfileMenuController>();
              await profileMenuController.checkDocumentVerificationStatus();
            }

            // Update any other controllers that might display user data
            // This ensures all parts of the app reflect the updated profile
            Get.forceAppUpdate();
          } catch (e) {
            print('Error refreshing UI controllers: $e');
          }

          // Show success message
          Get.snackbar(
            'Success',
            'Profile updated successfully',
            snackPosition: SnackPosition.TOP,
            backgroundColor: Colors.green,
            colorText: Colors.white,
            duration: const Duration(seconds: 2),
          );

          // Navigate to profile page after successful update
          Get.offAllNamed(AppRoutes.root, arguments: {'initialIndex': 4});
          isSaving.value = false;
        }
      } else {
        throw Exception('User not authenticated');
      }
    } catch (e) {
      isSaving.value = false;
      Get.snackbar(
        'Error',
        'Failed to save profile: ${e.toString()}',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> pickAvatarFromCamera() async {
    final ImagePicker picker = ImagePicker();
    final XFile? file = await picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 85,
    );
    if (file != null) {
      avatarPath.value = file.path;
      _saveProgress();
    }
  }

  Future<void> pickAvatarFromGallery() async {
    final ImagePicker picker = ImagePicker();
    final XFile? file = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (file != null) {
      avatarPath.value = file.path;
      _saveProgress();
    }
  }

  @override
  void onClose() {
    try { nameController.dispose(); } catch (_) {}
    try { emailController.dispose(); } catch (_) {}
    try { phoneController.dispose(); } catch (_) {}
    try { addressController.dispose(); } catch (_) {}
    try { cityController.dispose(); } catch (_) {}
    try { stateController.dispose(); } catch (_) {}
    try { pinCodeController.dispose(); } catch (_) {}
    super.onClose();
  }
}
