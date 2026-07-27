import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_color.dart';
import '../../../core/utils/ts.dart';
import '../../../core/utils/app_text.dart';
import '../home/home_screen.dart';
import '../home/my_cars_view.dart';
import '../profile/profile_menu_view.dart';
import '../profile/controller/profile_menu_controller.dart';
import '../wishlist/wishlist_view.dart';
import '../add_car/add_car_view.dart';
import '../add_car/controller/add_car_controller.dart';
import '../../routes/app_routes.dart';
import 'controller/root_controller.dart';

class RootView extends GetView<RootController> {
  const RootView({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Scaffold(
        backgroundColor: Colors.white,
        body: IndexedStack(
          index: controller.currentIndex.value,
          children: [
            const _DashboardBodyWrapper(),
            const WishlistView(),
            _AddCarWrapper(),
            const MyCarsView(),
            const ProfileMenuView(),
          ],
        ),
        bottomNavigationBar: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(
              top: BorderSide(color: Color(0xFFB1B1B1), width: 1.0),
            ),
          ),
          child: NavigationBarTheme(
            data: NavigationBarThemeData(
              indicatorColor: AppColor.secondary.withValues(alpha: 0.12),
              labelTextStyle: WidgetStateProperty.resolveWith(
                (states) => states.contains(WidgetState.selected)
                    ? Ts.semiBold12(color: AppColor.secondary)
                    : Ts.regular12(color: AppColor.gray600),
              ),
              iconTheme: WidgetStateProperty.resolveWith(
                (states) => IconThemeData(
                  color: states.contains(WidgetState.selected)
                      ? AppColor.secondary
                      : AppColor.gray600,
                ),
              ),
            ),
            child: NavigationBar(
              selectedIndex: controller.currentIndex.value,
              onDestinationSelected: controller.setIndex,
              backgroundColor: Colors.white,
              surfaceTintColor: Colors.white,
              elevation: 0,
              destinations: [
                const NavigationDestination(
                  icon: Icon(Icons.home_outlined),
                  label: 'Home',
                ),
                const NavigationDestination(
                  icon: Icon(Icons.favorite_border_outlined),
                  label: 'Wishlist',
                ),
                const NavigationDestination(
                  icon: Icon(Icons.add_circle_outline),
                  label: 'Add Car',
                ),
                const NavigationDestination(
                  icon: Icon(Icons.directions_car_filled_outlined),
                  label: 'My Car',
                ),
                NavigationDestination(
                  icon: Obx(() {
                    final hasExclamation =
                        Get.isRegistered<ProfileMenuController>()
                        ? !Get.find<ProfileMenuController>()
                              .areDocumentsUploaded
                              .value
                        : false;
                    return Stack(
                      clipBehavior: Clip.none,
                      children: [
                        const Icon(Icons.person_outline),
                        if (hasExclamation)
                          Positioned(
                            right: -6,
                            top: -6,
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
                                width: 16,
                                height: 16,
                                decoration: BoxDecoration(
                                  color: Colors.orange,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 1.5,
                                  ),
                                ),
                                child: const Icon(
                                  Icons.error_outline,
                                  color: Colors.white,
                                  size: 10,
                                ),
                              ),
                            ),
                          ),
                      ],
                    );
                  }),
                  label: 'Profile',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Wraps the previous dashboard body to reuse the UI
class _DashboardBodyWrapper extends StatelessWidget {
  const _DashboardBodyWrapper();
  @override
  Widget build(BuildContext context) {
    // Use the fixed HomeView
    return const HomeScreen();
  }
}

// Wraps the AddCarView to ensure controller is initialized and user is verified
class _AddCarWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Ensure ProfileMenuController is registered
    if (!Get.isRegistered<ProfileMenuController>()) {
      Get.put(ProfileMenuController());
    }
    final profileController = Get.find<ProfileMenuController>();

    return Obx(() {
      if (!profileController.isDocumentVerified.value) {
        return const _VerificationRequiredView();
      }

      // Ensure AddCarController is registered before building the view
      if (!Get.isRegistered<AddCarController>()) {
        Get.put(AddCarController());
      }
      return const AddCarView();
    });
  }
}

class _VerificationRequiredView extends StatelessWidget {
  const _VerificationRequiredView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColor.secondary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.verified_user_outlined,
                  size: 80,
                  color: AppColor.secondary,
                ),
              ),
              const SizedBox(height: 32),
              AppText(
                'Verification Required',
                style: Ts.semiBold24(color: AppColor.secondary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              AppText(
                'To add car listings and ensure a safe experience for all users, you need to verify your documents first.',
                style: Ts.regular16(color: AppColor.gray600),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // Navigate to Document Upload screen
                    Get.toNamed(
                      AppRoutes.verificationDocs,
                      arguments: {'onboarding': false},
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColor.secondary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Verify Now',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
