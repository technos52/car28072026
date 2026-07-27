import 'package:get/get.dart';
import 'app_routes.dart';
import '../../core/middleware/auth_middleware.dart';
import '../modules/login/login_page.dart';
import '../modules/dashboard/dashboard_page.dart';
import '../modules/users/users_page.dart';
import '../modules/users/user_detail_page.dart';
import '../modules/cars/cars_page.dart';
import '../modules/kyc/kyc_page.dart';
import '../modules/admins/admins_page.dart';
import '../modules/carousel_images/carousel_images_page.dart';
import '../modules/notifications/notifications_page.dart';
import '../modules/send_message/send_message_page.dart';

class AppPages {
  static final pages = [
    GetPage(
      name: AppRoutes.login,
      page: () => const LoginPage(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: AppRoutes.dashboard,
      page: () => const DashboardPage(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: AppRoutes.users,
      page: () => const UsersPage(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: AppRoutes.userDetail,
      page: () => const UserDetailPage(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: AppRoutes.cars,
      page: () => const CarsPage(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: AppRoutes.kyc,
      page: () => const KycPage(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: AppRoutes.admins,
      page: () => const AdminsPage(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: AppRoutes.carouselImages,
      page: () => const CarouselImagesPage(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: AppRoutes.notifications,
      page: () => const NotificationsPage(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: AppRoutes.sendMessage,
      page: () => SendMessagePage(
        userId: Get.parameters['userId'],
        userName: Get.parameters['userName'],
      ),
      middlewares: [AuthMiddleware()],
    ),
  ];
}

