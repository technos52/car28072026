import 'package:get/get.dart';
import 'package:flutter/widgets.dart';
import '../../../../core/services/signup_progress_service.dart';
import '../../profile/controller/profile_menu_controller.dart';
import '../../admin_messages/controller/admin_messages_controller.dart';
import '../../admin_messages/admin_messages_view.dart';

import '../../wishlist/wishlist_controller.dart';
import '../../home/home_controller.dart';
import '../../add_car/controller/add_car_controller.dart';

class RootController extends GetxController {
  final RxInt currentIndex = 0.obs;
  final RxString pendingBrandFilter = ''.obs;

  @override
  void onInit() {
    super.onInit();

    // Check for initialIndex argument
    final arguments = Get.arguments;
    if (arguments is Map<String, dynamic> &&
        arguments['initialIndex'] != null) {
      final initialIndex = arguments['initialIndex'] as int;
      if (initialIndex >= 0 && initialIndex <= 4) {
        currentIndex.value = initialIndex;
      }
    }

    final progressService = Get.isRegistered<SignupProgressService>()
        ? Get.find<SignupProgressService>()
        : Get.put(SignupProgressService());
    progressService.clearProgress();

    if (!Get.isRegistered<ProfileMenuController>()) {
      Get.put(ProfileMenuController());
    }

    if (!Get.isRegistered<AdminMessagesController>()) {
      Get.put(AdminMessagesController());
    }

    if (!Get.isRegistered<WishlistController>()) {
      Get.put(WishlistController());
    }
  }

  void setIndex(int i) {
    final previousIndex = currentIndex.value;
    currentIndex.value = i;

    // Only refresh if actually changing tabs to avoid unnecessary calls
    if (previousIndex != i) {
      _refreshPageData(i);
    }
  }

  void _refreshPageData(int index) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      switch (index) {
        case 0: // Home tab
          _refreshHomeData();
          break;
        case 1: // Wishlist tab
          _refreshWishlistData();
          break;
        case 2: // Add Car tab
          _refreshAddCarData();
          break;
        case 3: // My Car tab
          _refreshMyCarsData();
          break;
        case 4: // Profile tab
          _refreshProfileData();
          break;
      }
    });
  }

  Future<void> _refreshHomeData() async {
    try {
      if (Get.isRegistered<HomeController>()) {
        final homeController = Get.find<HomeController>();
        // Refresh user data and cars in parallel for faster loading
        await Future.wait([
          homeController.refreshUserData(),
          homeController.refreshCars(),
        ]);
      }
    } catch (e) {
      print('Error refreshing home data: $e');
    }
  }

  Future<void> _refreshWishlistData() async {
    try {
      if (Get.isRegistered<WishlistController>()) {
        final wishlistController = Get.find<WishlistController>();
        await wishlistController.refreshWishlist();
      }
    } catch (e) {
      print('Error refreshing wishlist data: $e');
    }
  }

  Future<void> _refreshAddCarData() async {
    try {
      if (Get.isRegistered<AddCarController>()) {
        final addCarController = Get.find<AddCarController>();
        // Refresh dropdown data for add car form
        await addCarController.loadDropdowns();
      }
    } catch (e) {
      print('Error refreshing add car data: $e');
    }
  }

  Future<void> _refreshMyCarsData() async {
    try {
      if (Get.isRegistered<HomeController>()) {
        final homeController = Get.find<HomeController>();
        await homeController.refreshCars();
      }
    } catch (e) {
      print('Error refreshing my cars data: $e');
    }
  }

  Future<void> _refreshProfileData() async {
    try {
      if (Get.isRegistered<ProfileMenuController>()) {
        final profileController = Get.find<ProfileMenuController>();
        // Refresh both user cars and document verification status
        await Future.wait([
          profileController.refreshCars(),
          profileController.checkDocumentVerificationStatus(),
        ]);
      }
    } catch (e) {
      print('Error refreshing profile data: $e');
    }
  }

  void navigateToNotifications() {
    // Navigate to admin messages page
    Get.to(() => const AdminMessagesView());
  }

  void setBrandFilter(String brand) {
    pendingBrandFilter.value = brand;
  }

  String? getBrandFilterAndClear() {
    final brand = pendingBrandFilter.value;
    if (brand.isNotEmpty) {
      pendingBrandFilter.value = '';
      return brand;
    }
    return null;
  }

  // Force refresh all pages data - useful after major data changes
  Future<void> refreshAllPages() async {
    try {
      await Future.wait([
        _refreshHomeData(),
        _refreshWishlistData(),
        _refreshMyCarsData(),
        _refreshProfileData(),
      ]);
    } catch (e) {
      print('Error refreshing all pages: $e');
    }
  }

  // Force refresh current page
  Future<void> refreshCurrentPage() async {
    _refreshPageData(currentIndex.value);
  }
}
