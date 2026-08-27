import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/services/catalog_service.dart';
import '../../../../core/models/car.dart';
import '../../../../core/database/database_service.dart';
import '../../../../core/services/remote_service.dart';
import '../../../../core/services/storage_service.dart';
import '../../../modules/home/home_controller.dart';
import '../../../modules/profile/controller/profile_menu_controller.dart';
import '../../../../core/utils/price_formatter.dart';
class AddCarController extends GetxController {
  final RxList<String> imagePaths = <String>[].obs;

  // Dropdown sources
  final CatalogService _catalogService = CatalogService();
  final RxList<String> carNames = <String>[].obs;
  final RxList<String> variants = <String>[].obs;
  final RxList<String> years = <String>[].obs;
  final RxList<String> owners = <String>[].obs;
  final RxList<String> colours = <String>[].obs;
  final RxList<String> models = <String>[].obs;
  final RxList<String> fuelTypes = <String>[].obs;
  final RxList<String> insuranceStatuses = <String>[].obs;
  final RxList<String> transmissions = <String>[].obs;
  final RxList<String> states = <String>[].obs;
  final RxList<String> cities = <String>[].obs;

  // Selected values
  final RxnString selectedCarName = RxnString();
  final RxnString selectedVariant = RxnString();
  final RxnString selectedYear = RxnString();
  final RxnString selectedOwner = RxnString();
  final RxnString selectedColour = RxnString();
  final RxnString selectedModel = RxnString();
  final RxnString selectedFuelType = RxnString();
  final RxnString selectedInsurance = RxnString();
  final RxnString selectedTransmission = RxnString();
  final RxnString selectedState = RxnString();
  final RxnString selectedCity = RxnString();

  // Other fields
  final RxString demandPrice = ''.obs;
  final RxString kmsDriven = ''.obs;
  final RxString mileage = ''.obs;
  final RxString tankCapacity = ''.obs;
  final RxString carName = ''.obs;
  final RxString model = ''.obs;
  final RxString pincode = ''.obs;

  // New fields for price unit
  final RxList<String> priceUnits = <String>['Lakh', 'Cr'].obs;
  final RxString selectedPriceUnit = 'Lakh'.obs;

  // New fields for seat type and license type
  final RxString selectedSeatType = '5'.obs; // Default to 5 seater
  final RxString selectedLicenseType =
      'Non Commercial'.obs; // Default to Non Commercial

  // TextEditingControllers for text fields
  final TextEditingController demandPriceController = TextEditingController();
  final TextEditingController kmsDrivenController = TextEditingController();
  final TextEditingController mileageController = TextEditingController();
  final TextEditingController tankCapacityController = TextEditingController();
  final TextEditingController carNameController = TextEditingController();
  final TextEditingController modelController = TextEditingController();
  final TextEditingController pincodeController = TextEditingController();

  // Custom input fields for "Other" option
  final RxString customOwner = ''.obs;
  final RxString customCarName = ''.obs;
  final RxString customModel = ''.obs;
  final RxString customVariant = ''.obs;
  final RxString customYear = ''.obs;
  final RxString customColour = ''.obs;
  final RxString customFuelType = ''.obs;
  final RxString customTransmission = ''.obs;
  final RxString customInsurance = ''.obs;
  final RxString customState = ''.obs;
  final RxString customCity = ''.obs;

  // TextEditingControllers for custom fields
  final TextEditingController customOwnerController = TextEditingController();
  final TextEditingController customCarNameController = TextEditingController();
  final TextEditingController customModelController = TextEditingController();
  final TextEditingController customVariantController = TextEditingController();
  final TextEditingController customYearController = TextEditingController();
  final TextEditingController customColourController = TextEditingController();
  final TextEditingController customFuelTypeController =
      TextEditingController();
  final TextEditingController customTransmissionController =
      TextEditingController();
  final TextEditingController customInsuranceController =
      TextEditingController();
  final TextEditingController customStateController = TextEditingController();
  final TextEditingController customCityController = TextEditingController();

  final RxBool isLoading = false.obs;
  final RxBool isEditMode = false.obs;
  String? editingCarId;

  void removeImage(int index) {
    if (index >= 0 && index < imagePaths.length) {
      imagePaths.removeAt(index);
    }
  }

