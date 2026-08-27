import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart' hide SearchController;
import 'package:get/get.dart';
import '../../../core/constants/app_color.dart';
import '../../../core/utils/app_button.dart';
import '../../../core/utils/ts.dart';
import '../../../core/utils/app_text.dart';
import '../../../core/utils/size.dart';
import '../../../core/utils/cached_image.dart';
import '../../../core/utils/price_formatter.dart';
import '../../routes/app_routes.dart';
import 'controller/search_controller.dart';
import '../root/controller/root_controller.dart';
import '../../../core/models/car.dart' as CarModel;

class SearchView extends GetView<SearchController> {
  const SearchView({super.key});

  @override
  Widget build(BuildContext context) {
    final SearchController controller = Get.isRegistered<SearchController>()
        ? Get.find<SearchController>()
        : Get.put(SearchController());

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (Get.isRegistered<RootController>()) {
        final rootController = Get.find<RootController>();
        final brand = rootController.getBrandFilterAndClear();
        if (brand != null && brand.isNotEmpty) {
          final brandTrimmed = brand.trim();
          controller.selectedBrandFilter.value = brandTrimmed;
          controller.searchTextController.text = '';
          controller.query.value = '';
          if (controller.allCars.isNotEmpty) {
            controller.applyFilters(brand: brandTrimmed);
          } else {
            controller.loadAllCars(initialBrand: brandTrimmed);
          }
        }
      }
    });

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        title: Obx(() {
          final hasBrandFilter =
              controller.selectedBrandFilter.value.isNotEmpty &&
              controller.selectedBrandFilter.value != 'All';
          return AppText(
            hasBrandFilter
                ? '${controller.selectedBrandFilter.value} Cars'
                : 'Search',
            style: Ts.semiBold16(color: AppColor.secondary),
          );
        }),
        centerTitle: false,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            child: Container(
              height: 44,
              decoration: BoxDecoration(
                color: AppColor.gray100,
                borderRadius: BorderRadius.circular(24),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: controller.searchTextController,
                      onSubmitted: controller.submit,
                      decoration: InputDecoration.collapsed(
                        hintText: 'Search car or dealer here',
                        hintStyle: Ts.regular12(color: AppColor.primary),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      controller.submit(controller.searchTextController.text);
                    },
                    child: const Icon(Icons.search, color: AppColor.textcolor),
                  ),
                  const SizedBox(width: 8),
                  Container(width: 1, height: 24, color: AppColor.gray300),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (context) =>
                            FilterSheetContent(controller: controller),
                      );
                    },
                    child: const Icon(Icons.tune, color: AppColor.textcolor),
                  ),
                ],
              ),
            ),
          ),
          Obx(() {
            final hasActiveFilters =
                controller.selectedBrandFilter.value.isNotEmpty ||
                controller.selectedModelFilter.value.isNotEmpty ||
                controller.selectedVariantFilter.value.isNotEmpty ||
                controller.selectedYearFilter.value.isNotEmpty ||
                controller.selectedColorFilter.value.isNotEmpty ||
                controller.selectedFuelTypes.isNotEmpty ||
                controller.selectedTransmissionFilter.value.isNotEmpty ||
                controller.selectedLicenseTypeFilter.value.isNotEmpty ||
                controller.selectedInsuranceFilter.value.isNotEmpty;

            if (!hasActiveFilters && controller.availableBrands.isEmpty) {
              return const SizedBox.shrink();
            }

            return Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8.0,
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _FilterChipWithDropdown(
                      label: 'Brand',
                      selectedValue:
                          controller.selectedBrandFilter.value.isEmpty ||
                              controller.selectedBrandFilter.value == 'All'
                          ? null
                          : controller.selectedBrandFilter.value,
                      options: ['All', ...controller.availableBrands],
                      onSelected: (value) {
                        controller.applyFilters(
                          brand: value == 'All' ? '' : value,
                        );
                      },
                    ),
                    const Wbox(8),
                    _FilterChipWithDropdown(
                      label: 'Year',
                      selectedValue:
                          controller.selectedYearFilter.value.isEmpty ||
                              controller.selectedYearFilter.value == 'All'
                          ? null
                          : controller.selectedYearFilter.value,
                      options: ['All', ...controller.availableYears],
                      onSelected: (value) {
                        controller.applyFilters(
                          year: value == 'All' ? '' : value,
                        );
                      },
                    ),
                    const Wbox(8),
                    _FilterChipWithDropdown(
                      label: 'Color',
                      selectedValue:
                          controller.selectedColorFilter.value.isEmpty ||
                              controller.selectedColorFilter.value == 'All'
                          ? null
                          : controller.selectedColorFilter.value,
                      options: ['All', ...controller.availableColors],
                      onSelected: (value) {
                        controller.applyFilters(
                          color: value == 'All' ? '' : value,
                        );
                      },
                    ),
                    const Wbox(8),
                    _FilterChipWithDropdown(
                      label: 'Fuel Type',
                      selectedValue: controller.selectedFuelTypes.isEmpty
                          ? null
                          : controller.selectedFuelTypes.join(', '),
                      options: ['All', ...controller.availableFuelTypes],
                      onSelected: (value) {
                        controller.applyFilters(
                          fuelTypes: value == 'All' ? [] : [value],
                        );
                      },
                    ),
                    const Wbox(8),
                    _FilterChipWithDropdown(
                      label: 'Transmission',
                      selectedValue:
                          controller.selectedTransmissionFilter.value.isEmpty ||
                              controller.selectedTransmissionFilter.value ==
                                  'All'
                          ? null
                          : controller.selectedTransmissionFilter.value,
                      options: ['All', ...controller.availableTransmissions],
                      onSelected: (value) {
                        controller.applyFilters(
                          transmission: value == 'All' ? '' : value,
                        );
                      },
                    ),
                    if (controller.availableModels.isNotEmpty) ...[
                      const Wbox(8),
                      _FilterChipWithDropdown(
                        label: 'Model',
                        selectedValue:
                            controller.selectedModelFilter.value.isEmpty ||
                                controller.selectedModelFilter.value == 'All'
                            ? null
                            : controller.selectedModelFilter.value,
                        options: ['All', ...controller.availableModels],
                        onSelected: (value) {
                          controller.applyFilters(
                            model: value == 'All' ? '' : value,
                          );
                        },
                      ),
                    ],
                    if (controller.availableVariants.isNotEmpty) ...[
                      const Wbox(8),
                      _FilterChipWithDropdown(
                        label: 'Variant',
                        selectedValue:
                            controller.selectedVariantFilter.value.isEmpty ||
                                controller.selectedVariantFilter.value == 'All'
                            ? null
                            : controller.selectedVariantFilter.value,
                        options: ['All', ...controller.availableVariants],
                        onSelected: (value) {
                          controller.applyFilters(
                            variant: value == 'All' ? '' : value,
                          );
                        },
                      ),
                    ],
                    if (controller.availableInsurances.isNotEmpty) ...[
                      const Wbox(8),
                      _FilterChipWithDropdown(
                        label: 'Insurance',
                        selectedValue:
                            controller.selectedInsuranceFilter.value.isEmpty ||
                                controller.selectedInsuranceFilter.value ==
                                    'All'
                            ? null
                            : controller.selectedInsuranceFilter.value,
                        options: ['All', ...controller.availableInsurances],
                        onSelected: (value) {
                          controller.applyFilters(
                            insurance: value == 'All' ? '' : value,
                          );
                        },
                      ),
                    ],
                    const Wbox(8),
                    _FilterChipWithDropdown(
                      label: 'License Type',
                      selectedValue:
                          controller.selectedLicenseTypeFilter.value.isEmpty ||
                              controller.selectedLicenseTypeFilter.value ==
                                  'All'
                          ? null
                          : controller.selectedLicenseTypeFilter.value,
                      options: ['All', 'Commercial', 'Non Commercial'],
                      onSelected: (value) {
                        controller.applyFilters(
                          licenseType: value == 'All' ? '' : value,
                        );
                      },
                    ),
                  ],
                ),
              ),
            );
          }),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                await controller.loadAllCars();
              },
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }

                final hasBrandFilter =
                    controller.selectedBrandFilter.value.isNotEmpty &&
                    controller.selectedBrandFilter.value != 'All';

                final resultsToShow =
                    (controller.query.value.isEmpty &&
                        !controller.hasActiveFilters)
                    ? controller.allCars
                    : controller.searchResults;

                if (controller.query.value.isEmpty &&
                    !controller.hasActiveFilters) {
                  if (controller.allCars.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.search_outlined,
                            size: 64,
                            color: AppColor.gray400,
                          ),
                          const Hbox(16),
                          AppText(
                            'Search for cars',
                            style: Ts.semiBold16(color: AppColor.textcolor),
                          ),
                          const Hbox(8),
                          AppText(
                            'Enter car name, model, brand, or dealer to search',
                            style: Ts.regular14(color: AppColor.gray600),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    );
                  }
                } else {
                  if (resultsToShow.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.search_off_outlined,
                            size: 64,
                            color: AppColor.gray400,
                          ),
                          const Hbox(16),
                          AppText(
                            'No results found',
                            style: Ts.semiBold16(color: AppColor.textcolor),
                          ),
                          const Hbox(8),
                          AppText(
                            hasBrandFilter
                                ? 'No ${controller.selectedBrandFilter.value} cars found'
                                : 'Try searching with different keywords',
                            style: Ts.regular14(color: AppColor.gray600),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    );
                  }
                }

                if (resultsToShow.isEmpty) {
                  return SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: SizedBox(
                      height: MediaQuery.of(context).size.height * 0.5,
                      child: const Center(child: SizedBox.shrink()),
                    ),
                  );
                }

                final resultCount = resultsToShow.length;

                String titleText;
                if (hasBrandFilter) {
                  titleText = '${controller.selectedBrandFilter.value} Cars';
                } else if (controller.query.value.isEmpty) {
                  titleText = 'All Cars';
                } else {
                  titleText = 'Results for "${controller.query.value}"';
                }

                return CustomScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  slivers: [
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      sliver: SliverToBoxAdapter(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                                  child: AppText(
                                    titleText,
                                    style: Ts.semiBold14(
                                      color: AppColor.textcolor,
                                    ),
                                  ),
                                ),
                                AppText(
                                  '$resultCount found',
                                  style: Ts.semiBold12(
                                    color: AppColor.textcolor,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                          ],
                        ),
                      ),
                    ),
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      sliver: SliverGrid(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 16,
                              childAspectRatio: 1,
                            ),
                        delegate: SliverChildBuilderDelegate((context, index) {
                          final car = resultsToShow[index];
                          final carKey = controller.getCarKey(car);
                          final carId = controller.carIdMap[carKey];

                          String imageUrl = '';
                          if (car.imagePaths.isNotEmpty) {
                            final firstImage = car.imagePaths.first;
                            if (firstImage.startsWith('[') &&
                                firstImage.endsWith(']')) {
                              try {
                                final List<dynamic> parsed = jsonDecode(
                                  firstImage,
                                );
                                imageUrl = parsed.isNotEmpty
                                    ? parsed.first.toString()
                                    : '';
                              } catch (e) {
                                imageUrl = firstImage;
                              }
                            } else {
                              imageUrl = firstImage;
                            }
                          }

                          final isAvailable = carId != null
                              ? (controller.carAvailabilityMap[carId] ?? true)
                              : true;
                          return GestureDetector(
                            onTap: () async {
                              await Get.toNamed(
                                AppRoutes.carDetail,
                                arguments: {'car': car, 'carId': carId},
                              );
                              controller.refreshSearchData();
                            },
                            child: _CarResultCard(
                              imageUrl: imageUrl,
                              title: car.name.isNotEmpty ? car.name : 'N/A',
                              variant: car.variant.isNotEmpty
                                  ? car.variant
                                  : (car.model.isNotEmpty ? car.model : ''),
                              spec1: car.owner.isNotEmpty ? car.owner : 'N/A',
                              price: PriceFormatter.formatPrice(
                                car.demandPrice,
                              ),
                              isAvailable: isAvailable,
                            ),
                          );
                        }, childCount: resultsToShow.length),
                      ),
                    ),
                  ],
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}

