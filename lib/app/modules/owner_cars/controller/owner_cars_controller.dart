import 'dart:convert';
import 'package:get/get.dart';
import '../../../../core/services/remote_service.dart';
import '../../../../core/models/car.dart' as CarModel;

class OwnerCarsController extends GetxController {
  final RxList<CarModel.Car> ownerCars = <CarModel.Car>[].obs;
  final RxBool isLoading = true.obs;
  final RxString ownerName = ''.obs;
  final RxString ownerId = ''.obs;
  final Map<String, String> carIdMap = {};
  final Map<String, bool> carAvailabilityMap = {};

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args is Map<String, dynamic>) {
      ownerId.value = args['ownerId'] as String? ?? '';
      ownerName.value = args['ownerName'] as String? ?? 'Owner';
    }
    loadOwnerCars();
  }

  Future<void> loadOwnerCars() async {
    try {
      isLoading.value = true;

      if (ownerId.value.isEmpty) {
        isLoading.value = false;
        return;
      }

      if (!Get.isRegistered<RemoteService>()) {
        Get.put(RemoteService());
      }
      final remoteService = Get.find<RemoteService>();

      final carsData = await remoteService.getCarsByOwner(ownerId.value);

      final cars = <CarModel.Car>[];
      carIdMap.clear();

      for (var carData in carsData) {
        final carId = carData['id'] as String? ?? '';

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

        final car = CarModel.Car(
          name: carData['make']?.toString() ?? '',
          model: carData['model']?.toString() ?? '',
          variant: carData['variant']?.toString() ?? '',
          yearOfManufacture: carData['year']?.toString() ?? '',
          owner: carData['owner']?.toString() ?? '',
          color: carData['color']?.toString() ?? '',
          fuelType: carData['fuelType']?.toString() ?? '',
          insurance: carData['insurance']?.toString() ?? '',
          transmission: carData['transmission']?.toString() ?? '',
          demandPrice: carData['price']?.toString() ?? '',
          kmsDriven: carData['kmsDriven']?.toString() ?? '',
          mileage: carData['mileage']?.toString() ?? '',
          tankCapacity: carData['tankCapacity']?.toString() ?? '',
          imagePaths: imageUrls,
          seatType: carData['seatType']?.toString() ?? '5',
          licenseType: carData['licenseType']?.toString() ?? 'Non Commercial',
        );

        final carKey = _getCarKey(car);
        final isAvailable = carData['isAvailable'] as bool? ?? true;
        carIdMap[carKey] = carId;
        carAvailabilityMap[carId] = isAvailable;
        cars.add(car);
      }

      ownerCars.value = cars;
      print('Loaded ${cars.length} cars for owner: ${ownerName.value}');
    } catch (e) {
      print('Error loading owner cars: $e');
    } finally {
      isLoading.value = false;
    }
  }

  String _getCarKey(CarModel.Car car) {
    return '${car.name}_${car.model}_${car.yearOfManufacture}_${car.demandPrice}';
  }

  String getCarKey(CarModel.Car car) {
    return _getCarKey(car);
  }
}
