import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/constants/app_color.dart';
import '../../../../core/models/car.dart';
import '../../../../core/services/remote_service.dart';
import '../../../../core/database/database_service.dart';
import '../../home/home_controller.dart';
import '../../wishlist/wishlist_controller.dart';
import '../../../routes/app_routes.dart';

class CarDetailController extends GetxController {
  Car? car;
  String? carId;
  final RxBool isLoading = true.obs;
  final RxInt selectedImageIndex = 0.obs;
  final RxBool isInWishlist = false.obs;
  final RxBool isUserCar = false.obs;
  final RxBool isCarSold = false.obs;
  final RxString sellerId = ''.obs;
  final RxString sellerName = ''.obs;
  final RxString sellerPhone = ''.obs;
  final RxBool isSubmittingInquiry = false.obs;
  final RxBool isDeletingCar = false.obs;

  @override
  void onInit() {
    super.onInit();
    _loadCarData();
  }

  @override
  void onReady() {
    super.onReady();
    if (car != null && car!.imagePaths.isNotEmpty) {
      selectedImageIndex.value = 0;
    }
  }

  Future<void> _loadCarData() async {
    try {
      isLoading.value = true;
      final dynamic args = Get.arguments;

      if (args is Map && args['car'] != null) {
        final carArg = args['car'];
        if (carArg is Car) {
          car = carArg;
          carId = args['carId'] as String?;

          // Always try to get carId if not provided
          if (carId == null) {
            if (Get.isRegistered<HomeController>()) {
              try {
                final homeController = Get.find<HomeController>();
                final carKey =
                    '${car!.name}_${car!.model}_${car!.yearOfManufacture}_${car!.demandPrice}';
                carId = homeController.carIdMap[carKey];
                print('Car ID from HomeController: $carId');
              } catch (e) {
                print('Error getting carId from HomeController: $e');
              }
            }
          }

          // Always try to fetch full data from Firebase if carId is available
          if (carId != null && carId!.isNotEmpty) {
            await _fetchFullCarData(carId!);
            await _checkWishlistStatus();
          } else {
            print('Warning: carId is null or empty, using provided car data');
            _parseDescriptionForDetails();
            sellerName.value = car?.owner.isNotEmpty == true
                ? car!.owner
                : 'Owner';
            // Check sold status from HomeController if available
            if (Get.isRegistered<HomeController>()) {
              try {
                final homeController = Get.find<HomeController>();
                final carKey =
                    '${car!.name}_${car!.model}_${car!.yearOfManufacture}_${car!.demandPrice}';
                final isAvailable =
                    homeController.carKeyAvailabilityMap[carKey] ?? true;
                isCarSold.value = !isAvailable;
              } catch (e) {
                print(
                  'Error checking car availability from HomeController: $e',
                );
              }
            }
            // Still try to check wishlist if possible
            await _checkWishlistStatus();
          }
        }
      } else if (args is Car) {
        car = args;
        if (car != null && Get.isRegistered<HomeController>()) {
          try {
            final homeController = Get.find<HomeController>();
            final carKey =
                '${car!.name}_${car!.model}_${car!.yearOfManufacture}_${car!.demandPrice}';
            carId = homeController.carIdMap[carKey];
            if (carId != null && carId!.isNotEmpty) {
              await _fetchFullCarData(carId!);
              await _checkWishlistStatus();
            } else {
              print(
                'CarId not found in HomeController, using provided car data',
              );
              _parseDescriptionForDetails();
              sellerName.value = car?.owner.isNotEmpty == true
                  ? car!.owner
                  : 'Owner';
              // Check sold status from HomeController
              try {
                final carKey =
                    '${car!.name}_${car!.model}_${car!.yearOfManufacture}_${car!.demandPrice}';
                final isAvailable =
                    homeController.carKeyAvailabilityMap[carKey] ?? true;
                isCarSold.value = !isAvailable;
              } catch (e) {
                print(
                  'Error checking car availability from HomeController: $e',
                );
              }
            }
          } catch (e) {
            print('Error getting carId from HomeController: $e');
            _parseDescriptionForDetails();
            sellerName.value = car?.owner.isNotEmpty == true
                ? car!.owner
                : 'Owner';
          }
        } else {
          _parseDescriptionForDetails();
          sellerName.value = car?.owner.isNotEmpty == true
              ? car!.owner
              : 'Owner';
        }
      } else {
        car = null;
      }
    } catch (e, stackTrace) {
      print('Error loading car data: $e');
      print('Stack trace: $stackTrace');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _checkWishlistStatus() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null || carId == null) {
        print(
          'Cannot check wishlist status: user=${user != null}, carId=$carId',
        );
        return;
      }

      if (!Get.isRegistered<RemoteService>()) {
        Get.put(RemoteService());
      }
      final remoteService = Get.find<RemoteService>();
      final wishlistIds = await remoteService.getWishlist(user.uid);
      print('Wishlist IDs: $wishlistIds');
      print('Checking if carId $carId is in wishlist');
      isInWishlist.value = wishlistIds.contains(carId);
      print('Wishlist status: ${isInWishlist.value}');
    } catch (e, stackTrace) {
      print('Error checking wishlist status: $e');
      print('Stack trace: $stackTrace');
    }
  }

  Future<void> toggleWishlist() async {
    try {
      print('=== toggleWishlist called ===');
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        print('User is null');
        Get.snackbar(
          'Error',
          'User not authenticated. Please login again.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      if (carId == null) {
        print('CarId is null, trying to get from HomeController');
        if (car != null && Get.isRegistered<HomeController>()) {
          try {
            final homeController = Get.find<HomeController>();
            final carKey =
                '${car!.name}_${car!.model}_${car!.yearOfManufacture}_${car!.demandPrice}';
            carId = homeController.carIdMap[carKey];
            print('CarId from HomeController: $carId');
          } catch (e) {
            print('Error getting carId from HomeController: $e');
          }
        }

        if (carId == null) {
          print('CarId is still null');
          Get.snackbar(
            'Error',
            'Car ID not found. Cannot update wishlist.',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
          return;
        }
      }

      if (car == null) {
        print('Car is null');
        Get.snackbar(
          'Error',
          'Car data not available',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      if (!Get.isRegistered<RemoteService>()) {
        Get.put(RemoteService());
      }
      final remoteService = Get.find<RemoteService>();

      final wasInWishlist = isInWishlist.value;
      print('Current wishlist status: $wasInWishlist');
      print('CarId: $carId');
      print('UserId: ${user.uid}');

      if (wasInWishlist) {
        print('Removing from wishlist...');
        await remoteService.removeFromWishlist(user.uid, carId!);
        isInWishlist.value = false;
        print('Removed from wishlist successfully');
        Get.snackbar(
          'Removed from Wishlist',
          '${car!.name} ${car!.model} removed from your wishlist',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange,
          colorText: Colors.white,
          duration: const Duration(seconds: 2),
        );
      } else {
        print('Adding to wishlist...');
        await remoteService.addToWishlist(user.uid, carId!);
        isInWishlist.value = true;
        print('Added to wishlist successfully');
        Get.snackbar(
          'Added to Wishlist',
          '${car!.name} ${car!.model} added to your wishlist',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 2),
        );
      }

      if (Get.isRegistered<HomeController>()) {
        try {
          final homeController = Get.find<HomeController>();
          if (wasInWishlist) {
            homeController.wishlistCarIds.remove(carId);
          } else {
            homeController.wishlistCarIds.add(carId!);
          }
          print('Updated HomeController wishlist');
        } catch (e) {
          print('Error updating HomeController: $e');
        }
      }

      if (Get.isRegistered<WishlistController>()) {
        try {
          final wishlistController = Get.find<WishlistController>();
          await wishlistController.refreshWishlist();
          print('Refreshed WishlistController');
        } catch (e) {
          print('Error refreshing WishlistController: $e');
        }
      }
    } catch (e, stackTrace) {
      print('Error toggling wishlist: $e');
      print('Stack trace: $stackTrace');
      Get.snackbar(
        'Error',
        'Failed to update wishlist: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    }
  }

  Future<void> _fetchSellerName(String carUserId, RemoteService remoteService) async {
    try {
      final shopData = await remoteService.getUserShop(carUserId);
      final sellerData = await remoteService.getUser(carUserId);

      // Fetch seller/shop phone
      if (shopData != null && shopData['phone']?.toString().trim().isNotEmpty == true) {
        sellerPhone.value = shopData['phone'].toString();
      } else if (sellerData != null && sellerData['phone']?.toString().trim().isNotEmpty == true) {
        sellerPhone.value = sellerData['phone'].toString();
      }

      if (shopData != null && shopData['shopName']?.toString().trim().isNotEmpty == true) {
        sellerName.value = shopData['shopName'].toString();
        return;
      }
      if (sellerData != null) {
        sellerName.value =
            sellerData['shopName']?.toString() ??
            sellerData['name']?.toString() ??
            'Owner';
        return;
      }
    } catch (e) {
      print('Error fetching seller name/shop: $e');
    }
    sellerName.value = car?.owner.isNotEmpty == true
        ? car!.owner
        : 'Owner';
  }

  Future<void> _fetchFullCarData(String carId) async {
    try {
      print('Fetching full car data for carId: $carId');
      if (!Get.isRegistered<RemoteService>()) {
        Get.put(RemoteService());
      }
      final remoteService = Get.find<RemoteService>();
      final carData = await remoteService.getCarById(carId);

      if (carData != null) {
        print('Car data fetched from Firebase: $carData');

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

        // Use Firebase data first, fallback to description parsing, then to existing car data
        final fetchedCar = Car(
          name: carData['make'] as String? ?? car?.name ?? '',
          model: carData['model'] as String? ?? car?.model ?? '',
          yearOfManufacture:
              carData['year'] as String? ?? car?.yearOfManufacture ?? '',
          demandPrice: carData['price'] as String? ?? car?.demandPrice ?? '',
          variant: (carData['variant'] as String? ?? '').trim().isNotEmpty
              ? (carData['variant'] as String).trim()
              : ((descriptionParts['variant'] ?? '').trim().isNotEmpty
                    ? descriptionParts['variant']!.trim()
                    : (car?.variant ?? '')),
          color: (carData['color'] as String? ?? '').trim().isNotEmpty
              ? (carData['color'] as String).trim()
              : ((descriptionParts['color'] ?? '').trim().isNotEmpty
                    ? descriptionParts['color']!.trim()
                    : (car?.color ?? '')),
          fuelType: (carData['fuelType'] as String? ?? '').trim().isNotEmpty
              ? (carData['fuelType'] as String).trim()
              : ((descriptionParts['fuelType'] ?? '').trim().isNotEmpty
                    ? descriptionParts['fuelType']!.trim()
                    : (car?.fuelType ?? '')),
          owner: (carData['owner'] as String? ?? '').trim().isNotEmpty
              ? (carData['owner'] as String).trim()
              : (car?.owner ?? ''),
          insurance: (carData['insurance'] as String? ?? '').trim().isNotEmpty
              ? (carData['insurance'] as String).trim()
              : (car?.insurance ?? ''),
          transmission:
              (carData['transmission'] as String? ?? '').trim().isNotEmpty
              ? (carData['transmission'] as String).trim()
              : (car?.transmission ?? ''),
          kmsDriven: (carData['kmsDriven'] as String? ?? '').trim().isNotEmpty
              ? (carData['kmsDriven'] as String).trim()
              : (car?.kmsDriven ?? ''),
          mileage: (carData['mileage'] as String? ?? '').trim().isNotEmpty
              ? (carData['mileage'] as String).trim()
              : (car?.mileage ?? ''),
          tankCapacity:
              (carData['tankCapacity'] as String? ?? '').trim().isNotEmpty
              ? (carData['tankCapacity'] as String).trim()
              : (car?.tankCapacity ?? ''),
          imagePaths: imageUrls.isNotEmpty
              ? imageUrls
              : (car?.imagePaths ?? []),
          seatType: carData['seatType'] as String? ?? car?.seatType ?? '5',
          licenseType:
              carData['licenseType'] as String? ??
              car?.licenseType ??
              'Non Commercial',
          state: carData['state'] as String? ?? car?.state ?? '',
          city: carData['city'] as String? ?? car?.city ?? '',
          pincode: carData['pincode'] as String? ?? car?.pincode ?? '',
        );

        print('Updated car with Firebase data:');
        print('  Name: ${fetchedCar.name}');
        print('  Model: ${fetchedCar.model}');
        print('  Variant: ${fetchedCar.variant}');
        print('  Owner: ${fetchedCar.owner}');
        print('  Color: ${fetchedCar.color}');
        print('  FuelType: ${fetchedCar.fuelType}');
        print('  Transmission: ${fetchedCar.transmission}');
        print('  Insurance: ${fetchedCar.insurance}');
        print('  KmsDriven: ${fetchedCar.kmsDriven}');
        print('  Mileage: ${fetchedCar.mileage}');
        print('  TankCapacity: ${fetchedCar.tankCapacity}');

        car = fetchedCar;

        // Check if car is sold
        final isAvailable = carData['isAvailable'] as bool? ?? true;
        isCarSold.value = !isAvailable;

        // Also check from HomeController if available
        if (Get.isRegistered<HomeController>()) {
          try {
            final homeController = Get.find<HomeController>();
            final carKey =
                '${car!.name}_${car!.model}_${car!.yearOfManufacture}_${car!.demandPrice}';
            final carIdFromMap = homeController.carIdMap[carKey];
            if (carIdFromMap != null) {
              final isAvailableFromMap =
                  homeController.carKeyAvailabilityMap[carKey] ?? true;
              isCarSold.value = !isAvailableFromMap;
            }
          } catch (e) {
            print('Error checking car availability from HomeController: $e');
          }
        }

        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          final carUserId = carData['userId'] as String?;
          isUserCar.value = carUserId == user.uid;

          if (carUserId != null && carUserId.isNotEmpty) {
            sellerId.value = carUserId;
            await _fetchSellerName(carUserId, remoteService);
          } else {
            sellerName.value = car?.owner.isNotEmpty == true
                ? car!.owner
                : 'Owner';
          }
        } else {
          isUserCar.value = false;
          final carUserId = carData['userId'] as String?;
          if (carUserId != null && carUserId.isNotEmpty) {
            sellerId.value = carUserId;
            await _fetchSellerName(carUserId, remoteService);
          } else {
            sellerName.value = car?.owner.isNotEmpty == true
                ? car!.owner
                : 'Owner';
          }
        }

        update();
      } else {
        print('No car data found in Firebase for carId: $carId');
      }
    } catch (e, stackTrace) {
      print('Error fetching full car data: $e');
      print('Stack trace: $stackTrace');
    }
  }

  void _parseDescriptionForDetails() {
    if (car != null &&
        car!.variant.isEmpty &&
        car!.color.isEmpty &&
        car!.fuelType.isEmpty) {
      final description = car!.owner.isNotEmpty ? car!.owner : '';
      if (description.isNotEmpty) {
        final descriptionParts = _parseDescription(description);
        car = car!.copyWith(
          variant: descriptionParts['variant'] ?? '',
          color: descriptionParts['color'] ?? '',
          fuelType: descriptionParts['fuelType'] ?? '',
        );
        update();
      }
    }
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

  void selectImage(int index) {
    if (car != null && index >= 0 && index < car!.imagePaths.length) {
      selectedImageIndex.value = index;
    }
  }

  Future<void> editCar() async {
    if (car == null || carId == null || carId!.isEmpty) {
      Get.snackbar(
        'Error',
        'Car data not available for editing',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    try {
      Get.dialog(
        const Center(child: CircularProgressIndicator()),
        barrierDismissible: false,
      );

      if (!Get.isRegistered<RemoteService>()) {
        Get.put(RemoteService());
      }
      final remoteService = Get.find<RemoteService>();

      final carData = await remoteService.getCarById(carId!);

      Get.back();

      if (carData == null) {
        Get.snackbar(
          'Error',
          'Could not load car data. Please try again.',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

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
      } else if (car!.imagePaths.isNotEmpty) {
        imageUrls = car!.imagePaths;
      }

      Get.toNamed(
        AppRoutes.addCar,
        arguments: {
          'editMode': true,
          'carId': carId,
          'name': carData['make'] ?? car!.name ?? '',
          'model': carData['model'] ?? car!.model ?? '',
          'year': carData['year'] ?? car!.yearOfManufacture ?? '',
          'price': carData['price'] ?? car!.demandPrice ?? '',
          'variant': carData['variant'] ?? car!.variant ?? '',
          'color': carData['color'] ?? car!.color ?? '',
          'fuelType': carData['fuelType'] ?? car!.fuelType ?? '',
          'owner': carData['owner'] ?? car!.owner ?? '',
          'transmission': carData['transmission'] ?? car!.transmission ?? '',
          'insurance': carData['insurance'] ?? car!.insurance ?? '',
          'kmsDriven': carData['kmsDriven'] ?? car!.kmsDriven ?? '',
          'mileage': carData['mileage'] ?? car!.mileage ?? '',
          'tankCapacity': carData['tankCapacity'] ?? car!.tankCapacity ?? '',
          'imageUrls': imageUrls,
          'imageUrl': imageUrls.isNotEmpty ? imageUrls.first : '',
        },
      );
    } catch (e) {
      Get.back();
      Get.snackbar(
        'Error',
        'Failed to load car data: ${e.toString()}',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> inquireAboutCar() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        Get.snackbar(
          'Error',
          'Please login to inquire about this car',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      if (car == null || carId == null || carId!.isEmpty) {
        Get.snackbar(
          'Error',
          'Car data not available',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      isSubmittingInquiry.value = true;

      if (!Get.isRegistered<RemoteService>()) {
        Get.put(RemoteService());
      }
      final remoteService = Get.find<RemoteService>();

      // Add timeout to prevent hanging
      final carData = await remoteService
          .getCarById(carId!)
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () {
              throw Exception('Request timed out while fetching car details');
            },
          );

      if (carData == null) {
        isSubmittingInquiry.value = false;
        Get.snackbar(
          'Error',
          'Could not fetch car details',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      final sellerId = carData['userId'] as String?;
      if (sellerId == null || sellerId.isEmpty) {
        isSubmittingInquiry.value = false;
        Get.snackbar(
          'Error',
          'Seller information not available',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      if (sellerId == user.uid) {
        isSubmittingInquiry.value = false;
        Get.snackbar(
          'Info',
          'This is your own car listing',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
        return;
      }

      final userData = await remoteService
          .getUser(user.uid)
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () {
              throw Exception('Request timed out while fetching user details');
            },
          );

      final buyerName =
          userData?['name']?.toString() ?? user.displayName ?? 'User';
      final buyerEmail = user.email ?? '';

      // Add timeout to the inquiry notification
      await remoteService
          .sendInquiryNotification(
            buyerId: user.uid,
            buyerName: buyerName,
            buyerEmail: buyerEmail,
            sellerId: sellerId,
            carId: carId!,
            carName: car!.name,
            carModel: car!.model,
            carPrice: car!.demandPrice,
            carImageUrl: car!.imagePaths.isNotEmpty ? car!.imagePaths.first : null,
          )
          .timeout(
            const Duration(seconds: 15),
            onTimeout: () {
              throw Exception('Request timed out while sending inquiry');
            },
          );

      isSubmittingInquiry.value = false;
      
      Get.defaultDialog(
        title: 'Success',
        middleText: 'Your inquiry has been sent to the seller and admin successfully.',
        titleStyle: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
        textConfirm: 'OK',
        confirmTextColor: Colors.white,
        buttonColor: AppColor.secondary,
        onConfirm: () {
          Get.back();
        },
        radius: 10,
        barrierDismissible: false,
      );
    } catch (e) {
      isSubmittingInquiry.value = false;

      String errorMessage = 'Failed to send inquiry';
      if (e.toString().contains('timed out')) {
        errorMessage =
            'Request timed out. Please check your internet connection and try again.';
      } else {
        errorMessage = 'Failed to send inquiry: ${e.toString()}';
      }

      Get.snackbar(
        'Error',
        errorMessage,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    }
  }

  Future<void> callSeller() async {
    try {
      final phone = sellerPhone.value.trim();
      if (phone.isEmpty) {
        Get.snackbar(
          'Error',
          'Phone number not available for this seller',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }
      
      final phoneUri = Uri.parse('tel:$phone');
      if (await canLaunchUrl(phoneUri)) {
        await launchUrl(phoneUri);
      } else {
        Get.snackbar(
          'Error',
          'Could not launch phone dialer',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to call: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  void viewOwnerCars() {
    if (sellerId.value.isEmpty) {
      Get.snackbar(
        'Error',
        'Owner information not available',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    Get.toNamed(
      AppRoutes.ownerCars,
      arguments: {'ownerId': sellerId.value, 'ownerName': sellerName.value},
    );
  }

  Future<void> deleteCar() async {
    if (car == null || carId == null || carId!.isEmpty) {
      Get.snackbar(
        'Error',
        'Car data not available for deletion',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      Get.snackbar(
        'Error',
        'User not authenticated. Please login again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    // Show confirmation dialog
    final confirm = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Delete Car'),
        content: Text(
          'Are you sure you want to delete ${car!.name} ${car!.model}? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm != true) {
      return;
    }

    try {
      isDeletingCar.value = true;

      if (!Get.isRegistered<RemoteService>()) {
        Get.put(RemoteService());
      }
      final remoteService = Get.find<RemoteService>();

      await remoteService.deleteCar(user.uid, carId!);

      if (Get.isRegistered<DatabaseService>()) {
        try {
          final databaseService = Get.find<DatabaseService>();
          await databaseService.deleteCar(carId!);
        } catch (e) {
          print('Error deleting car from local DB: $e');
        }
      }

      Get.back(); // Close car detail page

      Get.snackbar(
        'Success',
        'Car deleted successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );

      // Refresh home controller if registered
      if (Get.isRegistered<HomeController>()) {
        try {
          final homeController = Get.find<HomeController>();
          await homeController.refreshCars();
        } catch (e) {
          print('Error refreshing HomeController: $e');
        }
      }
    } catch (e) {
      isDeletingCar.value = false;
      Get.snackbar(
        'Error',
        'Failed to delete car: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    }
  }
}
