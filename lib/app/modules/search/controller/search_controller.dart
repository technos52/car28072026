import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/services/remote_service.dart';
import '../../../../core/services/catalog_service.dart';
import '../../../../core/models/car.dart' as CarModel;
import '../../root/controller/root_controller.dart';
import '../../../../core/utils/price_formatter.dart';

class SearchController extends GetxController {
  final TextEditingController searchTextController = TextEditingController();
  final RxString query = ''.obs;
  final RxList<String> recent = <String>[].obs;
  final RxList<CarModel.Car> allCars = <CarModel.Car>[].obs;
  final RxList<CarModel.Car> searchResults = <CarModel.Car>[].obs;
  final RxBool isLoading = false.obs;
  final Map<String, String> carIdMap = {};
  final Map<String, bool> carAvailabilityMap = {};

  final RxList<String> availableBrands = <String>[].obs;
  final RxList<String> availableYears = <String>[].obs;
  final RxList<String> availableColors = <String>[].obs;
  final RxList<String> availableFuelTypes = <String>[].obs;
  final RxList<String> availableTransmissions = <String>[].obs;
  final RxList<String> availableModels = <String>[].obs;
  final RxList<String> availableVariants = <String>[].obs;
  final RxList<String> availableInsurances = <String>[].obs;
  final RxList<String> availableLicenseTypes = <String>[].obs;
  final RxList<String> availableStates = <String>[].obs;
  final RxList<String> availableCities = <String>[].obs;
  final RxList<String> availablePincodes = <String>[].obs;
  final RxList<String> availableSeatTypes = <String>[].obs;

  final RxString selectedBrandFilter = ''.obs;
  final RxString selectedYearFilter = ''.obs;
  final RxString selectedColorFilter = ''.obs;
  final RxList<String> selectedFuelTypes = <String>[].obs;
  final CatalogService _catalogService = CatalogService();
  final RxString selectedTransmissionFilter = ''.obs;
  final RxString selectedModelFilter = ''.obs;
  final RxString selectedVariantFilter = ''.obs;
  final RxString selectedInsuranceFilter = ''.obs;
  final RxString selectedLicenseTypeFilter = ''.obs;
  final RxString selectedStateFilter = ''.obs;
  final RxString selectedCityFilter = ''.obs;
  final RxString selectedPincodeFilter = ''.obs;
  final RxString selectedSeatTypeFilter = ''.obs;
  final RxString selectedSortBy = 'Most Recent'.obs;
  final RxDouble minPrice = 0.30.obs;
  final RxDouble maxPrice = 200.0.obs;

  bool get hasActiveFilters {
    return (selectedBrandFilter.value.isNotEmpty &&
            selectedBrandFilter.value != 'All') ||
        (selectedModelFilter.value.isNotEmpty &&
            selectedModelFilter.value != 'All') ||
        (selectedVariantFilter.value.isNotEmpty &&
            selectedVariantFilter.value != 'All') ||
        (selectedYearFilter.value.isNotEmpty &&
            selectedYearFilter.value != 'All') ||
        (selectedColorFilter.value.isNotEmpty &&
            selectedColorFilter.value != 'All') ||
        selectedFuelTypes.isNotEmpty ||
        (selectedTransmissionFilter.value.isNotEmpty &&
            selectedTransmissionFilter.value != 'All') ||
        (selectedInsuranceFilter.value.isNotEmpty &&
            selectedInsuranceFilter.value != 'All') ||
        (selectedLicenseTypeFilter.value.isNotEmpty &&
            selectedLicenseTypeFilter.value != 'All') ||
        (selectedStateFilter.value.isNotEmpty &&
            selectedStateFilter.value != 'All') ||
        (selectedCityFilter.value.isNotEmpty &&
            selectedCityFilter.value != 'All') ||
        (selectedPincodeFilter.value.isNotEmpty &&
            selectedPincodeFilter.value != 'All') ||
        (selectedSeatTypeFilter.value.isNotEmpty &&
            selectedSeatTypeFilter.value != 'All') ||
        (selectedSortBy.value.isNotEmpty &&
            selectedSortBy.value != 'Most Recent') ||
        minPrice.value > 0.35 ||
        maxPrice.value < 200.0;
  }

