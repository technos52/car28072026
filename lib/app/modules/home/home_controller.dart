import 'dart:async';
import 'dart:convert';
import 'package:get/get.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/services/remote_service.dart';
import '../../../core/database/database_service.dart';
import '../../../core/models/car.dart' as CarModel;
import '../../../core/utils/carousel_setup.dart';
import '../../routes/app_routes.dart';
import '../search/controller/search_controller.dart' as search_ctrl;

class HomeController extends GetxController with WidgetsBindingObserver {
  final RxInt currentIndex = 0.obs;
  void setIndex(int i) => currentIndex.value = i;

  final RxList<String> carouselImages = <String>[].obs;
  final RxInt currentCarouselImage = 0.obs;
  PageController _carouselController = PageController(initialPage: 1000);
  PageController get carouselController {
    try {
      final _ = _carouselController.hasClients;
    } catch (_) {
      _carouselController = PageController(initialPage: 1000);
    }
    return _carouselController;
  }
  Timer? _carouselTimer;
  bool _isCarouselAnimating = false;

  final RxString userName = ''.obs;
  final RxString userAvatarUrl = ''.obs;
  final RxString shopName = ''.obs;

  String getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good Morning';
    } else if (hour < 17) {
      return 'Good Afternoon';
    } else if (hour < 21) {
      return 'Good Evening';
    } else {
      return 'Good Night';
    }
  }

  final RxList<CarModel.Car> userCars = <CarModel.Car>[].obs;
  final RxList<CarModel.Car> otherCars = <CarModel.Car>[].obs;
  final RxList<CarModel.Car> allOtherCars = <CarModel.Car>[].obs;
  final RxList<CarModel.Car> topDealsCars = <CarModel.Car>[].obs;
  final RxList<String> brands = <String>[].obs;
  final RxString selectedBrand = ''.obs;
  TextEditingController _searchController = TextEditingController();
  TextEditingController get searchController {
    try {
      final _ = _searchController.text;
    } catch (_) {
      _searchController = TextEditingController(text: searchQuery.value);
    }
    return _searchController;
  }
  final RxString searchQuery = ''.obs;
  final RxList<String> filteredBrandSuggestions = <String>[].obs;
  final RxList<String> filteredDealerSuggestions = <String>[].obs;
  final RxList<Map<String, dynamic>> carSuggestions =
      <Map<String, dynamic>>[].obs;
  ScrollController _brandsScrollController = ScrollController();
  ScrollController get brandsScrollController {
    try {
      final _ = _brandsScrollController.hasClients;
    } catch (_) {
      _brandsScrollController = ScrollController();
    }
    return _brandsScrollController;
  }
  Timer? _brandsScrollTimer;

  final Map<String, String> carIdMap = {};
  final Map<String, bool> carAvailabilityMap = {};
  final Map<String, bool> carKeyAvailabilityMap = {};
  final RxSet<String> wishlistCarIds = <String>{}.obs;

  String _getCarKey(CarModel.Car car) {
    return '${car.name}_${car.model}_${car.yearOfManufacture}_${car.demandPrice}';
  }

  String getCarKey(CarModel.Car car) {
    return _getCarKey(car);
  }

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
    _loadUserData();
    _loadCars();
    _loadWishlist();
    _loadCarouselImages();
    _startCarouselAutoPlay();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      refreshCars();
    }
  }

  Future<void> _loadCarouselImages() async {
    try {
      // Ensure RemoteService is registered only once
      if (!Get.isRegistered<RemoteService>()) {
        Get.put(RemoteService());
      }
      final remoteService = Get.find<RemoteService>();
      final images = await remoteService.getCarouselImages();

      // Simply load images if they exist, don't auto-add samples
      carouselImages.clear();
      carouselImages.addAll(images);

      print('Loaded ${carouselImages.length} carousel images from Firebase');

      if (carouselImages.isNotEmpty) {
        _startCarouselAutoPlay();
      }
    } catch (e) {
      print('Error loading carousel images: $e');
    }
  }

  void _startCarouselAutoPlay() {
    _carouselTimer?.cancel();
    if (carouselImages.length <= 1) {
      return;
    }
    _carouselTimer = Timer.periodic(const Duration(milliseconds: 4000), (
      timer,
    ) {
      if (isClosed || !carouselController.hasClients || _isCarouselAnimating) {
        return;
      }
      try {
        final currentPosition = carouselController.page?.round() ?? 1000;
        final nextPage = currentPosition + 1;
        _isCarouselAnimating = true;
        carouselController
            .animateToPage(
              nextPage,
              duration: const Duration(milliseconds: 800),
              curve: Curves.easeInOutCubic,
            )
            .then((_) {
              if (!isClosed) {
                _isCarouselAnimating = false;
                currentCarouselImage.value = nextPage % carouselImages.length;
              }
            })
            .catchError((error) {
              _isCarouselAnimating = false;
            });
      } catch (e) {
        _isCarouselAnimating = false;
      }
    });
  }

  void _stopCarouselAutoPlay() {
    _carouselTimer?.cancel();
    _carouselTimer = null;
  }

  Future<void> _loadWishlist() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        // Ensure RemoteService is registered only once
        if (!Get.isRegistered<RemoteService>()) {
          Get.put(RemoteService());
        }
        final remoteService = Get.find<RemoteService>();
        final wishlistIds = await remoteService.getWishlist(user.uid);
        wishlistCarIds.clear();
        wishlistCarIds.addAll(wishlistIds);
      }
    } catch (e) {
      print('Error loading wishlist: $e');
    }
  }

  Future<void> toggleWishlistById(String carId) async {
    try {
      print('toggleWishlistById called for carId: $carId');
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        Get.snackbar(
          'Login Required',
          'Please sign in to save cars to your wishlist',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.black87,
          colorText: Colors.white,
        );
        return;
      }

      if (!Get.isRegistered<RemoteService>()) {
        Get.put(RemoteService());
      }
      final remoteService = Get.find<RemoteService>();

      final isCurrentlyWishlisted = wishlistCarIds.contains(carId);

      if (isCurrentlyWishlisted) {
        print('Removing $carId from wishlist...');
        await remoteService.removeFromWishlist(user.uid, carId);
        wishlistCarIds.remove(carId);
        Get.snackbar(
          'Wishlist',
          'Removed from wishlist',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.black87,
          colorText: Colors.white,
          duration: const Duration(seconds: 2),
        );
      } else {
        print('Adding $carId to wishlist...');
        await remoteService.addToWishlist(user.uid, carId);
        wishlistCarIds.add(carId);
        Get.snackbar(
          'Wishlist',
          'Added to wishlist',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.black87,
          colorText: Colors.white,
          duration: const Duration(seconds: 2),
        );
      }
    } catch (e, stackTrace) {
      print('Error toggling wishlist by ID: $e');
      print('Stack trace: $stackTrace');
    }
  }

  Future<void> toggleWishlist(CarModel.Car car) async {
    try {
      print('toggleWishlist called for car: ${car.name} ${car.model}');
      final carKey = _getCarKey(car);
      final carId = carIdMap[carKey];
      if (carId == null || carId.isEmpty) {
        print('Car ID is null or empty, cannot toggle wishlist');
        return;
      }
      await toggleWishlistById(carId);
    } catch (e, stackTrace) {
      print('Error toggling wishlist: $e');
      print('Stack trace: $stackTrace');
    }
  }

  bool isInWishlist(CarModel.Car car) {
    final carKey = _getCarKey(car);
    final carId = carIdMap[carKey];
    return carId != null && wishlistCarIds.contains(carId);
  }

  Future<void> _loadBrands() async {
    try {
      final brandsSet = <String>{};

      for (var car in allOtherCars) {
        if (car.name.isNotEmpty) {
          brandsSet.add(car.name);
        }
      }

      for (var car in userCars) {
        if (car.name.isNotEmpty) {
          brandsSet.add(car.name);
        }
      }

      if (!Get.isRegistered<RemoteService>()) {
        Get.put(RemoteService());
      }
      final remoteService = Get.find<RemoteService>();

      try {
        final uniqueBrands = await remoteService.getUniqueBrands();
        brandsSet.addAll(uniqueBrands);
      } catch (e) {
        print('Error loading brands from Firebase: $e');
      }

      final brandsList = brandsSet.toList()..sort();
      brands.clear();
      brands.addAll(brandsList);
      print('Loaded ${brands.length} brands: ${brands.take(5).toList()}');

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (brandsScrollController.hasClients) {
          startBrandsAutoScroll();
        }
      });
    } catch (e) {
      print('Error loading brands: $e');
    }
  }

  Future<void> selectBrand(String brand) async {
    final brandTrimmed = brand.trim();
    // Navigate to Search page as a separate route since Search tab is now My Cars
    await Get.toNamed(AppRoutes.search, arguments: {'brand': brandTrimmed});
    refreshCars();
  }

  void onSearchChanged(String query) {
    searchQuery.value = query;

    // Clear suggestions if query is empty
    if (query.isEmpty) {
      filteredBrandSuggestions.clear();
      filteredDealerSuggestions.clear();
      carSuggestions.clear();
      selectedBrand.value = '';
      return;
    }

    final queryLower = query.toLowerCase().trim();

    // Filter brand suggestions
    final currentBrands = List<String>.from(brands);
    final brandSuggestions = currentBrands
        .where((brand) => brand.toLowerCase().contains(queryLower))
        .toList();

    filteredBrandSuggestions.clear();
    filteredBrandSuggestions.addAll(brandSuggestions);

    // Combine all cars
    final allCars = <CarModel.Car>[...userCars, ...allOtherCars];

    // Filter dealer suggestions
    final uniqueDealers = allCars
        .map((car) => car.dealerName)
        .where((name) => name.isNotEmpty)
        .toSet()
        .toList();

    final dealerSuggestionsList = uniqueDealers
        .where((dealer) => dealer.toLowerCase().contains(queryLower))
        .toList();

    filteredDealerSuggestions.clear();
    filteredDealerSuggestions.addAll(dealerSuggestionsList);

    final matchingCars = allCars
        .where((car) {
          final carName = '${car.name} ${car.model}'.toLowerCase();
          final carYear = car.yearOfManufacture.toLowerCase();
          final carFuel = car.fuelType.toLowerCase();

          return carName.contains(queryLower) ||
              carYear.contains(queryLower) ||
              carFuel.contains(queryLower);
        })
        .take(5)
        .toList(); // Limit to 5 suggestions

    // Convert cars to suggestion format with car ID
    carSuggestions.clear();
    for (var car in matchingCars) {
      final carKey = _getCarKey(car);
      final carId = carIdMap[carKey];
      if (carId != null) {
        final dealerSuffix = car.dealerName.isNotEmpty ? ' by ${car.dealerName}' : '';
        carSuggestions.add({
          'car': car,
          'carId': carId,
          'displayText': '${car.name} ${car.model} (${car.yearOfManufacture})$dealerSuffix',
        });
      }
    }

    // Handle brand selection
    String? exactMatch;
    try {
      exactMatch = currentBrands.firstWhere(
        (brand) => brand.toLowerCase() == queryLower,
      );
    } catch (e) {
      exactMatch = null;
    }

    if (exactMatch != null && filteredBrandSuggestions.length == 1) {
      selectedBrand.value = exactMatch;
    } else {
      if (selectedBrand.value.isEmpty ||
          selectedBrand.value.toLowerCase() != queryLower) {
        selectedBrand.value = '';
      }
    }

    _filterCars();
  }

  void selectBrandFromSearch(String brand) {
    selectedBrand.value = brand;
    searchController.text = brand;
    searchQuery.value = brand;
    filteredBrandSuggestions.clear();
    filteredDealerSuggestions.clear();
    carSuggestions.clear();
    _filterCars();

    if (Get.isRegistered<search_ctrl.SearchController>()) {
      final searchCtrl = Get.find<search_ctrl.SearchController>();
      searchCtrl.query.value = brand;
      searchCtrl.applyFilters();
    }
  }

  void selectDealerFromSearch(String dealer) {
    searchController.text = dealer;
    searchQuery.value = dealer;
    filteredBrandSuggestions.clear();
    filteredDealerSuggestions.clear();
    carSuggestions.clear();

    if (Get.isRegistered<search_ctrl.SearchController>()) {
      final searchCtrl = Get.find<search_ctrl.SearchController>();
      searchCtrl.query.value = dealer;
      searchCtrl.applyFilters();
    }
  }

  Future<void> selectCarFromSuggestions(Map<String, dynamic> carSuggestion) async {
    // Navigate to car detail page
    final car = carSuggestion['car'] as CarModel.Car;
    final carId = carSuggestion['carId'] as String;

    // Clear suggestions but keep search
    carSuggestions.clear();
    filteredBrandSuggestions.clear();

    // Navigate to car detail
    await Get.toNamed(AppRoutes.carDetail, arguments: {'car': car, 'carId': carId});
    refreshCars();
  }

  void clearSearch() {
    searchController.clear();
    searchQuery.value = '';
    selectedBrand.value = '';
    filteredBrandSuggestions.clear();
    filteredDealerSuggestions.clear();
    carSuggestions.clear();
    _filterCars();
  }

  void _filterCars() {
    final soldCars = allOtherCars.where((car) {
      final carKey = _getCarKey(car);
      final isAvailable = carKeyAvailabilityMap[carKey] ?? true;
      return !isAvailable;
    }).toList();
    topDealsCars.value = soldCars
        .take(50)
        .toList(); // Increased from 12 to show more cars
  }

  void _loadUserData() async {
    await refreshUserData();
  }

  Future<void> _loadCars() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await refreshUserData(); // Ensure user data is loaded before building cars
        // Ensure services are registered only once
        if (!Get.isRegistered<DatabaseService>()) {
          await Get.putAsync<DatabaseService>(() async => DatabaseService());
        }
        if (!Get.isRegistered<RemoteService>()) {
          Get.put(RemoteService());
        }

        final databaseService = Get.find<DatabaseService>();
        final remoteService = Get.find<RemoteService>();

        // Load from Firestore first (cloud), then sync to local DB
        List<Map<String, dynamic>> firestoreCars = [];
        try {
          print('Loading cars from Firestore...');
          firestoreCars = await remoteService.getUserCars(user.uid);
          print('Found ${firestoreCars.length} cars in Firestore');

          // Delete cars that are no longer in Firestore
          final firestoreCarIds = firestoreCars.map((c) => c['id'] as String).toList();
          final localUserCars = await databaseService.getUserCars(user.uid);
          for (var localCar in localUserCars) {
            if (!firestoreCarIds.contains(localCar.id)) {
              await databaseService.deleteCar(localCar.id);
            }
          }

          // Sync Firestore cars to local database
          for (var carData in firestoreCars) {
            // Handle imageUrls array or single imageUrl
            String? imageUrlToSave;
            if (carData['imageUrls'] != null && carData['imageUrls'] is List) {
              // Convert array to JSON string for local DB
              final imageUrls = carData['imageUrls'] as List;
              imageUrlToSave = jsonEncode(imageUrls);
            } else if (carData['imageUrl'] != null) {
              imageUrlToSave = carData['imageUrl'] as String;
            }

            await databaseService.saveCar(
              id: carData['id'] as String,
              userId: user.uid,
              make: carData['make'] as String? ?? '',
              model: carData['model'] as String? ?? '',
              year: carData['year'] as String? ?? '',
              price: carData['price'] as String? ?? '',
              imageUrl: imageUrlToSave,
              description: carData['description'] as String?,
              isAvailable: carData['isAvailable'] as bool? ?? true,
            );
          }
        } catch (e) {
          print('Error loading from Firestore, using local DB: $e');
        }

        userCars.clear();

        if (firestoreCars.isNotEmpty) {
          for (var carData in firestoreCars) {
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
              name: carData['make'] as String? ?? '',
              variant: carData['variant'] as String? ?? '',
              yearOfManufacture: carData['year'] as String? ?? '',
              owner: carData['owner'] as String? ?? '',
              color: _parseColorFromData(carData),
              model: carData['model'] as String? ?? '',
              fuelType: carData['fuelType'] as String? ?? '',
              insurance: carData['insurance'] as String? ?? '',
              transmission: carData['transmission'] as String? ?? '',
              demandPrice: carData['price'] as String? ?? '',
              kmsDriven: carData['kmsDriven'] as String? ?? '',
              mileage: carData['mileage'] as String? ?? '',
              tankCapacity: carData['tankCapacity'] as String? ?? '',
              imagePaths: imageUrls,
              dealerName: carData['dealerName'] as String? ?? (shopName.value.isNotEmpty ? shopName.value : userName.value),
              seatType: carData['seatType'] as String? ?? '5',
              licenseType: carData['licenseType']?.toString() ??
                  carData['license_type']?.toString() ??
                  carData['license']?.toString() ??
                  'Non Commercial',
              state: carData['state'] as String? ?? '',
              city: carData['city'] as String? ?? '',
              pincode: carData['pincode'] as String? ?? '',
            );

            final carId = carData['id'] as String;
            final isAvailable = carData['isAvailable'] as bool? ?? true;
            final carKey = _getCarKey(car);
            userCars.add(car);
            carIdMap[carKey] = carId;
            carAvailabilityMap[carId] = isAvailable;
            carKeyAvailabilityMap[carKey] = isAvailable;
          }
        } else {
          // Load from local database if Firestore returned no cars or error
          final dbCars = await databaseService.getUserCars(user.uid);
          dbCars.sort((a, b) => b.id.compareTo(a.id));

          for (var dbCar in dbCars) {
            List<String> imageUrls = [];
            if (dbCar.imageUrl != null && dbCar.imageUrl!.isNotEmpty) {
              if (dbCar.imageUrl!.startsWith('[') &&
                  dbCar.imageUrl!.endsWith(']')) {
                try {
                  final List<dynamic> parsed = jsonDecode(dbCar.imageUrl!);
                  imageUrls = parsed.cast<String>();
                } catch (e) {
                  imageUrls = [dbCar.imageUrl!];
                }
              } else {
                imageUrls = [dbCar.imageUrl!];
              }
            }

            final car = CarModel.Car(
              name: dbCar.make,
              variant: '',
              yearOfManufacture: dbCar.year,
              owner: '',
              color: '',
              model: dbCar.model,
              fuelType: '',
              insurance: '',
              transmission: '',
              demandPrice: dbCar.price,
              kmsDriven: '',
              mileage: '',
              tankCapacity: '',
              imagePaths: imageUrls,
              dealerName: shopName.value.isNotEmpty ? shopName.value : userName.value,
              seatType: '5',
              licenseType: 'Non Commercial',
            );
            final carKey = _getCarKey(car);
            final carId = dbCar.id;
            final isAvailable = dbCar.isAvailable;
            userCars.add(car);
            carIdMap[carKey] = carId;
            carAvailabilityMap[carId] = isAvailable;
            carKeyAvailabilityMap[carKey] = isAvailable;
          }
        }

        // Load other cars from Firestore
        List<Map<String, dynamic>> firestoreOtherCars = [];
        try {
          firestoreOtherCars = await remoteService.getAllCars(
            excludeUserId: user.uid,
          );
          print('Found ${firestoreOtherCars.length} other cars in Firestore');

          // Delete other cars that are no longer in Firestore
          final firestoreOtherCarIds = firestoreOtherCars.map((c) => c['id'] as String).toList();
          final localAllCars = await databaseService.getAllCars();
          for (var localCar in localAllCars) {
            if (localCar.userId != user.uid && !firestoreOtherCarIds.contains(localCar.id)) {
              await databaseService.deleteCar(localCar.id);
            }
          }

          // Sync other cars to local DB
          for (var carData in firestoreOtherCars) {
            // Handle imageUrls array or single imageUrl
            String? imageUrlToSave;
            if (carData['imageUrls'] != null && carData['imageUrls'] is List) {
              // Convert array to JSON string for local DB
              final imageUrls = carData['imageUrls'] as List;
              imageUrlToSave = jsonEncode(imageUrls);
            } else if (carData['imageUrl'] != null) {
              imageUrlToSave = carData['imageUrl'] as String;
            }

            await databaseService.saveCar(
              id: carData['id'] as String,
              userId: carData['userId'] as String? ?? '',
              make: carData['make'] as String? ?? '',
              model: carData['model'] as String? ?? '',
              year: carData['year'] as String? ?? '',
              price: carData['price'] as String? ?? '',
              imageUrl: imageUrlToSave,
              description: carData['description'] as String?,
              isAvailable: carData['isAvailable'] as bool? ?? true,
            );
          }
        } catch (e) {
          print('Error loading other cars from Firestore: $e');
        }

        allOtherCars.clear();
        topDealsCars.clear();

        final sortedFirestoreCars = firestoreOtherCars;

        final topDealsCount = 50; // Increased from 12 to show more cars

        for (var carData in sortedFirestoreCars) {
          // Parse image URLs - can be JSON array string or single URL
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
            name: carData['make'] as String? ?? '',
            variant: carData['variant'] as String? ?? '',
            yearOfManufacture: carData['year'] as String? ?? '',
            owner: carData['owner'] as String? ?? '',
            color: _parseColorFromData(carData),
            model: carData['model'] as String? ?? '',
            fuelType: carData['fuelType'] as String? ?? '',
            insurance: carData['insurance'] as String? ?? '',
            transmission: carData['transmission'] as String? ?? '',
            demandPrice: carData['price'] as String? ?? '',
            kmsDriven: carData['kmsDriven'] as String? ?? '',
            mileage: carData['mileage'] as String? ?? '',
            tankCapacity: carData['tankCapacity'] as String? ?? '',
            imagePaths: imageUrls,
            dealerName: carData['dealerName'] as String? ?? '',
            seatType: carData['seatType'] as String? ?? '5',
            licenseType: carData['licenseType']?.toString() ??
                carData['license_type']?.toString() ??
                carData['license']?.toString() ??
                'Non Commercial',
            state: carData['state'] as String? ?? '',
            city: carData['city'] as String? ?? '',
            pincode: carData['pincode'] as String? ?? '',
          );

          final carId = carData['id'] as String;
          final isAvailable = carData['isAvailable'] as bool? ?? true;
          final carKey = _getCarKey(car);
          allOtherCars.add(car);
          carIdMap[carKey] = carId;
          carAvailabilityMap[carId] = isAvailable;
          carKeyAvailabilityMap[carKey] = isAvailable;
        }

        final soldCars = allOtherCars.where((car) {
          final carKey = _getCarKey(car);
          final isAvailable = carKeyAvailabilityMap[carKey] ?? true;
          return !isAvailable;
        }).toList();

        print(
          'DEBUG: Total cars loaded: ${allOtherCars.length}, Sold cars found: ${soldCars.length}',
        );
        if (soldCars.isNotEmpty) {
          print(
            'DEBUG: First sold car - ${soldCars.first.name} ${soldCars.first.model}, isAvailable=${carKeyAvailabilityMap[_getCarKey(soldCars.first)]}',
          );
        }

        topDealsCars.addAll(soldCars.take(topDealsCount));

        if (firestoreOtherCars.isEmpty) {
          final allCars = await databaseService.getAllCars();
          for (var dbCar in allCars) {
            if (dbCar.userId != user.uid) {
              bool alreadyAdded = allOtherCars.any(
                (car) =>
                    car.name == dbCar.make &&
                    car.model == dbCar.model &&
                    car.demandPrice == dbCar.price,
              );

              if (!alreadyAdded) {
                List<String> imageUrls = [];
                if (dbCar.imageUrl != null && dbCar.imageUrl!.isNotEmpty) {
                  if (dbCar.imageUrl!.startsWith('[') &&
                      dbCar.imageUrl!.endsWith(']')) {
                    try {
                      final List<dynamic> parsed = jsonDecode(dbCar.imageUrl!);
                      imageUrls = parsed.cast<String>();
                    } catch (e) {
                      imageUrls = [dbCar.imageUrl!];
                    }
                  } else {
                    imageUrls = [dbCar.imageUrl!];
                  }
                }

                final car = CarModel.Car(
                  name: dbCar.make,
                  variant: '',
                  yearOfManufacture: dbCar.year,
                  owner: '',
                  color: '',
                  model: dbCar.model,
                  fuelType: '',
                  insurance: '',
                  transmission: '',
                  demandPrice: dbCar.price,
                  kmsDriven: '',
                  mileage: '',
                  tankCapacity: '',
                  imagePaths: imageUrls,
                  seatType: '5',
                  licenseType: 'Non Commercial',
                );

                final carKey = _getCarKey(car);
                final carId = dbCar.id;
                final isAvailable = dbCar.isAvailable;
                allOtherCars.add(car);
                carIdMap[carKey] = carId;
                carAvailabilityMap[carId] = isAvailable;
                carKeyAvailabilityMap[carKey] = isAvailable;
              }
            }
          }
        }

        await _loadWishlist();

        print(
          'Loaded ${userCars.length} user cars, ${allOtherCars.length} other cars, and ${topDealsCars.length} top deals',
        );

        await _loadBrands();
        _filterCars();
        if (Get.isRegistered<search_ctrl.SearchController>()) {
          Get.find<search_ctrl.SearchController>().refreshSearchData();
        }
      }
    } catch (e) {
      print('Error loading cars: $e');
    }
  }

  Future<void> refreshCars() async {
    await _loadCars();
    await _loadBrands();
    await _loadCarouselImages();
  }

  Future<void> refreshUserData() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        if (!Get.isRegistered<RemoteService>()) {
          Get.put(RemoteService());
        }
        if (!Get.isRegistered<DatabaseService>()) {
          await Get.putAsync<DatabaseService>(() async => DatabaseService());
        }

        final remoteService = Get.find<RemoteService>();
        final databaseService = Get.find<DatabaseService>();

        final userData = await remoteService.getUser(user.uid);
        if (userData != null) {
          userName.value =
              userData['name']?.toString() ?? user.displayName ?? 'User';
          final savedAvatar = userData['avatarUrl']?.toString() ?? '';
          if (savedAvatar.isNotEmpty) {
            userAvatarUrl.value = savedAvatar;
          } else {
            userAvatarUrl.value = '';
          }
        } else {
          final localUser = await databaseService.getUser(user.uid);
          if (localUser != null) {
            userName.value = localUser.name;
            userAvatarUrl.value = localUser.avatarUrl ?? '';
          } else {
            userName.value = user.displayName ?? 'User';
            userAvatarUrl.value = '';
          }
        }

        final shopData = await remoteService.getUserShop(user.uid);
        if (shopData != null && shopData['shopName'] != null) {
          shopName.value = shopData['shopName'].toString();
        } else {
          final localShop = await databaseService.getShop(user.uid);
          if (localShop != null) {
            shopName.value = localShop.shopName;
          } else {
            shopName.value = '';
          }
        }
      }
    } catch (e) {
      print('Error loading user data: $e');
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        userName.value = user.displayName ?? 'User';
        userAvatarUrl.value = '';
        shopName.value = '';
      }
    }
  }

  void startBrandsAutoScroll() {
    _brandsScrollTimer?.cancel();
    if (brands.isEmpty) {
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!brandsScrollController.hasClients) {
        return;
      }

      final maxScroll = brandsScrollController.position.maxScrollExtent;
      if (maxScroll <= 0) {
        Future.delayed(const Duration(milliseconds: 100), () {
          if (brandsScrollController.hasClients) {
            startBrandsAutoScroll();
          }
        });
        return;
      }

      final oneThirdScroll = maxScroll / 3;
      brandsScrollController.jumpTo(oneThirdScroll);

      _brandsScrollTimer = Timer.periodic(const Duration(milliseconds: 50), (
        timer,
      ) {
        if (isClosed || !brandsScrollController.hasClients) {
          timer.cancel();
          return;
        }

        try {
          final maxScroll = brandsScrollController.position.maxScrollExtent;
          final currentScroll = brandsScrollController.offset;
          final oneThirdScroll = maxScroll / 3;
          final twoThirdScroll = (maxScroll * 2) / 3;

          if (currentScroll >= twoThirdScroll - 1) {
            brandsScrollController.jumpTo(oneThirdScroll);
          } else {
            brandsScrollController.jumpTo(currentScroll + 0.5);
          }
        } catch (e) {
          timer.cancel();
        }
      });
    });
  }

  void _stopBrandsAutoScroll() {
    _brandsScrollTimer?.cancel();
    _brandsScrollTimer = null;
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    _stopBrandsAutoScroll();
    _stopCarouselAutoPlay();
    try {
      _brandsScrollController.dispose();
    } catch (_) {}
    try {
      _carouselController.dispose();
    } catch (_) {}
    try {
      _searchController.dispose();
    } catch (_) {}
    super.onClose();
  }

  static String _parseColorFromData(Map<String, dynamic> carData) {
    String direct = carData['color']?.toString().trim() ??
        carData['colour']?.toString().trim() ??
        carData['carColor']?.toString().trim() ??
        '';

    final invalidValues = {
      'null',
      'n/a',
      'none',
      'select',
      'default',
      'undefined',
      'unknown',
      ''
    };
    if (invalidValues.contains(direct.toLowerCase())) {
      direct = '';
    }

    if (direct.isNotEmpty) return direct;

    final desc = carData['description']?.toString().trim() ?? '';
    final variant = carData['variant']?.toString().trim() ?? '';
    final model = carData['model']?.toString().trim() ?? '';
    final make = carData['make']?.toString().trim() ?? '';
    final combinedText = '$desc $variant $model $make'.toLowerCase();

    final knownColors = [
      'black',
      'white',
      'silver',
      'grey',
      'gray',
      'red',
      'blue',
      'brown',
      'gold',
      'green',
      'orange',
      'yellow',
      'bronze',
      'maroon',
      'beige',
      'burgundy',
      'purple'
    ];

    for (var color in knownColors) {
      if (combinedText.contains(color)) {
        return color[0].toUpperCase() + color.substring(1);
      }
    }

    if (combinedText.contains('sliver') || combinedText.contains('slvr')) {
      return 'Silver';
    }
    if (combinedText.contains('blk')) return 'Black';
    if (combinedText.contains('wht')) return 'White';

    return '';
  }
}
