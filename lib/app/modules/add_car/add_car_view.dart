import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'controller/add_car_controller.dart';
import '../home/home_controller.dart';
import '../root/controller/root_controller.dart';
import '../../../core/utils/price_formatter.dart';
import '../../../core/utils/error_dialog.dart';
import '../../../core/utils/success_dialog.dart';

class AddCarView extends GetView<AddCarController> {
  const AddCarView({super.key});

  // Define colors as per specification
  static const Color primaryColor = Color(0xFF0B409C);
  static const Color secondaryColor = Color(0xFF37EC3F);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildPhotoUploadSection(),
                  const SizedBox(height: 24),
                  _buildFormFields(),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
          _buildContinueButton(),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      automaticallyImplyLeading: false,
      title: const Text(
        'Add a Car',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Colors.black,
        ),
      ),
      centerTitle: false,
    );
  }

  Widget _buildPhotoUploadSection() {
    return Obx(() {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text.rich(
            TextSpan(
              text: 'Upload Car Photos',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: primaryColor,
              ),
              children: const [
                TextSpan(
                  text: ' *',
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          // Upload button
          GestureDetector(
            onTap: () => controller.pickImages(),
            child: Container(
              height: 160,
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFFE8E8E8),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: primaryColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.add_photo_alternate,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
            ),
          ),
          // Display uploaded images
          if (controller.imagePaths.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(
              '${controller.imagePaths.length} image(s) selected',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: primaryColor,
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 80,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: controller.imagePaths.length,
                itemBuilder: (context, index) {
                  final imagePath = controller.imagePaths[index];
                  return Container(
                    margin: const EdgeInsets.only(right: 8),
                    child: Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: imagePath.startsWith('http')
                              ? Image.network(
                                  imagePath,
                                  width: 80,
                                  height: 80,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      width: 80,
                                      height: 80,
                                      color: Colors.grey[300],
                                      child: const Icon(Icons.error),
                                    );
                                  },
                                )
                              : Image.file(
                                  File(imagePath),
                                  width: 80,
                                  height: 80,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      width: 80,
                                      height: 80,
                                      color: Colors.grey[300],
                                      child: const Icon(Icons.error),
                                    );
                                  },
                                ),
                        ),
                        Positioned(
                          top: 4,
                          right: 4,
                          child: GestureDetector(
                            onTap: () => controller.removeImage(index),
                            child: Container(
                              padding: const EdgeInsets.all(2),
                              decoration: const BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.close,
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ],
      );
    });
  }

  Widget _buildFormFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDropdownField(
          'Ownership',
          'Owner',
          controller.selectedOwner,
          controller.owners,
        ),
        const SizedBox(height: 16),
        _buildDropdownField(
          'Brand Name',
          'Select Brand',
          controller.selectedCarName,
          controller.carNames,
          onChanged: (value) => controller.onCarNameChanged(value),
        ),
        const SizedBox(height: 16),
        _buildTextField(
          'Car Name',
          'Enter car name',
          controller.carNameController,
        ),
        const SizedBox(height: 16),
        _buildDropdownField(
          'Variant',
          'Select Variant',
          controller.selectedVariant,
          controller.variants,
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildTextField(
                'Model',
                'Enter model',
                controller.modelController,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildDropdownField(
                'Year',
                'Select year',
                controller.selectedYear,
                controller.years,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 7,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTextField(
                    'Price',
                    'Enter price',
                    controller.demandPriceController,
                    keyboardType: TextInputType.number,
                    onChanged: (value) => controller.demandPrice.value = value,
                  ),
                  Obx(() {
                    final priceValue = controller.demandPrice.value;
                    if (priceValue.isEmpty) return const SizedBox.shrink();
                    final formatted = PriceFormatter.formatPriceReadable(priceValue);
                    return Padding(
                      padding: const EdgeInsets.only(top: 8.0, left: 4.0),
                      child: Text(
                        formatted,
                        style: const TextStyle(
                          color: Color(0xFF666666),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(' ', style: TextStyle(fontSize: 16)), // Spacer for alignment
                  const SizedBox(height: 8),
                  Container(
                    height: 50,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      border: Border.all(color: const Color(0xFFE0E0E0)),
                      borderRadius: BorderRadius.circular(8),
                      color: const Color(0xFFFAFAFA),
                    ),
                    child: const Text(
                      'RS',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Text.rich(
          const TextSpan(
            text: 'Specifications',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: primaryColor,
            ),
            children: [
              TextSpan(
                text: ' *',
                style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildDropdownField(
                'Colour',
                'Select Colour',
                controller.selectedColour,
                controller.colours,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildDropdownField(
                'Fuel Type',
                'Select Fuel',
                controller.selectedFuelType,
                controller.fuelTypes,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildDropdownField(
                'Transmission',
                'Select Transmission',
                controller.selectedTransmission,
                controller.transmissions,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildDropdownField(
                'Insurance',
                'Select Insurance',
                controller.selectedInsurance,
                controller.insuranceStatuses,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildTextField(
          'Kilometers Driven',
          'Enter kms driven',
          controller.kmsDrivenController,
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 24),
        Text.rich(
          const TextSpan(
            text: 'Location',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: primaryColor,
            ),
            children: [
              TextSpan(
                text: ' *',
                style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildDropdownField(
                'State',
                'Select State',
                controller.selectedState,
                controller.states,
                onChanged: (value) => controller.onStateChanged(value),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildDropdownField(
                'City',
                'Select City',
                controller.selectedCity,
                controller.cities,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildTextField(
          'Pincode',
          'Enter pincode',
          controller.pincodeController,
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 24),
        _buildSeatTypeSection(),
        const SizedBox(height: 24),
        _buildLicenseTypeSection(),
      ],
    );
  }

  Widget _buildDropdownField(
    String label,
    String hint,
    Rx<String?> selectedValue,
    RxList<String> items, {
    Function(String?)? onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text.rich(
          TextSpan(
            text: label,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: primaryColor,
            ),
            children: const [
              TextSpan(
                text: ' *',
                style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Obx(() {
          // Ensure unique items and filter out null/empty values
          final uniqueItems = items
              .where((item) => item.isNotEmpty)
              .toSet()
              .toList();

          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFFE0E0E0)),
              borderRadius: BorderRadius.circular(8),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                isExpanded: true,
                value: uniqueItems.contains(selectedValue.value)
                    ? selectedValue.value
                    : null,
                hint: Text(
                  hint,
                  style: const TextStyle(
                    color: Color(0xFF9E9E9E),
                    fontSize: 14,
                  ),
                ),
                icon: const Icon(
                  Icons.keyboard_arrow_down,
                  color: primaryColor,
                ),
                items: uniqueItems.map((String item) {
                  return DropdownMenuItem<String>(
                    value: item,
                    child: Text(item),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  selectedValue.value = newValue;
                  if (onChanged != null) {
                    onChanged(newValue);
                  }
                },
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildDropdownFieldWithoutLabel(
    String hint,
    Rx<String> selectedValue,
    RxList<String> items, {
    Function(String?)? onChanged,
  }) {
    return Obx(() {
      // Ensure unique items and filter out null/empty values
      final uniqueItems = items
          .where((item) => item.isNotEmpty)
          .toSet()
          .toList();

      return Container(
        height: 50, // Match typical text field height
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFFE0E0E0)),
          borderRadius: BorderRadius.circular(8),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            isExpanded: true,
            value: uniqueItems.contains(selectedValue.value)
                ? selectedValue.value
                : null,
            hint: Text(
              hint,
              style: const TextStyle(color: Color(0xFF9E9E9E), fontSize: 14),
            ),
            icon: const Icon(Icons.keyboard_arrow_down, color: primaryColor),
            items: uniqueItems.map((String item) {
              return DropdownMenuItem<String>(value: item, child: Text(item));
            }).toList(),
            onChanged: (String? newValue) {
              if (newValue != null) {
                selectedValue.value = newValue;
                if (onChanged != null) {
                  onChanged(newValue);
                }
              }
            },
          ),
        ),
      );
    });
  }

  Widget _buildTextField(
    String label,
    String hint,
    TextEditingController textController, {
    TextInputType keyboardType = TextInputType.text,
    Function(String)? onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text.rich(
          TextSpan(
            text: label,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: primaryColor,
            ),
            children: const [
              TextSpan(
                text: ' *',
                style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFFE0E0E0)),
            borderRadius: BorderRadius.circular(8),
          ),
          child: TextField(
            controller: textController,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(
                color: Color(0xFF9E9E9E),
                fontSize: 14,
              ),
              border: InputBorder.none,
            ),
            keyboardType: keyboardType,
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

  Widget _buildSeatTypeSection() {
    return Obx(
      () => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text.rich(
            const TextSpan(
              text: 'Seat Type',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: primaryColor,
              ),
              children: [
                TextSpan(
                  text: ' *',
                  style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildSeatButton(
                '2 Seater',
                controller.selectedSeatType.value == '2',
              ),
              const SizedBox(width: 12),
              _buildSeatButton(
                '5 Seater',
                controller.selectedSeatType.value == '5',
              ),
              const SizedBox(width: 12),
              _buildSeatButton(
                '7 Seater',
                controller.selectedSeatType.value == '7',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSeatButton(String text, bool isSelected) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          String seatNumber = text.split(' ')[0];
          controller.selectedSeatType.value = seatNumber;
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? primaryColor : Colors.transparent,
            border: Border.all(
              color: isSelected ? primaryColor : const Color(0xFFE0E0E0),
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected ? Colors.white : const Color(0xFF666666),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLicenseTypeSection() {
    return Obx(
      () => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text.rich(
            const TextSpan(
              text: 'License Type',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: primaryColor,
              ),
              children: [
                TextSpan(
                  text: ' *',
                  style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildLicenseButton(
                'Commercial',
                controller.selectedLicenseType.value == 'Commercial',
              ),
              const SizedBox(width: 12),
              _buildLicenseButton(
                'Non Commercial',
                controller.selectedLicenseType.value == 'Non Commercial',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLicenseButton(String text, bool isSelected) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          controller.selectedLicenseType.value = text;
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? primaryColor : Colors.transparent,
            border: Border.all(
              color: isSelected ? primaryColor : const Color(0xFFE0E0E0),
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected ? Colors.white : const Color(0xFF666666),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContinueButton() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: SizedBox(
        width: double.infinity,
        child: Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF4FC3F7), primaryColor],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(25),
          ),
          child: ElevatedButton(
            onPressed: () => _handleContinue(),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
            ),
            child: const Text(
              'Continue',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _handleContinue() async {
    print('🚀 CONTINUE BUTTON CLICKED!');

    // Show loading indicator
    Get.dialog(
      const Center(child: CircularProgressIndicator()),
      barrierDismissible: false,
    );

    print('Continue button pressed - starting validation');

    try {
      // Validation
      if (controller.imagePaths.isEmpty) {
        print('Validation failed: No image uploaded');
        Get.back(); // Close loading dialog
        _showErrorDialog('Please upload at least one car image');
        return;
      }

      if (controller.selectedOwner.value == null ||
          controller.selectedOwner.value!.isEmpty) {
        print('Validation failed: Owner not selected');
        Get.back(); // Close loading dialog
        _showErrorDialog('Please select ownership type');
        return;
      }

      // Brand name is mandatory
      if (controller.selectedCarName.value == null ||
          controller.selectedCarName.value!.isEmpty) {
        print('Validation failed: Brand not selected');
        Get.back();
        _showErrorDialog('Please select a brand name');
        return;
      }

      if (controller.carName.value.isEmpty) {
        print('Validation failed: Car name is empty');
        Get.back(); // Close loading dialog
        _showErrorDialog('Please enter car name');
        return;
      }

      if (controller.selectedVariant.value == null ||
          controller.selectedVariant.value!.isEmpty) {
        print('Validation failed: Variant not selected');
        Get.back(); // Close loading dialog
        _showErrorDialog('Please select variant');
        return;
      }

      if (controller.model.value.isEmpty) {
        print('Validation failed: Model is empty');
        Get.back(); // Close loading dialog
        _showErrorDialog('Please enter model');
        return;
      }

      if (controller.selectedYear.value == null ||
          controller.selectedYear.value!.isEmpty) {
        print('Validation failed: Year not selected');
        Get.back(); // Close loading dialog
        _showErrorDialog('Please select year');
        return;
      }

      if (controller.demandPrice.value.isEmpty) {
        print('Validation failed: Price is empty');
        Get.back(); // Close loading dialog
        _showErrorDialog('Please enter price');
        return;
      }

      if (controller.selectedColour.value == null ||
          controller.selectedColour.value!.isEmpty) {
        print('Validation failed: Colour not selected');
        Get.back(); // Close loading dialog
        _showErrorDialog('Please select colour');
        return;
      }

      if (controller.selectedFuelType.value == null ||
          controller.selectedFuelType.value!.isEmpty) {
        print('Validation failed: Fuel type not selected');
        Get.back(); // Close loading dialog
        _showErrorDialog('Please select fuel type');
        return;
      }

      if (controller.selectedTransmission.value == null ||
          controller.selectedTransmission.value!.isEmpty) {
        print('Validation failed: Transmission not selected');
        Get.back(); // Close loading dialog
        _showErrorDialog('Please select transmission');
        return;
      }

      if (controller.selectedInsurance.value == null ||
          controller.selectedInsurance.value!.isEmpty) {
        print('Validation failed: Insurance not selected');
        Get.back(); // Close loading dialog
        _showErrorDialog('Please select insurance status');
        return;
      }

      if (controller.kmsDriven.value.isEmpty) {
        print('Validation failed: Kilometers driven is empty');
        Get.back(); // Close loading dialog
        _showErrorDialog('Please enter kilometers driven');
        return;
      }

      if (controller.selectedSeatType.value.isEmpty) {
        print('Validation failed: Seat type not selected');
        Get.back(); // Close loading dialog
        _showErrorDialog('Please select seat type');
        return;
      }

      if (controller.selectedLicenseType.value.isEmpty) {
        print('Validation failed: License type not selected');
        Get.back(); // Close loading dialog
        _showErrorDialog('Please select license type');
        return;
      }

      if (controller.selectedState.value == null ||
          controller.selectedState.value!.isEmpty) {
        print('Validation failed: State not selected');
        Get.back(); // Close loading dialog
        _showErrorDialog('Please select state');
        return;
      }

      if (controller.selectedCity.value == null ||
          controller.selectedCity.value!.isEmpty) {
        print('Validation failed: City not selected');
        Get.back(); // Close loading dialog
        _showErrorDialog('Please select city');
        return;
      }

      if (controller.pincode.value.isEmpty) {
        print('Validation failed: Pincode is empty');
        Get.back(); // Close loading dialog
        _showErrorDialog('Please enter pincode');
        return;
      }

      print('All validations passed - building car object');

      // Build car object with all data including new fields
      final car = controller.buildCar();
      print('Car object built successfully: ${car.name} ${car.model}');

      // Save to Firebase
      print('Starting to save car to database...');
      await controller.saveCarToDatabase(car);
      print('Car saved successfully to database');

      // Refresh home controller to show new car
      try {
        if (Get.isRegistered<HomeController>()) {
          final homeController = Get.find<HomeController>();
          await homeController.refreshCars();
          print('Home controller refreshed');
        }
      } catch (e) {
        print('Error refreshing home controller: $e');
      }

      // Close loading dialog
      Get.back();

      // Show success dialog
      _showSuccessDialog();
    } catch (e) {
      print('Error saving car: $e');
      Get.back(); // Close loading dialog
      String errorMessage = e.toString().replaceAll('Exception: ', '').trim();
      _showErrorDialog(errorMessage);
    }
  }

  void _showSuccessDialog() {
    bool isClosed = false;

    void closeAndNavigate() {
      if (isClosed) return;
      isClosed = true;

      // Close dialog if it is still open
      if (Get.isDialogOpen == true) {
        Get.back();
      }

      // Clear form safely
      try {
        controller.clearForm();
      } catch (e) {
        print('Error clearing form: $e');
      }

      // Close AddCar page if it was opened as a separate route (edit mode)
      if (controller.isEditMode.value) {
        Get.back();
      } else {
        // Return to Home tab if it's part of the root navigation
        if (Get.isRegistered<RootController>()) {
          Get.find<RootController>().setIndex(0);
        }
      }
    }

    SuccessDialog.showGenericSuccess(
      title: 'Success',
      message: 'Car details saved successfully!\nYour new car will appear on the home screen.',
      buttonText: 'OK',
      onPressed: closeAndNavigate,
    );

    // Auto-dismiss after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      closeAndNavigate();
    });
  }

  void _showErrorDialog(String message) {
    ErrorDialog.show(message: message);
  }
}