class FilterSheetContent extends StatefulWidget {
  final SearchController controller;

  const FilterSheetContent({super.key, required this.controller});

  @override
  _FilterSheetContentState createState() => _FilterSheetContentState();
}

class _FilterSheetContentState extends State<FilterSheetContent> {
  double tempMinPrice = 0.0;
  double tempMaxPrice = 0.0;
  String tempSelectedBrand = '';
  String tempSelectedModel = '';
  String tempSelectedColor = '';
  String tempSortBy = '';
  String tempSelectedFuelType = 'All';
  String tempSelectedTransmission = 'All';
  String tempSelectedLicenseType = 'All';
  String tempSelectedState = 'All';
  String tempSelectedCity = 'All';
  String tempSelectedPincode = 'All';
  String tempSelectedSeatType = 'All';
  double maxPriceRange = 200.0;

  // Custom text input for Others
  final TextEditingController _customBrandController = TextEditingController();
  final TextEditingController _customColorController = TextEditingController();
  final TextEditingController _pincodeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    tempMinPrice = widget.controller.minPrice.value;
    tempMaxPrice = widget.controller.maxPrice.value;
    tempSelectedBrand = widget.controller.selectedBrandFilter.value;
    tempSelectedModel = widget.controller.selectedModelFilter.value;
    tempSelectedColor = widget.controller.selectedColorFilter.value;
    tempSortBy = widget.controller.selectedSortBy.value;

