import 'dart:convert';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/services/remote_service.dart';
import '../../../core/models/car.dart' as CarModel;
import '../home/home_controller.dart';

class WishlistController extends GetxController {
  final RxList<CarModel.Car> wishlistCars = <CarModel.Car>[].obs;
  final Map<String, String> wishlistCarIdMap = {};
  final Map<String, bool> carAvailabilityMap = {};
  final RxBool isLoading = false.obs;

  String _getCarKey(CarModel.Car car) {
    return '${car.name}_${car.model}_${car.yearOfManufacture}_${car.demandPrice}';
  }

  @override
  void onInit() {
    super.onInit();
    loadWishlist();
  }

  @override
  void onReady() {
    super.onReady();
    // Refresh wishlist when page becomes ready
    refreshWishlist();
  }

  Future<void> loadWishlist() async {
    try {
      isLoading.value = true;
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        isLoading.value = false;
        return;
      }

      if (!Get.isRegistered<RemoteService>()) {
        Get.put(RemoteService());
      }
      final remoteService = Get.find<RemoteService>();

      final wishlistIds = await remoteService.getWishlist(user.uid);
      wishlistCars.clear();
      wishlistCarIdMap.clear();

      // Load cars in parallel for faster loading
      final futures = wishlistIds.map((carId) async {
        final carData = await remoteService.getCarById(carId);
        if (carData != null) {
          return {'carId': carId, 'carData': carData};
        }
        return null;
      });

      final results = await Future.wait(futures);

      for (var result in results) {
        if (result != null) {
          final carId = result['carId'] as String;
          final carData = result['carData'] as Map<String, dynamic>;

          List<String> imageUrls = [];
          if (carData['imageUrls'] != null && carData['imageUrls'] is List) {
            imageUrls = (carData['imageUrls'] as List).cast<String>();
          } else if (carData['imageUrl'] != null) {
            final imageUrl = carData['imageUrl'] as String;
            if (imageUrl.startsWith('[') && imageUrl.endsWith(']')) {
              try {
                final List<dynamic> parsed = jsonDecode(imageUrl);
                imageUrls = parsed.cast<String>();
              } catch (e) {
                imageUrls = [imageUrl];
              }
            } else {
              imageUrls = [imageUrl];
            }
          }

          final description = carData['description'] as String? ?? '';
          final descriptionParts = _parseDescription(description);

          final car = CarModel.Car(
            name: carData['make'] as String? ?? '',
            variant: (carData['variant'] as String? ?? '').isNotEmpty
                ? (carData['variant'] as String)
                : (descriptionParts['variant'] ?? ''),
            yearOfManufacture: carData['year'] as String? ?? '',
            owner: carData['owner'] as String? ?? '',
            color: (carData['color'] as String? ?? '').isNotEmpty
                ? (carData['color'] as String)
                : (descriptionParts['color'] ?? ''),
            model: carData['model'] as String? ?? '',
            fuelType: (carData['fuelType'] as String? ?? '').isNotEmpty
                ? (carData['fuelType'] as String)
                : (descriptionParts['fuelType'] ?? ''),
            insurance: carData['insurance'] as String? ?? '',
            transmission: carData['transmission'] as String? ?? '',
            demandPrice: carData['price'] as String? ?? '',
            kmsDriven: carData['kmsDriven'] as String? ?? '',
            mileage: carData['mileage'] as String? ?? '',
            tankCapacity: carData['tankCapacity'] as String? ?? '',
            imagePaths: imageUrls,
            seatType: carData['seatType'] as String? ?? '5',
            licenseType: carData['licenseType'] as String? ?? 'Non Commercial',
          );

          final isAvailable = carData['isAvailable'] as bool? ?? true;
          wishlistCars.add(car);
          wishlistCarIdMap[_getCarKey(car)] = carId;
          carAvailabilityMap[carId] = isAvailable;
        }
      }
    } catch (e) {
      print('Error loading wishlist: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> removeFromWishlist(CarModel.Car car) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final carKey = _getCarKey(car);
      final carId = wishlistCarIdMap[carKey];
      if (carId == null) return;

      if (!Get.isRegistered<RemoteService>()) {
        Get.put(RemoteService());
      }
      final remoteService = Get.find<RemoteService>();

      await remoteService.removeFromWishlist(user.uid, carId);
      wishlistCars.remove(car);
      wishlistCarIdMap.remove(carKey);

      if (Get.isRegistered<HomeController>()) {
        try {
          final homeController = Get.find<HomeController>();
          homeController.wishlistCarIds.remove(carId);
        } catch (e) {}
      }
    } catch (e) {
      print('Error removing from wishlist: $e');
    }
  }

  Future<void> refreshWishlist() async {
    await loadWishlist();
  }

  Map<String, String> _parseDescription(String description) {
    final Map<String, String> result = {
      'variant': '',
      'color': '',
      'fuelType': '',
    };

    if (description.isEmpty) return result;

    final parts = description.split(',').map((e) => e.trim()).toList();
    if (parts.length >= 1) result['variant'] = parts[0];
    if (parts.length >= 2) result['color'] = parts[1];
    if (parts.length >= 3) result['fuelType'] = parts[2];

    return result;
  }
}
