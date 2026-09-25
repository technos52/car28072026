import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
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
      if (e is SignInWithAppleAuthorizationException &&
          e.code == AuthorizationErrorCode.canceled) {
        return;
      }
      if (e is FirebaseAuthException && e.code == 'canceled') {
        return;
      }
      Get.snackbar('Sign-in failed', e.toString());
    } finally {
      isLoading.value = false;
    }
  }
  Future<void> continueAsGuest() async {
    isLoading.value = true;
    try {
      User? user;
      try {
        final userCred = await _authService.signInAnonymously();
        user = userCred.user;
      } catch (authError) {
        print('Anonymous Firebase sign-in warning: $authError');
      }

      final uid = user?.uid ?? 'demo_guest_user';

      if (!Get.isRegistered<RemoteService>()) {
        Get.put(RemoteService());
      }
      final remoteService = Get.find<RemoteService>();

      try {
        await remoteService.saveUser(
          id: uid,
          name: "Demo Dealer",
          email: "demo@dealmatee.com",
          phone: "9999999999",
          gender: "Male",
          avatarUrl: "https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=300&q=80",
        );

        await remoteService.saveShop(
          id: "${uid}_shop",
          userId: uid,
          shopName: "DealMatee Premium Motors",
          ownerName: "Demo Dealer",
          phone: "9999999999",
          email: "demo@dealmatee.com",
          address: "Auto Hub, Link Road, Andheri West",
          city: "Mumbai",
          state: "Maharashtra",
          pincode: "400053",
        );

        // Pre-verify KYC documents so reviewer can test Add Car & full features
        await remoteService.saveKycDocument(
          id: uid,
          userId: uid,
          panPath: "https://images.unsplash.com/photo-1554224155-8d04cb21cd6c?auto=format&fit=crop&w=400&q=80",
          aadhaarPath: "https://images.unsplash.com/photo-1554224155-8d04cb21cd6c?auto=format&fit=crop&w=400&q=80",
          addressProofPath: "https://images.unsplash.com/photo-1554224155-8d04cb21cd6c?auto=format&fit=crop&w=400&q=80",
          isVerified: true,
        );

        // Seed rich user cars
        await remoteService.saveCar(
          id: "${uid}_car_1",
          userId: uid,
          make: "Toyota",
          model: "Camry",
          year: "2023",
          price: "2500000",
          variant: "ZX Hybrid",
          fuelType: "Petrol",
          transmission: "Automatic",
          color: "Pearl White",
          kmsDriven: "18500",
          owner: "1st Owner",
          insurance: "Comprehensive",
          mileage: "19.1 kmpl",
          tankCapacity: "50 L",
          state: "Maharashtra",
          city: "Mumbai",
          pincode: "400053",
          imageUrls: [
            "https://images.unsplash.com/photo-1621007947382-bb3c3994e3fb?auto=format&fit=crop&w=800&q=80",
            "https://images.unsplash.com/photo-1549317661-bd32c8ce0db2?auto=format&fit=crop&w=800&q=80",
          ],
          description: "Pristine condition Toyota Camry Hybrid. Fully serviced at authorized dealership with complete records.",
          isAvailable: true,
        );

        await remoteService.saveCar(
          id: "${uid}_car_2",
          userId: uid,
          make: "Hyundai",
          model: "Creta",
          year: "2022",
          price: "1650000",
          variant: "SX (O) Turbo",
          fuelType: "Diesel",
          transmission: "Automatic",
          color: "Phantom Black",
          kmsDriven: "24000",
          owner: "1st Owner",
          insurance: "Zero Depreciation",
          mileage: "18.5 kmpl",
          tankCapacity: "50 L",
          state: "Maharashtra",
          city: "Mumbai",
          pincode: "400053",
          imageUrls: [
            "https://images.unsplash.com/photo-1549317661-bd32c8ce0db2?auto=format&fit=crop&w=800&q=80",
            "https://images.unsplash.com/photo-1552519507-da3b142c6e3d?auto=format&fit=crop&w=800&q=80",
          ],
          description: "Top of the line Hyundai Creta SX(O) with panoramic sunroof, ventilated seats, and Bose audio.",
          isAvailable: true,
        );

        // Seed explore cars from other dealers
        await remoteService.saveCar(
          id: "demo_explore_bmw",
          userId: "dealer_apex_auto",
          make: "BMW",
          model: "3 Series",
          year: "2023",
          price: "4800000",
          variant: "330i M Sport",
          fuelType: "Petrol",
          transmission: "Automatic",
          color: "Portimao Blue",
          kmsDriven: "12000",
          owner: "1st Owner",
          insurance: "Comprehensive",
          mileage: "15.3 kmpl",
          tankCapacity: "59 L",
          state: "Maharashtra",
          city: "Mumbai",
          pincode: "400050",
          imageUrls: [
            "https://images.unsplash.com/photo-1555215695-3004980ad54e?auto=format&fit=crop&w=800&q=80",
            "https://images.unsplash.com/photo-1583121274602-3e2820c69888?auto=format&fit=crop&w=800&q=80",
          ],
          description: "Certified pre-owned BMW 330i M Sport with manufacturer warranty and full service history.",
          isAvailable: true,
        );

        await remoteService.saveCar(
          id: "demo_explore_thar",
          userId: "dealer_star_wheels",
          make: "Mahindra",
          model: "Thar",
          year: "2023",
          price: "1750000",
          variant: "LX 4-Str Hard Top",
          fuelType: "Diesel",
          transmission: "Manual",
          color: "Rocky Beige",
          kmsDriven: "9500",
          owner: "1st Owner",
          insurance: "Comprehensive",
          mileage: "14.0 kmpl",
          tankCapacity: "57 L",
          state: "Maharashtra",
          city: "Pune",
          pincode: "411001",
          imageUrls: [
            "https://images.unsplash.com/photo-1503376780353-7e6692767b70?auto=format&fit=crop&w=800&q=80",
          ],
          description: "Iconic Mahindra Thar 4x4 with hard top and off-road enhancements.",
          isAvailable: true,
        );
      } catch (saveError) {
        print('Firestore demo data seeding warning: $saveError');
      }

      Get.offAllNamed(AppRoutes.root);
    } catch (e) {
      print('Demo Login Error: $e');
      Get.offAllNamed(AppRoutes.root);
    } finally {
      isLoading.value = false;
    }
  }
}