    if (widget.controller.selectedFuelTypes.isNotEmpty) {
      tempSelectedFuelType = widget.controller.selectedFuelTypes.first;
    } else {
      tempSelectedFuelType = 'All';
    }

    tempSelectedTransmission =
        widget.controller.selectedTransmissionFilter.value.isEmpty
        ? 'All'
        : widget.controller.selectedTransmissionFilter.value;

    tempSelectedLicenseType =
        widget.controller.selectedLicenseTypeFilter.value.isEmpty
        ? 'All'
        : widget.controller.selectedLicenseTypeFilter.value;
        
    tempSelectedState =
        widget.controller.selectedStateFilter.value.isEmpty
        ? 'All'
        : widget.controller.selectedStateFilter.value;

    tempSelectedCity =
        widget.controller.selectedCityFilter.value.isEmpty
        ? 'All'
        : widget.controller.selectedCityFilter.value;
        
    tempSelectedPincode =
        widget.controller.selectedPincodeFilter.value.isEmpty
        ? 'All'
        : widget.controller.selectedPincodeFilter.value;
        
    tempSelectedSeatType =
        widget.controller.selectedSeatTypeFilter.value.isEmpty
        ? 'All'
        : widget.controller.selectedSeatTypeFilter.value;

    _pincodeController.text = widget.controller.selectedPincodeFilter.value;