  Future<void> pickImages() async {
    try {
      final FilePickerResult? result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.image,
      );
      if (result != null && result.files.isNotEmpty) {
        final List<String> validPaths = [];
        for (var file in result.files) {
          if (file.path != null && file.path!.isNotEmpty) {
            // Verify file exists before adding
            final fileObj = File(file.path!);
            if (await fileObj.exists()) {
              validPaths.add(file.path!);
              print(
                'Selected image: ${file.path}, size: ${await fileObj.length()} bytes',
              );
            } else {
              print('Warning: Selected file does not exist: ${file.path}');
            }
          }
        }
        if (validPaths.isNotEmpty) {
          // Add to existing images (max 10 total)
          final currentCount = imagePaths.length;
          final remainingSlots = 10 - currentCount;
          if (remainingSlots > 0) {
            final newPaths = validPaths.take(remainingSlots).toList();
            imagePaths.addAll(newPaths);
            print(
              'Added ${newPaths.length} image(s). Total: ${imagePaths.length}',
            );

            if (validPaths.length > remainingSlots) {
              Get.snackbar(
                'Info',
                'Only ${remainingSlots} more images can be added (max 10 total)',
                snackPosition: SnackPosition.TOP,
                backgroundColor: Colors.orange,
                colorText: Colors.white,
              );
            }
          } else {
            Get.snackbar(
              'Limit Reached',
              'Maximum 10 images allowed. Please remove some images first.',
              snackPosition: SnackPosition.TOP,
              backgroundColor: Colors.orange,
              colorText: Colors.white,
            );
          }
        } else {
          Get.snackbar(
            'Error',
            'No valid images selected',
            snackPosition: SnackPosition.TOP,
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
        }
      }
    } catch (e) {
      print('Error picking images: $e');
      Get.snackbar(
        'Error',
        'Failed to pick images: ${e.toString()}',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  @override
  void onInit() {
    super.onInit();
    _checkEditMode();
    _loadDropdowns().then((_) async {
      final args = Get.arguments;
      if (args is Map<String, dynamic> && args['editMode'] == true) {
        await _loadCarData(args);
        update();
      }
    });

    demandPriceController.addListener(() {
      demandPrice.value = demandPriceController.text;
    });
    kmsDrivenController.addListener(() {
      kmsDriven.value = kmsDrivenController.text;
    });
    mileageController.addListener(() {
      mileage.value = mileageController.text;
    });
    tankCapacityController.addListener(() {
      tankCapacity.value = tankCapacityController.text;
    });
    carNameController.addListener(() {
      carName.value = carNameController.text;
    });
    modelController.addListener(() {
      model.value = modelController.text;
    });

    customOwnerController.addListener(() {
      customOwner.value = customOwnerController.text;
    });
    customCarNameController.addListener(() {
      customCarName.value = customCarNameController.text;
    });
    customModelController.addListener(() {
      customModel.value = customModelController.text;
    });
    customVariantController.addListener(() {
      customVariant.value = customVariantController.text;
    });
    customYearController.addListener(() {
      customYear.value = customYearController.text;
    });
    customColourController.addListener(() {
      customColour.value = customColourController.text;
    });
    customFuelTypeController.addListener(() {
      customFuelType.value = customFuelTypeController.text;
    });
    customTransmissionController.addListener(() {
      customTransmission.value = customTransmissionController.text;
    });
    customInsuranceController.addListener(() {
      customInsurance.value = customInsuranceController.text;
    });
    pincodeController.addListener(() {
      pincode.value = pincodeController.text;
    });
    customStateController.addListener(() {
      customState.value = customStateController.text;
    });
    customCityController.addListener(() {
      customCity.value = customCityController.text;
    });
  }

  void _checkEditMode() {
    final args = Get.arguments;
    if (args is Map<String, dynamic> && args['editMode'] == true) {
      isEditMode.value = true;
      editingCarId = args['carId'] as String?;
    }
  }

  Future<void> _loadCarData(Map<String, dynamic> args) async {
    print('Loading car data for editing: $args');

    if (args['name'] != null) {
      final name = (args['name'] as String? ?? '').trim();
      if (name.isNotEmpty) {
        carName.value = name;
        carNameController.text = name;
        print('Set car name: $name');
      }
    }

    if (args['price'] != null) {
      final priceStr = (args['price'] as String? ?? '').trim();
      if (priceStr.isNotEmpty) {
        final parsedPrice = PriceFormatter.parsePriceToDouble(priceStr);
        String numericPrice = parsedPrice > 0 ? parsedPrice.toInt().toString() : priceStr;

        demandPrice.value = numericPrice;
        demandPriceController.text = numericPrice;
        print('Set price: $numericPrice');
      }
    }

    if (args['year'] != null) {
      final year = (args['year'] as String? ?? '').trim();
      if (year.isNotEmpty) {
        if (years.contains(year)) {
          selectedYear.value = year;
          print('Set year: $year');
        } else {
          selectedYear.value = 'Other';
          customYear.value = year;
          customYearController.text = year;
          print('Set year as Other: $year');
        }
      }
    }

    if (selectedCarName.value != null &&
        selectedCarName.value!.isNotEmpty &&
        selectedCarName.value != 'Other') {
      await onCarNameChanged(selectedCarName.value!, customCarNameController);
    }

    if (args['model'] != null) {
      final modelValue = (args['model'] as String? ?? '').trim();
      if (modelValue.isNotEmpty) {
        model.value = modelValue;
        modelController.text = modelValue;
        print('Set model: $modelValue');
      }
    }

    if (args['variant'] != null) {
      final variant = (args['variant'] as String? ?? '').trim();
      if (variant.isNotEmpty) {
        if (variants.contains(variant)) {
          selectedVariant.value = variant;
          print('Set variant: $variant');
        } else {
          selectedVariant.value = 'Other';
          customVariant.value = variant;
          customVariantController.text = variant;
          print('Set variant as Other: $variant');
        }
      }
    }

    if (args['color'] != null) {
      final color = (args['color'] as String? ?? '').trim();
      if (color.isNotEmpty) {
        if (colours.contains(color)) {
          selectedColour.value = color;
          print('Set color: $color');
        } else {
          final matchingColour = colours.firstWhere(
            (c) =>
                c.toLowerCase() == color.toLowerCase() ||
                c.toLowerCase().contains(color.toLowerCase()) ||
                color.toLowerCase().contains(c.toLowerCase()),
            orElse: () => '',
          );
          if (matchingColour.isNotEmpty) {
            selectedColour.value = matchingColour;
            print('Set color mapped from $color to $matchingColour');
          } else {
            selectedColour.value = 'Other';
            customColour.value = color;
            customColourController.text = color;
            print('Set color as Other: $color');
          }
        }
      }
    }

    if (args['fuelType'] != null) {
      final fuelType = (args['fuelType'] as String? ?? '').trim();
      if (fuelType.isNotEmpty) {
        if (fuelTypes.contains(fuelType)) {
          selectedFuelType.value = fuelType;
          print('Set fuelType: $fuelType');
        } else {
          final matchingFuel = fuelTypes.firstWhere(
            (f) =>
                f.toLowerCase() == fuelType.toLowerCase() ||
                f.toLowerCase().startsWith('${fuelType.toLowerCase()} ('),
            orElse: () => '',
          );
          if (matchingFuel.isNotEmpty) {
            selectedFuelType.value = matchingFuel;
            print('Set fuelType mapped from $fuelType to $matchingFuel');
          } else {
            selectedFuelType.value = 'Other';
            customFuelType.value = fuelType;
            customFuelTypeController.text = fuelType;
            print('Set fuelType as Other: $fuelType');
          }
        }
      }
    }

    if (args['owner'] != null) {
      final owner = (args['owner'] as String? ?? '').trim();
      if (owner.isNotEmpty) {
        if (owners.contains(owner)) {
          selectedOwner.value = owner;
          print('Set owner: $owner');
        } else {
          selectedOwner.value = 'Other';
          customOwner.value = owner;
          customOwnerController.text = owner;
          print('Set owner as Other: $owner');
        }
      }
    }

    if (args['transmission'] != null) {
      final transmission = (args['transmission'] as String? ?? '').trim();
      if (transmission.isNotEmpty) {
        if (transmissions.contains(transmission)) {
          selectedTransmission.value = transmission;
          print('Set transmission: $transmission');
        } else {
          selectedTransmission.value = 'Other';
          customTransmission.value = transmission;
          customTransmissionController.text = transmission;
          print('Set transmission as Other: $transmission');
        }
      }
    }

    if (args['insurance'] != null) {
      final insurance = (args['insurance'] as String? ?? '').trim();
      if (insurance.isNotEmpty) {
        if (insuranceStatuses.contains(insurance)) {
          selectedInsurance.value = insurance;
          print('Set insurance: $insurance');
        } else {
          selectedInsurance.value = 'Other';
          customInsurance.value = insurance;
          customInsuranceController.text = insurance;
          print('Set insurance as Other: $insurance');
        }
      }
    }

    if (args['kmsDriven'] != null) {
      final kms = (args['kmsDriven'] as String? ?? '').trim();
      kmsDriven.value = kms;
      kmsDrivenController.text = kms;
      print('Set kmsDriven: $kms');
    }

    if (args['mileage'] != null) {
      final mil = (args['mileage'] as String? ?? '').trim();
      mileage.value = mil;
      mileageController.text = mil;
      print('Set mileage: $mil');
    }

    if (args['tankCapacity'] != null) {
      final tank = (args['tankCapacity'] as String? ?? '').trim();
      tankCapacity.value = tank;
      tankCapacityController.text = tank;
      print('Set tankCapacity: $tank');
    }

    if (args['state'] != null) {
      final stateValue = (args['state'] as String? ?? '').trim();
      if (stateValue.isNotEmpty) {
        if (states.contains(stateValue)) {
          selectedState.value = stateValue;
          await onStateChanged(stateValue, customStateController);
          print('Set state: $stateValue');
        } else {
          selectedState.value = 'Other';
          customState.value = stateValue;
          customStateController.text = stateValue;
          print('Set state as Other: $stateValue');
        }
      }
    }

    if (args['city'] != null) {
      final cityValue = (args['city'] as String? ?? '').trim();
      if (cityValue.isNotEmpty) {
        if (cities.contains(cityValue)) {
          selectedCity.value = cityValue;
          print('Set city: $cityValue');
        } else {
          selectedCity.value = 'Other';
          customCity.value = cityValue;
          customCityController.text = cityValue;
          print('Set city as Other: $cityValue');
        }
      }
    }

    if (args['pincode'] != null) {
      final pin = (args['pincode'] as String? ?? '').trim();
      pincode.value = pin;
      pincodeController.text = pin;
      print('Set pincode: $pin');
    }

    // Handle image URLs - can be single URL, array, or JSON string
    if (args['imageUrls'] != null && args['imageUrls'] is List) {
      // Prefer imageUrls array if available
      final imageUrls = args['imageUrls'] as List;
      imagePaths.value = imageUrls.cast<String>();
      print('Loaded ${imageUrls.length} images');
    } else if (args['imageUrl'] != null && args['imageUrl'] is String) {
      final imageUrl = args['imageUrl'] as String;
      if (imageUrl.isNotEmpty) {
        // Check if it's a JSON array string
        if (imageUrl.startsWith('[') && imageUrl.endsWith(']')) {
          try {
            final List<dynamic> parsed = jsonDecode(imageUrl);
            imagePaths.value = parsed.cast<String>();
            print('Loaded ${parsed.length} images from JSON string');
          } catch (e) {
            // If parsing fails, treat as single URL
            imagePaths.value = [imageUrl];
            print('Loaded 1 image from string');
          }
        } else {
          imagePaths.value = [imageUrl];
          print('Loaded 1 image');
        }
      }
    }

    print('Finished loading car data. All fields should be prefilled now.');
    update();
  }

  Future<void> loadDropdowns() async {
    isLoading.value = true;
    try {
      final List<String> fetchedCarNames = await _catalogService
          .fetchCarNames();
      carNames.assignAll(fetchedCarNames);
      years.assignAll(await _catalogService.fetchYears());
      owners.assignAll(await _catalogService.fetchOwners());
      colours.assignAll(await _catalogService.fetchColours());
      fuelTypes.assignAll(await _catalogService.fetchFuelTypes());
      insuranceStatuses.assignAll(
        await _catalogService.fetchInsuranceStatuses(),
      );
      transmissions.assignAll(await _catalogService.fetchTransmissions());
      states.assignAll(await _catalogService.fetchStates());

      // Load default variants (will be updated when brand is selected)
      variants.clear();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _loadDropdowns() async {
    await loadDropdowns();
  }

  Future<void> onStateChanged(
    String? value, [
    TextEditingController? customController,
  ]) async {
    if (value == 'Other') {
      selectedState.value = 'Other';
      customState.value = '';
      customController?.clear();
      cities.clear();
      selectedCity.value = null;
    } else if (value != null && value != 'Other') {
      selectedState.value = value;
      customState.value = '';
      customStateController.clear();
      try {
        final fetchedCities = await _catalogService.fetchCities(value);
        cities.clear();
        cities.addAll(fetchedCities);
        print('Loaded ${fetchedCities.length} cities for state $value');
      } catch (e) {
        print('Error loading cities: $e');
        cities.clear();
      }
      selectedCity.value = null;
    }
  }

  Future<void> onCarNameChanged(
    String? value, [
    TextEditingController? customController,
  ]) async {
    if (value == 'Other') {
      selectedCarName.value = 'Other';
      customCarName.value = '';
      customController?.clear();
      models.clear();
      variants.clear();
      selectedModel.value = null;
      selectedVariant.value = null;
    } else if (value != null && value != 'Other') {
      selectedCarName.value = value;
      customCarName.value = '';
      customCarNameController.clear();
      try {
        // Fetch dependent lists
        final fetchedModels = await _catalogService.fetchModels(value);
        final fetchedVariants = await _catalogService.fetchVariants(value);
        models.clear();
        models.addAll(fetchedModels);
        variants.clear();
        variants.addAll(fetchedVariants);
        print(
          'Loaded ${fetchedModels.length} models and ${fetchedVariants.length} variants for $value',
        );
      } catch (e) {
        print('Error loading models/variants: $e');
        models.clear();
        variants.clear();
      }
      // Clear dependent selections
      selectedModel.value = null;
      selectedVariant.value = null;
    }
  }

  void onDropdownChanged(
    String? value,
    Rx<String?> selectedField,
    RxString customField,
    TextEditingController? customController,
  ) {
    if (value == 'Other') {
      selectedField.value = 'Other';
      customField.value = '';
      customController?.clear();
    } else if (value != null) {
      selectedField.value = value;
      customField.value = '';
      customController?.clear();
    }
  }

  Car buildCar() {
    return Car(
      name: carName.value,
      variant:
          (selectedVariant.value == 'Other' && customVariant.value.isNotEmpty)
          ? customVariant.value
          : (selectedVariant.value ?? ''),
      yearOfManufacture:
          (selectedYear.value == 'Other' && customYear.value.isNotEmpty)
          ? customYear.value
          : (selectedYear.value ?? ''),
      owner: (selectedOwner.value == 'Other' && customOwner.value.isNotEmpty)
          ? customOwner.value
          : (selectedOwner.value ?? ''),
      color: (selectedColour.value == 'Other' && customColour.value.isNotEmpty)
          ? customColour.value
          : (selectedColour.value ?? ''),
      model: model.value,
      fuelType:
          (selectedFuelType.value == 'Other' && customFuelType.value.isNotEmpty)
          ? customFuelType.value
          : (selectedFuelType.value ?? ''),
      insurance:
          (selectedInsurance.value == 'Other' &&
              customInsurance.value.isNotEmpty)
          ? customInsurance.value
          : (selectedInsurance.value ?? ''),
      transmission:
          (selectedTransmission.value == 'Other' &&
              customTransmission.value.isNotEmpty)
          ? customTransmission.value
          : (selectedTransmission.value ?? ''),
      demandPrice: demandPrice.value,
      kmsDriven: kmsDriven.value,
      mileage: mileage.value,
      tankCapacity: tankCapacity.value,
      imagePaths: imagePaths.toList(),
      seatType: selectedSeatType.value, // New field
      licenseType: selectedLicenseType.value, // New field
      state:
          (selectedState.value == 'Other' && customState.value.isNotEmpty)
          ? customState.value
          : (selectedState.value ?? ''),
      city:
          (selectedCity.value == 'Other' && customCity.value.isNotEmpty)
          ? customCity.value
          : (selectedCity.value ?? ''),
      pincode: pincode.value,
    );
  }

  Future<void> saveCarToDatabase(Car car) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        print('Error: User is not authenticated');
        Get.snackbar(
          'Error',
          'User is not authenticated. Please log in again.',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      if (!Get.isRegistered<DatabaseService>()) {
        await Get.putAsync<DatabaseService>(() async => DatabaseService());
      }
      if (!Get.isRegistered<RemoteService>()) {
        Get.put(RemoteService());
      }
      final databaseService = Get.find<DatabaseService>();
      final remoteService = Get.find<RemoteService>();
      // Ensure StorageService is registered
      if (!Get.isRegistered<StorageService>()) {
        Get.put(StorageService());
      }
      final storageService = Get.find<StorageService>();

      final carId = isEditMode.value && editingCarId != null
          ? editingCarId!
          : '${user.uid}_${DateTime.now().millisecondsSinceEpoch}';

      print('Saving car with ID: $carId for user: ${user.uid}');
      print(
        'Car details: make=${car.name}, model=${car.model}, year=${car.yearOfManufacture}, price=${car.demandPrice}',
      );

      // Upload all images to Firebase Storage
      List<String> imageUrls = [];
      if (car.imagePaths.isNotEmpty) {
        print('Processing ${car.imagePaths.length} car image(s)...');

        for (int i = 0; i < car.imagePaths.length; i++) {
          final imagePath = car.imagePaths[i];
          print(
            'Processing image ${i + 1}/${car.imagePaths.length}: $imagePath',
          );

          // Check if it's already a URL
          if (imagePath.startsWith('http://') ||
              imagePath.startsWith('https://')) {
            imageUrls.add(imagePath); // Already uploaded
            print('Image ${i + 1} is already a URL, using as-is');
          } else {
            // Upload local file to Firebase Storage
            try {
              print(
                'Starting upload for image ${i + 1}/${car.imagePaths.length}...',
              );

              // Verify file exists before attempting upload
              final File imageFile = File(imagePath);
              if (!await imageFile.exists()) {
                throw Exception(
                  'Image file ${i + 1} not found at path: $imagePath. Please select the image again.',
                );
              }

              final fileSize = await imageFile.length();
              print('Image ${i + 1} verified. Size: $fileSize bytes');

              if (fileSize == 0) {
                throw Exception(
                  'Image file ${i + 1} is empty. Please select a valid image.',
                );
              }

              final uploadedUrl = await storageService.uploadCarImage(
                user.uid,
                imagePath,
                carId,
                i,
              );
              imageUrls.add(uploadedUrl);
              print('Image ${i + 1} uploaded successfully: $uploadedUrl');
            } catch (e, stackTrace) {
              print('Error uploading image ${i + 1}: $e');
              print('Stack trace: $stackTrace');

              String errorMessage;
              if (e.toString().contains('permission-denied') ||
                  e.toString().contains('Permission denied')) {
                errorMessage =
                    'Permission denied for image ${i + 1}. Please check Firebase Storage rules in Firebase Console.';
              } else if (e.toString().contains('file-not-found') ||
                  e.toString().contains('does not exist') ||
                  e.toString().contains('not found')) {
                errorMessage =
                    'Image file ${i + 1} not found. Please select the image again.';
              } else if (e.toString().contains('network') ||
                  e.toString().contains('connection')) {
                errorMessage =
                    'Network error uploading image ${i + 1}. Please check your internet connection and try again.';
              } else if (e.toString().contains('canceled') ||
                  e.toString().contains('cancelled')) {
                errorMessage =
                    'Upload for image ${i + 1} was cancelled. Please try again.';
              } else {
                errorMessage =
                    'Failed to upload image ${i + 1}. Error: ${e.toString().split(':').last.trim()}';
              }

              Get.snackbar(
                'Upload Failed',
                errorMessage,
                snackPosition: SnackPosition.TOP,
                backgroundColor: Colors.red,
                colorText: Colors.white,
                duration: const Duration(seconds: 6),
              );

              // Don't save with local path if upload fails - ask user to retry
              String cleanError = e.toString().replaceAll('Exception: ', '').trim();
              throw Exception(cleanError);
            }
          }
        }

        print('Successfully processed ${imageUrls.length} image(s)');
      } else {
        print('No images selected for car - saving car without images');
      }

      // Convert image URLs list to JSON string for storage
      final String? imageUrlsJson = imageUrls.isNotEmpty
          ? jsonEncode(imageUrls)
          : null;

      final String description = [
        car.variant.isNotEmpty ? car.variant : null,
        car.color.isNotEmpty ? car.color : null,
        car.fuelType.isNotEmpty ? car.fuelType : null,
        car.transmission.isNotEmpty
            ? '${car.transmission} Transmission'
            : null,
        car.kmsDriven.isNotEmpty ? '${car.kmsDriven} Kms' : null,
      ].where((item) => item != null).join(', ');

      // Save to local database (store as JSON string)
      await databaseService.saveCar(
        id: carId,
        userId: user.uid,
        make: car.name,
        model: car.model,
        year: car.yearOfManufacture,
        price: car.demandPrice,
        imageUrl: imageUrlsJson,
        description: description.isNotEmpty ? description : null,
      );

      // Save to Firestore (cloud) - store as array
      await remoteService.saveCar(
        id: carId,
        userId: user.uid,
        make: car.name,
        model: car.model,
        year: car.yearOfManufacture,
        price: car.demandPrice,
        imageUrl: imageUrls.isNotEmpty ? imageUrls.first : null,
        imageUrls: imageUrls.isNotEmpty ? imageUrls : null,
        description: description.isNotEmpty ? description : null,
        owner: car.owner.isNotEmpty ? car.owner : null,
        color: car.color.isNotEmpty ? car.color : null,
        variant: car.variant.isNotEmpty ? car.variant : null,
        kmsDriven: car.kmsDriven.isNotEmpty ? car.kmsDriven : null,
        fuelType: car.fuelType.isNotEmpty ? car.fuelType : null,
        transmission: car.transmission.isNotEmpty ? car.transmission : null,
        insurance: car.insurance.isNotEmpty ? car.insurance : null,
        mileage: car.mileage.isNotEmpty ? car.mileage : null,
        tankCapacity: car.tankCapacity.isNotEmpty ? car.tankCapacity : null,
        state: car.state.isNotEmpty ? car.state : null,
        city: car.city.isNotEmpty ? car.city : null,
        pincode: car.pincode.isNotEmpty ? car.pincode : null,
        seatType: car.seatType.isNotEmpty ? car.seatType : null,
        licenseType: car.licenseType.isNotEmpty ? car.licenseType : null,
      );

      print('Car saved successfully to local database and Firestore');

      // Verify the car was saved
      final savedCars = await databaseService.getUserCars(user.uid);
      print('Total cars for user in local DB: ${savedCars.length}');

      try {
        if (Get.isRegistered<HomeController>()) {
          final homeController = Get.find<HomeController>();
          await homeController.refreshCars();
        }
      } catch (e) {
        print('Error refreshing HomeController: $e');
      }

      try {
        if (Get.isRegistered<ProfileMenuController>()) {
          final profileController = Get.find<ProfileMenuController>();
          await profileController.refreshCars();
        }
      } catch (e) {
        print('Error refreshing ProfileMenuController: $e');
      }
    } catch (e, stackTrace) {
      print('Error saving car to database: $e');
      print('Stack trace: $stackTrace');
      Get.snackbar(
        'Error',
        'Failed to save car: ${e.toString()}',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 4),
      );
      rethrow;
    }
  }

  void clearForm() {
    // Reset selections
    selectedCarName.value = null;
    selectedVariant.value = null;
    selectedYear.value = null;
    selectedOwner.value = null;
    selectedColour.value = null;
    selectedModel.value = null;
    selectedFuelType.value = null;
    selectedInsurance.value = null;
    selectedTransmission.value = null;
    selectedState.value = null;
    selectedCity.value = null;
    selectedSeatType.value = '5';
    selectedLicenseType.value = 'Non Commercial';
    selectedPriceUnit.value = 'Lakh';

    // Reset controllers
    demandPriceController.clear();
    kmsDrivenController.clear();
    mileageController.clear();
    tankCapacityController.clear();
    carNameController.clear();
    modelController.clear();
    pincodeController.clear();

    // Reset custom fields
    customOwnerController.clear();
    customCarNameController.clear();
    customModelController.clear();
    customVariantController.clear();
    customYearController.clear();
    customColourController.clear();
    customFuelTypeController.clear();
    customTransmissionController.clear();
    customInsuranceController.clear();
    customStateController.clear();
    customCityController.clear();

    // Reset images
    imagePaths.clear();

    // Reset state
    isEditMode.value = false;
    editingCarId = null;

    print('Add car form cleared');
    update();
  }
}
