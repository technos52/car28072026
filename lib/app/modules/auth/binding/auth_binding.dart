import 'package:get/get.dart';
import '../controller/auth_controller.dart';
import '../../../services/auth_service.dart';

class AuthBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<AuthService>(AuthService(), permanent: true);
    Get.lazyPut<AuthController>(() => AuthController());
  }
}