    maxPriceRange = widget.controller.maxPrice.value;
    if (maxPriceRange < 200.0) maxPriceRange = 200.0;

    if (tempSelectedBrand.isNotEmpty &&
        tempSelectedBrand != 'All' &&
        !widget.controller.availableBrands.contains(tempSelectedBrand)) {
      _customBrandController.text = tempSelectedBrand;
      tempSelectedBrand = 'Others';
    }

    if (tempSelectedColor.isNotEmpty &&
        tempSelectedColor != 'All' &&
        !widget.controller.availableColors.contains(tempSelectedColor)) {
      _customColorController.text = tempSelectedColor;
      tempSelectedColor = 'Others';
    }
  }
  List<String> getFilteredCities() {
    if (tempSelectedState.isEmpty || tempSelectedState == 'All') {
      return widget.controller.availableCities.toList();
    }
    final cities = widget.controller.allCars
        .where((car) => car.state.toLowerCase().trim() == tempSelectedState.toLowerCase().trim())
        .map((car) => car.city)
        .where((city) => city.isNotEmpty)
        .toSet()
        .toList();
    cities.sort();
    return cities;
  }

  List<String> getFilteredPincodes() {
    Iterable<CarModel.Car> cars = widget.controller.allCars;
    if (tempSelectedState.isNotEmpty && tempSelectedState != 'All') {
      cars = cars.where((car) => car.state.toLowerCase().trim() == tempSelectedState.toLowerCase().trim());
    }
    if (tempSelectedCity.isNotEmpty && tempSelectedCity != 'All') {
      cars = cars.where((car) => car.city.toLowerCase().trim() == tempSelectedCity.toLowerCase().trim());
    }
    final pincodes = cars
        .map((car) => car.pincode)
        .where((pin) => pin.isNotEmpty)
        .toSet()
        .toList();
    pincodes.sort();
    return pincodes;
  }

  Widget _buildDropdown({
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    // Ensure 'All' is present and handle potential duplicates gracefully
    final Set<String> uniqueItems = {'All', ...items};
    // Ensure current value is in the list, otherwise append it
    if (value.isNotEmpty && !uniqueItems.contains(value)) {
      uniqueItems.add(value);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColor.gray200),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          value: value.isEmpty ? 'All' : value,
          items: uniqueItems.map((String val) {
            return DropdownMenuItem<String>(
              value: val,
              child: AppText(
                val,
                style: Ts.regular14(color: AppColor.textcolor),
              ),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.only(top: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColor.gray300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: AppText(
                          'Sort & Filter',
                          style: Ts.semiBold18(color: AppColor.secondary),
                        ),
                      ),
                      const Hbox(24),

                      Obx(() {
                        if (widget.controller.availableBrands.isEmpty) {
                          return const SizedBox.shrink();
                        }
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AppText(
                              'Car Brand',
                              style: Ts.semiBold16(color: AppColor.textcolor),
                            ),
                            _buildDropdown(
                              value: tempSelectedBrand,
                              items: [
                                ...widget.controller.availableBrands,
                                'Others',
                              ],
                              onChanged: (newValue) {
                                setState(() {
                                  tempSelectedBrand = newValue ?? 'All';
                                  if (tempSelectedBrand != 'Others') {
                                    _customBrandController.clear();
                                  }
                                });
                              },
                            ),
                            if (tempSelectedBrand == 'Others')
                              Padding(
                                padding: const EdgeInsets.only(top: 12),
                                child: TextField(
                                  controller: _customBrandController,
                                  decoration: InputDecoration(
                                    hintText: 'Enter brand name...',
                                    hintStyle: Ts.regular14(
                                      color: AppColor.gray400,
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 12,
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: const BorderSide(
                                        color: AppColor.gray300,
                                      ),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: const BorderSide(
                                        color: AppColor.gray300,
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: const BorderSide(
                                        color: AppColor.secondary,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            const Hbox(20),
                          ],
                        );
                      }),

                      Obx(() {
                        if (widget.controller.availableModels.isEmpty) {
                          return const SizedBox.shrink();
                        }
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AppText(
                              'Model',
                              style: Ts.semiBold16(color: AppColor.textcolor),
                            ),
                            const Hbox(12),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: AppColor.gray200),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  isExpanded: true,
                                  value: tempSelectedModel.isEmpty
                                      ? 'All'
                                      : tempSelectedModel,
                                  items:
                                      [
                                        'All',
                                        ...widget.controller.availableModels,
                                      ].map((String value) {
                                        return DropdownMenuItem<String>(
                                          value: value,
                                          child: AppText(
                                            value,
                                            style: Ts.regular14(
                                              color: AppColor.textcolor,
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                  onChanged: (newValue) {
                                    setState(() {
                                      tempSelectedModel = newValue ?? 'All';
                                    });
                                  },
                                ),
                              ),
                            ),
                            const Hbox(20),
                          ],
                        );
                      }),


                      // Grouping requested filters: State, City, Pincode, Colour, Fuel, Type, Transmission
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AppText(
                            'Location & Details',
                            style: Ts.semiBold16(color: AppColor.textcolor),
                          ),
                          const Hbox(12),
                          
                          // (a) State
                          AppText('State', style: Ts.regular14(color: AppColor.textcolor)),
                          const Hbox(4),
                          Obx(() => _buildDropdown(
                            value: tempSelectedState,
                            items: widget.controller.availableStates.toList(),
                            onChanged: (newValue) {
                              setState(() {
                                tempSelectedState = newValue ?? 'All';
                                tempSelectedCity = 'All';
                                tempSelectedPincode = 'All';
                              });
                            },
                          )),
                          const Hbox(12),

                          // (b) City
                          AppText('City', style: Ts.regular14(color: AppColor.textcolor)),
                          const Hbox(4),
                          Obx(() => _buildDropdown(
                            value: tempSelectedCity,
                            items: getFilteredCities(),
                            onChanged: (newValue) {
                              setState(() {
                                tempSelectedCity = newValue ?? 'All';
                                tempSelectedPincode = 'All';
                              });
                            },
                          )),
                          const Hbox(12),

                          // (c) Pincode
                          AppText('Pincode', style: Ts.regular14(color: AppColor.textcolor)),
                          const Hbox(4),
                          Obx(() => _buildDropdown(
                            value: tempSelectedPincode,
                            items: getFilteredPincodes(),
                            onChanged: (newValue) {
                              setState(() {
                                tempSelectedPincode = newValue ?? 'All';
                              });
                            },
                          )),
                          const Hbox(20),

                          // (d) Colour
                          AppText('Colour', style: Ts.semiBold16(color: AppColor.textcolor)),
                          const Hbox(4),
                          Obx(() => _buildDropdown(
                            value: tempSelectedColor,
                            items: [...widget.controller.availableColors, 'Others'],
                            onChanged: (newValue) {
                              setState(() {
                                tempSelectedColor = newValue ?? 'All';
                                if (tempSelectedColor != 'Others') _customColorController.clear();
                              });
                            },
                          )),
                          if (tempSelectedColor == 'Others')
                            Padding(
                              padding: const EdgeInsets.only(top: 12),
                              child: TextField(
                                controller: _customColorController,
                                decoration: InputDecoration(
                                  hintText: 'Enter colour...',
                                  hintStyle: Ts.regular14(color: AppColor.gray400),
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                                ),
                              ),
                            ),
                          const Hbox(20),

                          // (e) Fuel
                          AppText('Fuel', style: Ts.semiBold16(color: AppColor.textcolor)),
                          const Hbox(4),
                          Obx(() => _buildDropdown(
                            value: tempSelectedFuelType,
                            items: widget.controller.availableFuelTypes.toList(),
                            onChanged: (newValue) {
                              setState(() {
                                tempSelectedFuelType = newValue ?? 'All';
                              });
                            },
                          )),
                          const Hbox(20),

                          // (f) Type (Seats)
                          AppText('Type (Seats)', style: Ts.semiBold16(color: AppColor.textcolor)),
                          const Hbox(4),
                          Obx(() => _buildDropdown(
                            value: tempSelectedSeatType,
                            items: widget.controller.availableSeatTypes.toList(),
                            onChanged: (newValue) {
                              setState(() {
                                tempSelectedSeatType = newValue ?? 'All';
                              });
                            },
                          )),
                          const Hbox(20),

                          // (g) Transmission
                          AppText('Transmission', style: Ts.semiBold16(color: AppColor.textcolor)),
                          const Hbox(4),
                          Obx(() => _buildDropdown(
                            value: tempSelectedTransmission,
                            items: widget.controller.availableTransmissions.toList(),
                            onChanged: (newValue) {
                              setState(() {
                                tempSelectedTransmission = newValue ?? 'All';
                              });
                            },
                          )),
                          const Hbox(20),

                          // (h) License Type
                          AppText('License Type', style: Ts.semiBold16(color: AppColor.textcolor)),
                          const Hbox(4),
                          Obx(() => _buildDropdown(
                            value: tempSelectedLicenseType,
                            items: widget.controller.availableLicenseTypes.toList(),
                            onChanged: (newValue) {
                              setState(() {
                                tempSelectedLicenseType = newValue ?? 'All';
                              });
                            },
                          )),
                          const Hbox(20),
                        ],
                      ),

                      AppText(
                        'Price range (Lakhs)',
                        style: Ts.semiBold16(color: AppColor.textcolor),
                      ),
                      const Hbox(12),
                      _PriceRangeSlider(
                        minValue: tempMinPrice,
                        maxValue: tempMaxPrice,
                        maxRange: maxPriceRange,
                        onChanged: (min, max) {
                          setState(() {
                            tempMinPrice = min;
                            tempMaxPrice = max;
                          });
                        },
                      ),
                      const Hbox(20),

                      AppText(
                        'Sort By',
                        style: Ts.semiBold16(color: AppColor.textcolor),
                      ),
                      const Hbox(12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _FilterChip(
                            label: 'Most Recent',
                            isSelected: tempSortBy == 'Most Recent',
                            onTap: () =>
                                setState(() => tempSortBy = 'Most Recent'),
                          ),
                          _FilterChip(
                            label: 'Car Name (Brand)',
                            isSelected: tempSortBy == 'Car Name (Brand)',
                            onTap: () =>
                                setState(() => tempSortBy = 'Car Name (Brand)'),
                          ),
                          _FilterChip(
                            label: 'Model',
                            isSelected: tempSortBy == 'Model',
                            onTap: () => setState(() => tempSortBy = 'Model'),
                          ),
                          _FilterChip(
                            label: 'Variant',
                            isSelected: tempSortBy == 'Variant',
                            onTap: () => setState(() => tempSortBy = 'Variant'),
                          ),
                          _FilterChip(
                            label: 'Fuel Type',
                            isSelected: tempSortBy == 'Fuel Type',
                            onTap: () =>
                                setState(() => tempSortBy = 'Fuel Type'),
                          ),
                          _FilterChip(
                            label: 'Color',
                            isSelected: tempSortBy == 'Color',
                            onTap: () => setState(() => tempSortBy = 'Color'),
                          ),
                          _FilterChip(
                            label: 'Km Driven',
                            isSelected: tempSortBy == 'Km Driven',
                            onTap: () =>
                                setState(() => tempSortBy = 'Km Driven'),
                          ),
                          _FilterChip(
                            label: 'Transmission',
                            isSelected: tempSortBy == 'Transmission',
                            onTap: () =>
                                setState(() => tempSortBy = 'Transmission'),
                          ),
                          _FilterChip(
                            label: 'Insurance',
                            isSelected: tempSortBy == 'Insurance',
                            onTap: () =>
                                setState(() => tempSortBy = 'Insurance'),
                          ),
                          _FilterChip(
                            label: 'low to high',
                            isSelected: tempSortBy == 'low to high',
                            onTap: () =>
                                setState(() => tempSortBy = 'low to high'),
                          ),
                          _FilterChip(
                            label: 'high to low',
                            isSelected: tempSortBy == 'high to low',
                            onTap: () =>
                                setState(() => tempSortBy = 'high to low'),
                          ),
                          _FilterChip(
                            label: '5 seater',
                            isSelected: tempSortBy == '5 seater',
                            onTap: () =>
                                setState(() => tempSortBy = '5 seater'),
                          ),
                          _FilterChip(
                            label: '7 seater',
                            isSelected: tempSortBy == '7 seater',
                            onTap: () =>
                                setState(() => tempSortBy = '7 seater'),
                          ),
                        ],
                      ),
                      const Hbox(30),
                    ],
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 30),
                child: Row(
                  children: [
                    Expanded(
                      child: AppButton(
                        text: 'Clear',
                        useGradient: false,
                        bgColor: AppColor.gray100,
                        textColor: AppColor.gray600,
                        onPressed: () {
                          widget.controller.clearFilters();
                          Navigator.pop(context);
                        },
                        height: 50,
                        borderRadius: 10,
                      ),
                    ),
                    const Wbox(12),
                    Expanded(
                      child: AppButton(
                        text: 'Apply',
                        useGradient: false,
                        bgColor: AppColor.secondary,
                        textColor: Colors.white,
                        onPressed: () {
                          String finalBrand = tempSelectedBrand;
                          if (tempSelectedBrand == 'Others') {
                            if (_customBrandController.text.trim().isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Please enter a custom Car Brand name'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                              return;
                            }
                            finalBrand = _customBrandController.text.trim();
                          }

                          String finalColor = tempSelectedColor;
                          if (tempSelectedColor == 'Others') {
                            finalColor = _customColorController.text.trim().isNotEmpty
                                ? _customColorController.text.trim()
                                : 'All';
                          }

                          widget.controller.applyFilters(
                            brand: finalBrand == 'All' ? '' : finalBrand,
                            model: tempSelectedModel == 'All'
                                ? ''
                                : tempSelectedModel,
                            year: '', // Removed from UI
                            color: finalColor == 'All' ? '' : finalColor,
                            fuelTypes: tempSelectedFuelType == 'All'
                                ? []
                                : [tempSelectedFuelType],
                            transmission: tempSelectedTransmission == 'All'
                                ? ''
                                : tempSelectedTransmission,
                            licenseType:
                                tempSelectedLicenseType == 'All' ||
                                    tempSelectedLicenseType.isEmpty
                                ? ''
                                : tempSelectedLicenseType,
                            state: tempSelectedState == 'All' ? '' : tempSelectedState,
                            city: tempSelectedCity == 'All' ? '' : tempSelectedCity,
                            pincode: tempSelectedPincode == 'All' ? '' : tempSelectedPincode,
                            seatType: tempSelectedSeatType == 'All' ? '' : tempSelectedSeatType,
                            sortBy: tempSortBy,
                            minPriceValue: tempMinPrice,
                            maxPriceValue: tempMaxPrice,
                          );
                          Navigator.pop(context);
                        },
                        height: 50,
                        borderRadius: 10,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _PriceRangeSlider extends StatefulWidget {
  final double minValue;
  final double maxValue;
  final double maxRange;
  final Function(double, double) onChanged;

  const _PriceRangeSlider({
    required this.minValue,
    required this.maxValue,
    required this.maxRange,
    required this.onChanged,
  });

  @override
  _PriceRangeSliderState createState() => _PriceRangeSliderState();
}

class _PriceRangeSliderState extends State<_PriceRangeSlider> {
  late double _minValue;
  late double _maxValue;

  @override
  void initState() {
    super.initState();
    _minValue = widget.minValue;
    _maxValue = widget.maxValue;
  }

  @override
  void didUpdateWidget(_PriceRangeSlider oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.minValue != widget.minValue ||
        oldWidget.maxValue != widget.maxValue) {
      _minValue = widget.minValue;
      _maxValue = widget.maxValue;
    }
  }

  String _formatPriceValue(double valueInLakhs) {
    if (valueInLakhs < 1) {
      return '${(valueInLakhs * 100).toInt()}k';
    } else if (valueInLakhs >= 100) {
      double cr = valueInLakhs / 100;
      return '${cr == cr.toInt().toDouble() ? cr.toInt() : cr.toStringAsFixed(2)} Cr';
    } else {
      return '${valueInLakhs == valueInLakhs.toInt().toDouble() ? valueInLakhs.toInt() : valueInLakhs.toStringAsFixed(1)}L';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            AppText(
              _formatPriceValue(_minValue),
              style: Ts.regular14(color: AppColor.gray600),
            ),
            const Spacer(),
            AppText(
              _formatPriceValue(_maxValue),
              style: Ts.regular14(color: AppColor.gray600),
            ),
          ],
        ),
        const Hbox(16),
        Container(
          height: 40,
          child: RangeSlider(
            values: RangeValues(_minValue, _maxValue),
            min: 0.0,
            max: widget.maxRange,
            divisions: widget.maxRange > 0
                ? (widget.maxRange * 20).toInt()
                : 100,
            activeColor: AppColor.secondary,
            inactiveColor: AppColor.gray200,
            onChanged: (RangeValues values) {
              setState(() {
                _minValue = values.start < 0.35 ? 0.35 : values.start;
                _maxValue = values.end;
              });
              widget.onChanged(_minValue, _maxValue);
            },
          ),
        ),
      ],
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({required this.label, this.isSelected = false, this.onTap});
  final String label;
  final bool isSelected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColor.secondary.withOpacity(0.1)
              : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColor.secondary : AppColor.gray200,
            width: 1,
          ),
        ),
        child: AppText(
          label,
          style: Ts.regular14(
            color: isSelected ? AppColor.secondary : AppColor.gray600,
          ),
        ),
      ),
    );
  }
}