  @override
  void onInit() {
    super.onInit();
    String? initialBrand;

    final arguments = Get.arguments;
    if (arguments != null && arguments is Map<String, dynamic>) {
      initialBrand = arguments['brand'] as String?;
    }

    if (initialBrand == null || initialBrand.isEmpty) {
      if (Get.isRegistered<RootController>()) {
        final rootController = Get.find<RootController>();
        initialBrand = rootController.getBrandFilterAndClear();
      }
    }

    if (initialBrand != null && initialBrand.isNotEmpty) {
      selectedBrandFilter.value = initialBrand.trim();
      searchTextController.text = '';
      query.value = '';
    }

    searchTextController.addListener(() {
      query.value = searchTextController.text;
      _performSearch();
    });

    _loadDefaultOptions();
    loadAllCars(initialBrand: initialBrand);
  }

  Future<void> _loadDefaultOptions() async {
    try {
      final fuelTypes = await _catalogService.fetchFuelTypes();
      for (var f in fuelTypes) if (!availableFuelTypes.contains(f)) availableFuelTypes.add(f);
      
      final transmissions = await _catalogService.fetchTransmissions();
      for (var t in transmissions) if (!availableTransmissions.contains(t)) availableTransmissions.add(t);
      
      final states = await _catalogService.fetchStates();
      for (var s in states) if (!availableStates.contains(s)) availableStates.add(s);
      
      final brands = await _catalogService.fetchCarNames();
      for (var b in brands) if (!availableBrands.contains(b)) availableBrands.add(b);
      
      final colors = await _catalogService.fetchColours();
      for (var c in colors) if (!availableColors.contains(c)) availableColors.add(c);

      final seatTypes = ['2', '5', '7'];
      for (var s in seatTypes) if (!availableSeatTypes.contains(s)) availableSeatTypes.add(s);
    } catch (e) {
      print('Error loading default options: $e');
    }
  }

  @override
  void onClose() {
    searchTextController.dispose();
    super.onClose();
  }

