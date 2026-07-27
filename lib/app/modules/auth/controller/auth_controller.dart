import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../services/auth_service.dart';
import '../../../routes/app_routes.dart';
import '../../../../core/services/remote_service.dart';

class AuthController extends GetxController {
  final AuthService _authService = Get.find<AuthService>();
  final RxBool isLoading = false.obs;

  Future<void> signInWithGoogle() async {
    await _signIn(() => _authService.signInWithGoogle());
  }

  Future<void> signInWithApple() async {
    await _signIn(() => _authService.signInWithApple());
  }

  Future<void> _signIn(Future<UserCredential> Function() action) async {
    if (isLoading.value) return;
    isLoading.value = true;
    try {
      final UserCredential credential = await action();
      final User? user = credential.user;
      if (user == null) throw Exception('No user');

      final bool existing = await _authService.isExistingUser(user);
      if (existing) {
        Get.offAllNamed(AppRoutes.root);
      } else {
        Get.offAllNamed(AppRoutes.profile, arguments: {'onboarding': true});
      }
    } catch (e) {
      Get.snackbar('Sign-in failed', e.toString());
    } finally {
      isLoading.value = false;
    }
  }
  Future<void> continueAsGuest() async {
    isLoading.value = true;
    try {
      final userCred = await _authService.signInAnonymously();
      final user = userCred.user;
      
      if (user != null) {
        if (!Get.isRegistered<RemoteService>()) {
          Get.put(RemoteService());
        }
        final remoteService = Get.find<RemoteService>();
        
        await remoteService.saveUser(
          id: user.uid,
          name: "Demo User",
          email: "demo@dealmatee.com",
          phone: "9999999999",
          gender: "Male",
        );

        await remoteService.saveShop(
          id: "${user.uid}_shop",
          userId: user.uid,
          shopName: "Demo Dealership",
          ownerName: "Demo User",
          phone: "9999999999",
          email: "demo@dealmatee.com",
          address: "123 Demo Street",
          city: "Demo City",
          state: "Demo State",
          pincode: "111111",
        );

        await remoteService.saveCar(
          id: "${user.uid}_car_1",
          userId: user.uid,
          make: "Toyota",
          model: "Camry",
          year: "2023",
          price: "2500000",
          description: "This is a prefilled demo car.",
          isAvailable: true,
        );
      }

      Get.offAllNamed(AppRoutes.root);
    } catch (e) {
      print('Demo Login Error: $e');
      Get.defaultDialog(
        title: 'Demo Login Failed',
        middleText: e.toString() + '\n\nMake sure Anonymous Authentication is enabled in your Firebase Console!',
        textConfirm: 'OK',
        onConfirm: () => Get.back(),
      );
    } finally {
      isLoading.value = false;
    }
  }
}