class _FilterChipWithDropdown extends StatelessWidget {
  const _FilterChipWithDropdown({
    required this.label,
    this.selectedValue,
    required this.options,
    required this.onSelected,
  });

  final String label;
  final String? selectedValue;
  final List<String> options;
  final Function(String) onSelected;

  @override
  Widget build(BuildContext context) {
    final isSelected = selectedValue != null && selectedValue!.isNotEmpty;

    return GestureDetector(
      onTap: () {
        _showDropdown(context);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColor.secondary.withOpacity(0.1)
              : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColor.secondary : AppColor.gray200,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppText(
              isSelected ? selectedValue! : label,
              style: isSelected
                  ? Ts.semiBold12(color: AppColor.secondary)
                  : Ts.regular12(color: AppColor.gray600),
            ),
            const Wbox(4),
            Icon(
              Icons.arrow_drop_down,
              size: 18,
              color: isSelected ? AppColor.secondary : AppColor.gray600,
            ),
          ],
        ),
      ),
    );
  }

  void _showDropdown(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColor.gray300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: AppText(
                  'Select $label',
                  style: Ts.semiBold16(color: AppColor.secondary),
                ),
              ),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: options.length,
                  itemBuilder: (context, index) {
                    final option = options[index];
                    final isOptionSelected =
                        selectedValue == option ||
                        (option == 'All' &&
                            (selectedValue == null || selectedValue!.isEmpty));

                    return ListTile(
                      title: AppText(
                        option,
                        style: isOptionSelected
                            ? Ts.semiBold14(color: AppColor.secondary)
                            : Ts.regular14(color: AppColor.textcolor),
                      ),
                      trailing: isOptionSelected
                          ? Icon(
                              Icons.check,
                              color: AppColor.secondary,
                              size: 20,
                            )
                          : null,
                      onTap: () {
                        onSelected(option);
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }
}

class _CarResultCard extends StatelessWidget {
  const _CarResultCard({
    required this.imageUrl,
    required this.title,
    required this.variant,
    required this.spec1,
    required this.price,
    this.isAvailable = true,
  });

  final String imageUrl;
  final String title;
  final String variant;
  final String spec1;
  final String price;
  final bool isAvailable;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFB7CAE6)),
          ),
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Stack(
                  children: [
                    imageUrl.isNotEmpty
                        ? (imageUrl.startsWith('http://') ||
                                  imageUrl.startsWith('https://'))
                              ? CachedImage(
                                  imageUrl: imageUrl,
                                  height: 70,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                  errorWidget: Container(
                                    height: 70,
                                    width: double.infinity,
                                    color: AppColor.gray200,
                                    child: const Icon(Icons.error, size: 24),
                                  ),
                                )
                              : Image.file(
                                  File(imageUrl),
                                  height: 70,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      Container(
                                        height: 70,
                                        width: double.infinity,
                                        color: AppColor.gray200,
                                        child: const Icon(
                                          Icons.error,
                                          size: 24,
                                        ),
                                      ),
                                )
                        : Container(
                            height: 70,
                            width: double.infinity,
                            color: AppColor.gray200,
                            child: const Icon(
                              Icons.image_not_supported,
                              size: 24,
                            ),
                          ),
                    if (!isAvailable)
                      Container(
                        height: 70,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                  ],
                ),
              ),
              const Hbox(6),
              AppText(title, style: Ts.semiBold12(color: AppColor.secondary)),
              AppText(variant, style: Ts.regular10(color: AppColor.textcolor)),
              AppText(spec1, style: Ts.regular10(color: AppColor.gray600)),
              const Hbox(4),
              AppText(price, style: Ts.semiBold12(color: AppColor.secondary)),
            ],
          ),
        ),
        if (!isAvailable)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            bottom: 0,
            child: Center(
              child: Transform.rotate(
                angle: -0.5,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.red.shade700,
                    borderRadius: BorderRadius.circular(4),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    'SOLD',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                ),
              ),
            ),
          ),
        Positioned(
          right: 8,
          top: 8,
          child: GestureDetector(
            onTap: () {},
            child: Icon(
              Icons.favorite_border,
              size: 18,
              color: AppColor.gray400,
            ),
          ),
        ),
      ],
    );
  }
}
