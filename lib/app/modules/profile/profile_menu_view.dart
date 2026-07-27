import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:get_storage/get_storage.dart';
import '../../../core/constants/app_color.dart';
import '../../../core/utils/ts.dart';
import '../../../core/utils/app_text.dart';
import '../../../core/utils/size.dart';
import '../../../../core/database/database_service.dart';
import '../../../core/utils/cached_image.dart';
import '../../../core/utils/app_button.dart';
import '../../../core/services/remote_service.dart';
import 'controller/profile_menu_controller.dart';
import '../shop/shop_view.dart';
import '../../routes/app_routes.dart';
import '../../services/auth_service.dart';

bool _isLocalFile(String path) {
  return path.startsWith('/') ||
      path.startsWith('file://') ||
      (!path.startsWith('http://') && !path.startsWith('https://'));
}

class ProfileMenuView extends StatefulWidget {
  const ProfileMenuView({super.key});

  @override
  State<ProfileMenuView> createState() => _ProfileMenuViewState();
}

class _ProfileMenuViewState extends State<ProfileMenuView> {
  final RxString userName = ''.obs;
  final RxString userAvatarUrl = ''.obs;
  final RxString shopName = ''.obs;
  final RxString shopImageUrl = ''.obs;
  late final ProfileMenuController profileController;

