import 'package:get/get.dart';
import '../modules/home/home_binding.dart';
import '../modules/home/home_screen.dart';
import '../modules/splash/binding/splash_binding.dart';
import '../modules/splash/splash_view.dart';
import '../modules/auth/binding/auth_binding.dart';
import '../modules/auth/auth_view.dart';
import '../modules/phone/binding/phone_binding.dart';
import '../modules/phone/phone_view.dart';
import '../modules/otp/controller/otp_controller.dart';
import '../modules/otp/otp_view.dart';
import '../modules/profile/controller/profile_controller.dart';
import '../modules/profile/profile_view.dart';
import '../modules/shop/controller/shop_controller.dart';
import '../modules/shop/shop_view.dart';
import '../modules/verification/controller/verification_controller.dart';
import '../modules/verification/verification_view.dart';
import '../modules/verification_docs/controller/verification_docs_controller.dart';
import '../modules/verification_docs/verification_docs_view.dart';
import '../modules/add_car/add_car_view.dart';
import '../modules/add_car/controller/add_car_controller.dart';
import '../modules/cars/cars_view.dart';
import '../modules/cars/controller/cars_controller.dart';
import '../modules/car_detail/car_detail_view.dart';
import '../modules/car_detail/controller/car_detail_controller.dart';
import '../modules/root/root_view.dart';
import '../modules/root/controller/root_controller.dart';
import '../modules/search/search_view.dart';
import '../modules/search/controller/search_controller.dart' as sc;
import '../modules/owner_cars/owner_cars_view.dart';
import '../modules/owner_cars/controller/owner_cars_controller.dart';
import '../modules/privacy_policy/privacy_policy_view.dart';
import '../../core/middleware/onboarding_middleware.dart';
import 'app_routes.dart';

class AppPages {
  AppPages._();

  static final List<GetPage> pages = <GetPage<dynamic>>[
    GetPage(
      name: AppRoutes.splash,
      page: () => const SplashView(),
      binding: SplashBinding(),
    ),
    GetPage(
      name: AppRoutes.home,
      page: () => const HomeScreen(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: AppRoutes.auth,
      page: () => const AuthView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: AppRoutes.phone,
      page: () => const PhoneView(),
      binding: PhoneBinding(),
      middlewares: [OnboardingMiddleware()],
    ),
    GetPage(
      name: AppRoutes.otp,
      page: () => const OtpView(),
      binding: BindingsBuilder(
        () => Get.lazyPut<OtpController>(() => OtpController()),
      ),
      middlewares: [OnboardingMiddleware()],
    ),
    GetPage(
      name: AppRoutes.profile,
      page: () => const ProfileView(),
      binding: BindingsBuilder(() {
        if (!Get.isRegistered<ProfileController>()) {
          Get.put(ProfileController());
        }
      }),
      middlewares: [OnboardingMiddleware()],
    ),
    GetPage(
      name: AppRoutes.shop,
      page: () => const ShopView(),
      binding: BindingsBuilder(() {
        if (!Get.isRegistered<ShopController>()) {
          Get.put(ShopController());
        }
      }),
      middlewares: [OnboardingMiddleware()],
    ),
    GetPage(
      name: AppRoutes.verification,
      page: () => const VerificationView(),
      binding: BindingsBuilder(
        () =>
            Get.lazyPut<VerificationController>(() => VerificationController()),
      ),
      middlewares: [OnboardingMiddleware()],
    ),
    GetPage(
      name: AppRoutes.verificationDocs,
      page: () => const VerificationDocsView(),
      binding: BindingsBuilder(
        () => Get.lazyPut<VerificationDocsController>(
          () => VerificationDocsController(),
        ),
      ),
      middlewares: [OnboardingMiddleware()],
    ),
    GetPage(
      name: AppRoutes.addCar,
      page: () => const AddCarView(),
      binding: BindingsBuilder(
        () => Get.lazyPut<AddCarController>(() => AddCarController()),
      ),
      middlewares: [OnboardingMiddleware()],
    ),
    GetPage(
      name: AppRoutes.cars,
      page: () => const CarsView(),
      binding: BindingsBuilder(
        () => Get.lazyPut<CarsController>(() => CarsController()),
      ),
      middlewares: [OnboardingMiddleware()],
    ),
    GetPage(
      name: AppRoutes.carDetail,
      page: () => const CarDetailView(),
      binding: BindingsBuilder(
        () => Get.lazyPut<CarDetailController>(() => CarDetailController()),
      ),
      middlewares: [OnboardingMiddleware()],
    ),
    GetPage(
      name: AppRoutes.root,
      page: () => const RootView(),
      binding: BindingsBuilder(
        () => Get.lazyPut<RootController>(() => RootController()),
      ),
    ),
    GetPage(
      name: AppRoutes.search,
      page: () => const SearchView(),
      binding: BindingsBuilder(
        () => Get.lazyPut<sc.SearchController>(() => sc.SearchController()),
      ),
    ),
    GetPage(
      name: AppRoutes.ownerCars,
      page: () => const OwnerCarsView(),
      binding: BindingsBuilder(
        () => Get.lazyPut<OwnerCarsController>(() => OwnerCarsController()),
      ),
    ),
    GetPage(
      name: AppRoutes.privacyPolicy,
      page: () => const PrivacyPolicyView(),
    ),
  ];
}
