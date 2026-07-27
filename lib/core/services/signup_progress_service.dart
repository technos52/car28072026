import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../app/routes/app_routes.dart';

class SignupProgressService extends GetxService {
  final GetStorage _storage = GetStorage();
  
  static const String _keyStage = 'signup_stage';
  static const String _keyProfileData = 'signup_profile_data';
  static const String _keyShopData = 'signup_shop_data';

  static const List<String> onboardingRoutes = [
    AppRoutes.phone,
    AppRoutes.otp,
    AppRoutes.profile,
    AppRoutes.shop,
    AppRoutes.verification,
    AppRoutes.verificationDocs,
    AppRoutes.addCar,
    AppRoutes.cars,
    AppRoutes.carDetail,
  ];

  bool isOnboardingRoute(String route) {
    return onboardingRoutes.contains(route);
  }

  String? getCurrentStage() {
    return _storage.read<String>(_keyStage);
  }

  void setStage(String route) {
    if (isOnboardingRoute(route)) {
      _storage.write(_keyStage, route);
    }
  }

  void saveCurrentRouteIfOnboarding() {
    final currentRoute = Get.currentRoute;
    if (currentRoute.isNotEmpty && isOnboardingRoute(currentRoute)) {
      setStage(currentRoute);
    }
  }

  void setProfileData(Map<String, dynamic> data) {
    _storage.write(_keyProfileData, data);
  }

  Map<String, dynamic>? getProfileData() {
    final data = _storage.read<Map<String, dynamic>>(_keyProfileData);
    return data != null ? Map<String, dynamic>.from(data) : null;
  }

  void setShopData(Map<String, dynamic> data) {
    _storage.write(_keyShopData, data);
  }

  Map<String, dynamic>? getShopData() {
    final data = _storage.read<Map<String, dynamic>>(_keyShopData);
    return data != null ? Map<String, dynamic>.from(data) : null;
  }

  void clearProgress() {
    _storage.remove(_keyStage);
    _storage.remove(_keyProfileData);
    _storage.remove(_keyShopData);
  }

  String? getNextRoute(String currentRoute) {
    if (currentRoute == AppRoutes.profile) {
      return AppRoutes.shop;
    } else if (currentRoute == AppRoutes.shop) {
      return AppRoutes.verification;
    } else if (currentRoute == AppRoutes.verification) {
      return AppRoutes.verificationDocs;
    } else if (currentRoute == AppRoutes.verificationDocs) {
      return AppRoutes.cars;
    }
    return null;
  }
}