  @override
  void initState() {
    super.initState();
    profileController = Get.put(ProfileMenuController());
    _loadUserData();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Refresh data when returning to this page (e.g., from profile edit)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _loadUserData(); // Refresh user data
        profileController.checkDocumentVerificationStatus();
      }
    });
  }

  // Public method to refresh data - can be called from RootController
  Future<void> refreshProfileMenuData() async {
    await _loadUserData();
    await profileController.checkDocumentVerificationStatus();
  }

  Future<void> _loadUserData() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        if (!Get.isRegistered<RemoteService>()) {
          Get.put(RemoteService());
        }
        if (!Get.isRegistered<DatabaseService>()) {
          await Get.putAsync<DatabaseService>(() async => DatabaseService());
        }

        final remoteService = Get.find<RemoteService>();
        final databaseService = Get.find<DatabaseService>();

        final userData = await remoteService.getUser(user.uid);
        if (userData != null) {
          userName.value = userData['name'] ?? user.displayName ?? 'User';
          final savedAvatar = userData['avatarUrl']?.toString() ?? '';
          if (savedAvatar.isNotEmpty) {
            userAvatarUrl.value = savedAvatar;
            print('User avatar loaded from remote: $savedAvatar');
          } else {
            userAvatarUrl.value = '';
            print('No user avatar found in remote data');
          }
        } else {
          final localUser = await databaseService.getUser(user.uid);
          if (localUser != null) {
            userName.value = localUser.name;
            userAvatarUrl.value = localUser.avatarUrl ?? '';
            print('User avatar loaded from local: ${localUser.avatarUrl}');
          } else {
            userName.value = user.displayName ?? 'User';
            userAvatarUrl.value = '';
            print('No local user data found');
          }
        }

        // Check document verification status
        profileController.checkDocumentVerificationStatus();

        // Load shop data
        final shopData = await remoteService.getUserShop(user.uid);
        if (shopData != null && shopData['shopName'] != null) {
          shopName.value = shopData['shopName'].toString();
          shopImageUrl.value = shopData['logoUrl']?.toString() ?? '';
          print(
            'Shop data loaded: ${shopData['shopName']}, Image: ${shopData['logoUrl']}',
          );
        } else {
          final localShop = await databaseService.getShop(user.uid);
          if (localShop != null) {
            shopName.value = localShop.shopName;
            shopImageUrl.value = localShop.logoUrl ?? '';
            print(
              'Local shop data: ${localShop.shopName}, Image: ${localShop.logoUrl}',
            );
          } else {
            shopName.value = '';
            shopImageUrl.value = '';
            print('No shop data found');
          }
        }

        // If no shop data found, use demo data for better UI
        if (shopName.value.isEmpty) {
          shopName.value = '9900';
        }

        // Demo images removed - now using real uploaded images
      }
    } catch (e) {
      print('Error loading user data: $e');
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        userName.value = user.displayName ?? 'User';
        userAvatarUrl.value = '';
        shopName.value = '';
        shopImageUrl.value = '';
      }
    }
  }

  Widget _buildDefaultBanner() {
    return Container(
      width: double.infinity,
      height: 200,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColor.secondary,
            AppColor.secondary.withValues(alpha: 0.8),
          ],
        ),
      ),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.store, size: 60, color: Colors.white),
            SizedBox(height: 8),
            Text(
              'Car Dealership',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
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

        title: AppText(
          'Profile',
          style: Ts.semiBold18(color: AppColor.secondary),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            // Banner Section with Shop Image and User Profile
            Obx(
              () => Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: AppColor.gray100,
                ),
                child: Stack(
                  children: [
                    // Shop Banner Image
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: shopImageUrl.value.isNotEmpty
                          ? (_isLocalFile(shopImageUrl.value)
                                ? Image.file(
                                    File(shopImageUrl.value),
                                    width: double.infinity,
                                    height: 200,
                                    fit: BoxFit.cover,
                                    errorBuilder:
                                        (context, error, stackTrace) =>
                                            _buildDefaultBanner(),
                                  )
                                : CachedImage(
                                    imageUrl: shopImageUrl.value,
                                    width: double.infinity,
                                    height: 200,
                                    fit: BoxFit.cover,
                                    errorWidget: _buildDefaultBanner(),
                                  ))
                          : _buildDefaultBanner(),
                    ),
                    // Gradient Overlay
                    Container(
                      width: double.infinity,
                      height: 200,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.7),
                          ],
                        ),
                      ),
                    ),
                    // Shop Name and User Info
                    Positioned(
                      bottom: 16,
                      left: 16,
                      right: 16,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AppText(
                            shopName.value.isNotEmpty
                                ? shopName.value
                                : 'Shop Name',
                            style: Ts.semiBold20(color: Colors.white),
                          ),
                          const Hbox(4),
                          AppText(
                            'Authorized Car Dealer',
                            style: Ts.regular14(color: Colors.white70),
                          ),
                        ],
                      ),
                    ),
                    // Small Circular User Profile Image
                    Positioned(
                      bottom: 16,
                      right: 16,
                      child: Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 3),
                        ),
                        child: ClipOval(
                          child: userAvatarUrl.value.isNotEmpty
                              ? (_isLocalFile(userAvatarUrl.value)
                                    ? Image.file(
                                        File(userAvatarUrl.value),
                                        width: 60,
                                        height: 60,
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (context, error, stackTrace) =>
                                                Container(
                                                  color: Colors.orange,
                                                  child: const Icon(
                                                    Icons.person,
                                                    size: 30,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                      )
                                    : CachedImage(
                                        imageUrl: userAvatarUrl.value,
                                        width: 60,
                                        height: 60,
                                        fit: BoxFit.cover,
                                        errorWidget: Container(
                                          color: Colors.orange,
                                          child: const Icon(
                                            Icons.person,
                                            size: 30,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ))
                              : Container(
                                  color: Colors.orange,
                                  child: const Icon(
                                    Icons.person,
                                    size: 30,
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                      ),
                    ),
                    // Verification Badge (if not verified)
                    if (!profileController.areDocumentsUploaded.value)
                      Positioned(
                        top: 16,
                        right: 16,
                        child: GestureDetector(
                          onTap: () {
                            Get.snackbar(
                              'KYC Documents Required',
                              'Please get your documents submitted and you will get a green tick',
                              snackPosition: SnackPosition.TOP,
                              backgroundColor: Colors.orange,
                              colorText: Colors.white,
                              duration: const Duration(seconds: 3),
                            );
                          },
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: Colors.orange,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                            child: const Icon(
                              Icons.error_outline,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const Hbox(20),
            // User Name Section
            Obx(
              () => Column(
                children: [
                  AppText(
                    userName.value.isNotEmpty ? userName.value : 'User',
                    style: Ts.semiBold18(color: AppColor.secondary),
                  ),
                  const Hbox(4),
                  AppText(
                    'Third+',
                    style: Ts.regular14(color: AppColor.gray600),
                  ),
                ],
              ),
            ),
            const Hbox(30),

            // Menu Items
            _ProfileMenuItem(
              icon: Icons.edit_outlined,
              title: 'Edit Profile',
              onTap: () {
                Get.toNamed(AppRoutes.profile, arguments: {'from': 'edit'});
              },
            ),
            const Hbox(16),
            _ProfileMenuItem(
              icon: Icons.store_outlined,
              title: 'Edit Shop Details',
              onTap: () {
                Get.to(() => const ShopView(), arguments: {'from': 'edit'});
              },
            ),
            const Hbox(16),
            Obx(() {
              // Show "Verify Documents" option if documents are not verified
              if (!profileController.isDocumentVerified.value) {
                return Column(
                  children: [
                    _ProfileMenuItem(
                      icon: Icons.verified_user_outlined,
                      title: 'Verify Documents',
                      hasAlert: true,
                      onTap: () {
                        Get.toNamed(
                          AppRoutes.verificationDocs,
                          arguments: {'onboarding': false},
                        );
                      },
                    ),
                    const Hbox(16),
                  ],
                );
              }
              return const SizedBox.shrink();
            }),
            const Hbox(16),

            _ProfileMenuItem(
              icon: Icons.privacy_tip_outlined,
              title: 'Privacy Policy',
              onTap: () {
                Get.toNamed(AppRoutes.privacyPolicy);
              },
            ),
            const Hbox(16),
            // Delete Account Button
            GestureDetector(
              onTap: () => _showDeleteAccountDialog(context),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColor.gray200),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.red.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.delete_forever_outlined,
                        color: Colors.red,
                        size: 20,
                      ),
                    ),
                    const Wbox(16),
                    Expanded(
                      child: AppText(
                        'Delete Account',
                        style: Ts.regular16(color: Colors.red),
                      ),
                    ),
                    const Icon(
                      Icons.arrow_forward_ios,
                      color: AppColor.secondary,
                      size: 16,
                    ),
                  ],
                ),
              ),
            ),
            const Hbox(16),
            // Logout Button
            GestureDetector(
              onTap: () => _showLogoutDialog(context),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColor.gray200),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColor.secondary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.logout,
                        color: AppColor.secondary,
                        size: 20,
                      ),
                    ),
                    const Wbox(16),
                    Expanded(
                      child: AppText(
                        'Logout',
                        style: Ts.regular16(color: AppColor.secondary),
                      ),
                    ),
                    const Icon(
                      Icons.arrow_forward_ios,
                      color: AppColor.secondary,
                      size: 16,
                    ),
                  ],
                ),
              ),
            ),
            const Hbox(30),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _showDeleteAccountDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColor.gray300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const Hbox(24),
              AppText('Delete Account', style: Ts.semiBold20(color: Colors.red)),
              const Hbox(16),
              AppText(
                'Are you sure you want to delete your account? This action is permanent and cannot be undone.',
                style: Ts.regular16(color: AppColor.gray600),
                textAlign: TextAlign.center,
              ),
              const Hbox(32),
              Row(
                children: [
                  Expanded(
                    child: AppButton(
                      text: 'Cancel',
                      useGradient: false,
                      bgColor: AppColor.gray100,
                      textColor: AppColor.gray600,
                      onPressed: () => Navigator.pop(context),
                      height: 50,
                      borderRadius: 30,
                    ),
                  ),
                  const Wbox(16),
                  Expanded(
                    child: AppButton(
                      text: 'Delete',
                      useGradient: false,
                      bgColor: Colors.red,
                      textColor: Colors.white,
                      onPressed: () async {
                        Navigator.pop(context);
                        await profileController.deleteAccount();
                      },
                      height: 50,
                      borderRadius: 30,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Drag Handle
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColor.gray300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const Hbox(24),

              // Logout Title
              AppText('Logout', style: Ts.semiBold20(color: Colors.red)),
              const Hbox(16),

              // Confirmation Message
              AppText(
                'Are you sure you want to log out?',
                style: Ts.regular16(color: AppColor.gray600),
                textAlign: TextAlign.center,
              ),
              const Hbox(32),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: AppButton(
                      text: 'Cancel',
                      useGradient: false,
                      bgColor: AppColor.gray100,
                      textColor: AppColor.gray600,
                      onPressed: () => Navigator.pop(context),
                      height: 50,
                      borderRadius: 30,
                    ),
                  ),
                  const Wbox(16),
                  Expanded(
                    child: AppButton(
                      text: 'Logout',
                      useGradient: false,
                      bgColor: AppColor.secondary,
                      textColor: Colors.white,
                      onPressed: () async {
                        Navigator.pop(context);
                        await _handleLogout();
                      },
                      height: 50,
                      borderRadius: 30,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _handleLogout() async {
    try {
      // Clear local database
      if (Get.isRegistered<DatabaseService>()) {
        final databaseService = Get.find<DatabaseService>();
        await databaseService.clearAllData();
      }

      final user = FirebaseAuth.instance.currentUser;
      if (user != null && user.isAnonymous) {
        try {
          if (!Get.isRegistered<AuthService>()) {
            Get.put(AuthService());
          }
          await Get.find<AuthService>().deleteAccount();
        } catch (e) {
          print('Error deleting demo account: $e');
        }
      } else {
        // Sign out from Firebase
        await FirebaseAuth.instance.signOut();
      }

      // Sign out from Google
      try {
        await GoogleSignIn().signOut();
      } catch (_) {}

      // Clear GetStorage
      try {
        await GetStorage().erase();
      } catch (_) {}

      // Navigate to auth screen first
      Get.offAllNamed(AppRoutes.auth);

      // Clear GetX non-permanent bindings (but keep services initialized in main)
      Get.deleteAll(force: false);

      Get.snackbar(
        'Success',
        'Logged out successfully',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to logout: ${e.toString()}',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
}

class _ProfileMenuItem extends StatelessWidget {
  const _ProfileMenuItem({
    required this.icon,
    required this.title,
    required this.onTap,
    this.hasAlert = false,
  });

  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final bool hasAlert;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColor.gray200),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColor.gray100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Center(
                    child: Icon(icon, color: AppColor.secondary, size: 20),
                  ),
                  if (hasAlert)
                    Positioned(
                      right: -4,
                      top: -4,
                      child: Container(
                        width: 16,
                        height: 16,
                        decoration: BoxDecoration(
                          color: Colors.orange,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 1.5),
                        ),
                        child: const Icon(
                          Icons.error_outline,
                          color: Colors.white,
                          size: 10,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const Wbox(16),
            Expanded(
              child: AppText(
                title,
                style: Ts.regular16(color: AppColor.secondary),
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              color: AppColor.secondary,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}