  Future<void> loadAllCars({String? initialBrand}) async {
    try {
      isLoading.value = true;

      if (!Get.isRegistered<RemoteService>()) {
        Get.put(RemoteService());
      }
      final remoteService = Get.find<RemoteService>();

      final allCarsData = await remoteService.getAllCars();

      final cars = <CarModel.Car>[];
      carIdMap.clear();

      for (var carData in allCarsData) {
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
          state: carData['state']?.toString() ?? '',
          city: carData['city']?.toString() ?? '',
          pincode: carData['pincode']?.toString() ?? '',
          createdAt: carData['createdAt'] != null
              ? (carData['createdAt'] as Timestamp).toDate()
              : null,
        );

        final carKey = _getCarKey(car);
        final isAvailable = carData['isAvailable'] as bool? ?? true;
        carIdMap[carKey] = carId;
        carAvailabilityMap[carId] = isAvailable;
        cars.add(car);
      }

      allCars.value = cars;
      _loadFilterOptions();
      print('Loaded ${cars.length} cars for search');
      isLoading.value = false;

      if (initialBrand != null && initialBrand.isNotEmpty) {
        selectedBrandFilter.value = initialBrand.trim();
        _performSearch();
      } else if (selectedBrandFilter.value.isNotEmpty &&
          selectedBrandFilter.value != 'All') {
        _performSearch();
      }
    } catch (e) {
      print('Error loading cars for search: $e');
      isLoading.value = false;
    }
  }

  Future<void> refreshSearchData() async {
    // Quick refresh without changing current filters
    await loadAllCars();
  }

  String _getCarKey(CarModel.Car car) {
    return '${car.name}_${car.model}_${car.yearOfManufacture}_${car.demandPrice}';
  }

  String getCarKey(CarModel.Car car) {
    return _getCarKey(car);
  }

  void _loadFilterOptions() {
    final brandsSet = <String>{};
    final yearsSet = <String>{};
    final colorsSet = <String>{};
    final fuelTypesSet = <String>{};
    final transmissionsSet = <String>{};
    final modelsSet = <String>{};
    final variantsSet = <String>{};
    final insurancesSet = <String>{};
    final licenseTypesSet = <String>{};
    final statesSet = <String>{};
    final citiesSet = <String>{};
    final pincodesSet = <String>{};
    final seatTypesSet = <String>{};

    for (var car in allCars) {
      if (car.name.isNotEmpty) brandsSet.add(car.name);
      if (car.model.isNotEmpty) modelsSet.add(car.model);
      if (car.variant.isNotEmpty) variantsSet.add(car.variant);
      if (car.yearOfManufacture.isNotEmpty) yearsSet.add(car.yearOfManufacture);
      if (car.color.isNotEmpty) colorsSet.add(car.color);
      if (car.fuelType.isNotEmpty) fuelTypesSet.add(car.fuelType);
      if (car.transmission.isNotEmpty) transmissionsSet.add(car.transmission);
      if (car.insurance.isNotEmpty) insurancesSet.add(car.insurance);
      if (car.licenseType.isNotEmpty) licenseTypesSet.add(car.licenseType);
      if (car.state.isNotEmpty) statesSet.add(car.state);
      if (car.city.isNotEmpty) citiesSet.add(car.city);
      if (car.pincode.isNotEmpty) pincodesSet.add(car.pincode);
      if (car.seatType.isNotEmpty) seatTypesSet.add(car.seatType);
    }

    availableBrands.assignAll(brandsSet.toList()..sort());
    availableModels.assignAll(modelsSet.toList()..sort());
    availableVariants.assignAll(variantsSet.toList()..sort());
    availableYears.assignAll(yearsSet.toList()..sort((a, b) => b.compareTo(a)));
    availableColors.assignAll(colorsSet.toList()..sort());
    fuelTypesSet.add('Petrol');
    availableFuelTypes.assignAll(fuelTypesSet.toList()..sort());
    availableTransmissions.assignAll(transmissionsSet.toList()..sort());
    availableInsurances.assignAll(insurancesSet.toList()..sort());
    licenseTypesSet.addAll(['Commercial', 'Non Commercial']);
    availableLicenseTypes.assignAll(licenseTypesSet.toList()..sort());
    availableStates.assignAll(statesSet.toList()..sort());
    availableCities.assignAll(citiesSet.toList()..sort());
    availablePincodes.assignAll(pincodesSet.toList()..sort());
    availableSeatTypes.assignAll(seatTypesSet.toList()..sort());

    // Hardcode price range
    minPrice.value = 0.30;
    maxPrice.value = 200.0;
  }

  void applyFilters({
    String? brand,
    String? model,
    String? variant,
    String? year,
    String? color,
    List<String>? fuelTypes,
    String? transmission,
    String? insurance,
    String? licenseType,
    String? state,
    String? city,
    String? pincode,
    String? seatType,
    String? sortBy,
    double? minPriceValue,
    double? maxPriceValue,
  }) {
    if (brand != null) selectedBrandFilter.value = brand;
    if (model != null) selectedModelFilter.value = model;
    if (variant != null) selectedVariantFilter.value = variant;
    if (year != null) selectedYearFilter.value = year;
    if (color != null) selectedColorFilter.value = color;
    if (fuelTypes != null) selectedFuelTypes.value = fuelTypes;
    if (transmission != null) selectedTransmissionFilter.value = transmission;
    if (insurance != null) selectedInsuranceFilter.value = insurance;
    if (licenseType != null) selectedLicenseTypeFilter.value = licenseType;
    if (state != null) selectedStateFilter.value = state;
    if (city != null) selectedCityFilter.value = city;
    if (pincode != null) selectedPincodeFilter.value = pincode;
    if (seatType != null) selectedSeatTypeFilter.value = seatType;
    if (sortBy != null) selectedSortBy.value = sortBy;
    if (minPriceValue != null) minPrice.value = minPriceValue;
    if (maxPriceValue != null) maxPrice.value = maxPriceValue;

    _performSearch();
  }

  void clearFilters() {
    selectedBrandFilter.value = '';
    selectedModelFilter.value = '';
    selectedVariantFilter.value = '';
    selectedYearFilter.value = '';
    selectedColorFilter.value = '';
    selectedFuelTypes.clear();
    selectedTransmissionFilter.value = '';
    selectedInsuranceFilter.value = '';
    selectedLicenseTypeFilter.value = '';
    selectedStateFilter.value = '';
    selectedCityFilter.value = '';
    selectedPincodeFilter.value = '';
    selectedSeatTypeFilter.value = '';
    selectedSortBy.value = 'Most Recent';
    minPrice.value = 0.30;
    maxPrice.value = 200.0;
    _performSearch();
  }

  void clearAll() => recent.clear();
  void removeAt(int index) => recent.removeAt(index);

  void submit(String value) {
    query.value = value;
    if (value.trim().isNotEmpty) {
      if (!recent.contains(value)) {
        recent.insert(0, value);
        if (recent.length > 10) {
          recent.removeLast();
        }
      } else {
        recent.remove(value);
        recent.insert(0, value);
      }
    }
    _performSearch();
  }

  void _performSearch() {
    print('Performing search with query: "${query.value}"');
    print('Total cars available: ${allCars.length}');

    List<CarModel.Car> filtered = List<CarModel.Car>.from(allCars);

    if (query.value.trim().isNotEmpty) {
      final searchTerm = query.value.toLowerCase().trim();
      print('Search term: "$searchTerm"');
      print(
        'Sample car names: ${allCars.take(10).map((c) => c.name).toList()}',
      );

      filtered = filtered.where((car) {
        final nameMatch = car.name.toLowerCase().trim().contains(searchTerm);
        final modelMatch = car.model.toLowerCase().trim().contains(searchTerm);
        final variantMatch = car.variant.toLowerCase().trim().contains(
          searchTerm,
        );
        final yearMatch = car.yearOfManufacture.toLowerCase().trim().contains(
          searchTerm,
        );
        final fuelMatch = car.fuelType.toLowerCase().trim().contains(
          searchTerm,
        );
        final colorMatch = car.color.toLowerCase().trim().contains(searchTerm);
        final combinedMatch = '${car.name} ${car.model}'
            .toLowerCase()
            .trim()
            .contains(searchTerm);
        final fullMatch = '${car.name} ${car.model} ${car.variant}'
            .toLowerCase()
            .trim()
            .contains(searchTerm);

        final matches =
            nameMatch ||
            modelMatch ||
            variantMatch ||
            yearMatch ||
            fuelMatch ||
            colorMatch ||
            combinedMatch ||
            fullMatch;

        if (matches) {
          print('Match found: ${car.name} ${car.model}');
        }

        return matches;
      }).toList();

      print('Found ${filtered.length} cars matching "$searchTerm"');
    }

    if (selectedBrandFilter.value.isNotEmpty &&
        selectedBrandFilter.value != 'All') {
      final brandFilter = selectedBrandFilter.value.toLowerCase().trim();
      print('Filtering by brand: $brandFilter');
      final beforeCount = filtered.length;
      filtered = filtered
          .where((car) => car.name.toLowerCase().trim() == brandFilter)
          .toList();
      print(
        'Brand filter: $beforeCount cars before, ${filtered.length} cars after',
      );
    }

    if (selectedYearFilter.value.isNotEmpty &&
        selectedYearFilter.value != 'All') {
      filtered = filtered
          .where((car) => car.yearOfManufacture == selectedYearFilter.value)
          .toList();
    }

    if (selectedColorFilter.value.isNotEmpty &&
        selectedColorFilter.value != 'All') {
      filtered = filtered
          .where(
            (car) =>
                car.color.toLowerCase().trim() ==
                selectedColorFilter.value.toLowerCase().trim(),
          )
          .toList();
    }

    if (selectedFuelTypes.isNotEmpty) {
      filtered = filtered.where((car) {
        final carFuel = car.fuelType.toLowerCase().trim();
        return selectedFuelTypes.any(
          (selected) => carFuel == selected.toLowerCase().trim(),
        );
      }).toList();
    }

    if (selectedTransmissionFilter.value.isNotEmpty &&
        selectedTransmissionFilter.value != 'All') {
      filtered = filtered
          .where(
            (car) =>
                car.transmission.toLowerCase().trim() ==
                selectedTransmissionFilter.value.toLowerCase().trim(),
          )
          .toList();
    }

    if (selectedModelFilter.value.isNotEmpty &&
        selectedModelFilter.value != 'All') {
      filtered = filtered
          .where(
            (car) =>
                car.model.toLowerCase().trim() ==
                selectedModelFilter.value.toLowerCase().trim(),
          )
          .toList();
    }

    if (selectedVariantFilter.value.isNotEmpty &&
        selectedVariantFilter.value != 'All') {
      filtered = filtered
          .where(
            (car) =>
                car.variant.toLowerCase().trim() ==
                selectedVariantFilter.value.toLowerCase().trim(),
          )
          .toList();
    }

    if (selectedInsuranceFilter.value.isNotEmpty &&
        selectedInsuranceFilter.value != 'All') {
      filtered = filtered
          .where(
            (car) =>
                car.insurance.toLowerCase().trim() ==
                selectedInsuranceFilter.value.toLowerCase().trim(),
          )
          .toList();
    }

    if (selectedLicenseTypeFilter.value.isNotEmpty &&
        selectedLicenseTypeFilter.value != 'All') {
      filtered = filtered
          .where(
            (car) =>
                car.licenseType.toLowerCase().trim() ==
                selectedLicenseTypeFilter.value.toLowerCase().trim(),
          )
          .toList();
    }

    if (selectedStateFilter.value.isNotEmpty &&
        selectedStateFilter.value != 'All') {
      filtered = filtered
          .where(
            (car) =>
                car.state.toLowerCase().trim() ==
                selectedStateFilter.value.toLowerCase().trim(),
          )
          .toList();
    }

    if (selectedCityFilter.value.isNotEmpty &&
        selectedCityFilter.value != 'All') {
      filtered = filtered
          .where(
            (car) =>
                car.city.toLowerCase().trim() ==
                selectedCityFilter.value.toLowerCase().trim(),
          )
          .toList();
    }

    if (selectedPincodeFilter.value.isNotEmpty &&
        selectedPincodeFilter.value != 'All') {
      filtered = filtered
          .where(
            (car) =>
                car.pincode.toLowerCase().trim() ==
                selectedPincodeFilter.value.toLowerCase().trim(),
          )
          .toList();
    }

    if (selectedSeatTypeFilter.value.isNotEmpty &&
        selectedSeatTypeFilter.value != 'All') {
      filtered = filtered
          .where(
            (car) =>
                car.seatType.toLowerCase().trim() ==
                selectedSeatTypeFilter.value.toLowerCase().trim(),
          )
          .toList();
    }

    final minPriceInLakhs = minPrice.value * 100000;
    final maxPriceInLakhs = maxPrice.value * 100000;

    filtered = filtered.where((car) {
      if (car.demandPrice.isEmpty) return false;
      final price = PriceFormatter.parsePriceToDouble(car.demandPrice);
      return price >= minPriceInLakhs && price <= maxPriceInLakhs;
    }).toList();

    if (selectedSortBy.value.isNotEmpty) {
      filtered.sort((a, b) {
        switch (selectedSortBy.value) {
          case 'Car Name (Brand)':
            return a.name.toLowerCase().compareTo(b.name.toLowerCase());
          case 'Model':
            return a.model.toLowerCase().compareTo(b.model.toLowerCase());
          case 'Variant':
            return a.variant.toLowerCase().compareTo(b.variant.toLowerCase());
          case 'Fuel Type':
            return a.fuelType.toLowerCase().compareTo(b.fuelType.toLowerCase());
          case 'Color':
            return a.color.toLowerCase().compareTo(b.color.toLowerCase());
          case 'Km Driven':
            final aKm =
                double.tryParse(a.kmsDriven.replaceAll(',', '').trim()) ?? 0.0;
            final bKm =
                double.tryParse(b.kmsDriven.replaceAll(',', '').trim()) ?? 0.0;
            return aKm.compareTo(bKm);
          case 'Transmission':
            return a.transmission.toLowerCase().compareTo(
              b.transmission.toLowerCase(),
            );
          case 'Insurance':
            return a.insurance.toLowerCase().compareTo(
              b.insurance.toLowerCase(),
            );
          case 'low to high':
            final aPrice = PriceFormatter.parsePriceToDouble(a.demandPrice);
            final bPrice = PriceFormatter.parsePriceToDouble(b.demandPrice);
            return aPrice.compareTo(bPrice);
          case 'high to low':
            final aPrice = PriceFormatter.parsePriceToDouble(a.demandPrice);
            final bPrice = PriceFormatter.parsePriceToDouble(b.demandPrice);
            return bPrice.compareTo(aPrice);
          case 'Most Recent':
            if (a.createdAt != null && b.createdAt != null) {
              return b.createdAt!.compareTo(a.createdAt!);
            } else if (a.createdAt != null) {
              return -1;
            } else if (b.createdAt != null) {
              return 1;
            }
            final aYear = int.tryParse(a.yearOfManufacture) ?? 0;
            final bYear = int.tryParse(b.yearOfManufacture) ?? 0;
            return bYear.compareTo(aYear);
          case '5 seater':
            final isA5 = a.seatType.contains('5');
            final isB5 = b.seatType.contains('5');
            if (isA5 && !isB5) return -1;
            if (!isA5 && isB5) return 1;
            return 0;
          case '7 seater':
            final isA7 = a.seatType.contains('7');
            final isB7 = b.seatType.contains('7');
            if (isA7 && !isB7) return -1;
            if (!isA7 && isB7) return 1;
            return 0;
          default:
            return 0;
        }
      });
    }

    print('Found ${filtered.length} matching cars after filters');
    searchResults.value = filtered;
    print('Search results updated: ${searchResults.length} cars');
  }

  List<CarModel.Car> get filteredResults {
    if (query.value.trim().isEmpty) {
      return [];
    }
    return searchResults;
  }
}
