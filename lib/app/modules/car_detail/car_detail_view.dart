import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_color.dart';
import '../../../core/utils/ts.dart';
import '../../../core/utils/app_text.dart';
import '../../../core/utils/size.dart';
import '../../../core/utils/cached_image.dart';
import 'controller/car_detail_controller.dart';
import '../dealer/dealer_view.dart';
import '../../../core/utils/price_formatter.dart';
class CarDetailView extends GetView<CarDetailController> {
  const CarDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        automaticallyImplyLeading: true,
        title: AppText(
          'Car Detail',
          style: Ts.semiBold16(color: AppColor.secondary),
        ),
        centerTitle: false,
        actions: [
          Obx(() {
            if (controller.car == null) return const SizedBox.shrink();

            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (controller.isUserCar.value) ...[
                  controller.isDeletingCar.value
                      ? const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.red,
                              strokeWidth: 2,
                            ),
                          ),
                        )
                      : IconButton(
                          icon: const Icon(
                            Icons.delete_outline,
                            color: Colors.red,
                            size: 24,
                          ),
                          onPressed: () => controller.deleteCar(),
                        ),
                ],
                IconButton(
                  icon: Icon(
                    controller.isInWishlist.value
                        ? Icons.favorite
                        : Icons.favorite_border,
                    color: controller.isInWishlist.value
                        ? Colors.red
                        : AppColor.gray400,
                    size: 28,
                  ),
                  onPressed: () => controller.toggleWishlist(),
                ),
              ],
            );
          }),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        final car = controller.car;
        if (car == null) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.info_outline,
                    size: 48,
                    color: AppColor.gray500,
                  ),
                  const Hbox(12),
                  AppText(
                    'No car data found',
                    style: Ts.semiBold16(color: AppColor.secondary),
                  ),
                  const Hbox(6),
                  AppText(
                    'Please navigate here using Add Car or pass a valid car argument.',
                    style: Ts.regular12(color: AppColor.gray600),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        }

        return Obx(() {
          final selectedImageIndex = controller.selectedImageIndex.value;
          final displayImage = car.imagePaths.isNotEmpty
              ? car.imagePaths[selectedImageIndex.clamp(
                  0,
                  car.imagePaths.length - 1,
                )]
              : null;

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Hbox(12),
                // Main Car Image
                if (displayImage != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: _buildMainImage(displayImage),
                  )
                else
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      height: 200,
                      width: double.infinity,
                      color: AppColor.gray200,
                      child: const Center(
                        child: Icon(
                          Icons.car_rental,
                          size: 60,
                          color: AppColor.gray500,
                        ),
                      ),
                    ),
                  ),
                const Hbox(12),

                // Car Name and Model
                AppText(
                  '${car.name} ${car.model}'.trim(),
                  style: Ts.semiBold18(color: AppColor.textcolor),
                ),
                const Hbox(6),

                // Clickable Owner/Dealer Name (This should navigate to dealer page)
                Obx(() {
                  final ownerName = controller.sellerName.value.isNotEmpty
                      ? controller.sellerName.value
                      : (car.owner.isNotEmpty ? car.owner : 'Owner');
                  return GestureDetector(
                    onTap: controller.sellerId.value.isNotEmpty
                        ? () => _navigateToDealerPage()
                        : null,
                    child: Row(
                      children: [
                        Icon(
                          Icons.store_outlined,
                          size: 16,
                          color: controller.sellerId.value.isNotEmpty
                              ? AppColor.secondary
                              : AppColor.gray500,
                        ),
                        const Wbox(6),
                        AppText(
                          ownerName,
                          style: Ts.regular14(
                            color: controller.sellerId.value.isNotEmpty
                                ? AppColor.secondary
                                : AppColor.gray600,
                          ),
                        ),
                        if (controller.sellerId.value.isNotEmpty) ...[
                          const Wbox(4),
                          Icon(
                            Icons.arrow_forward_ios,
                            size: 12,
                            color: AppColor.secondary,
                          ),
                        ],
                      ],
                    ),
                  );
                }),
                const Hbox(8),

                // Car Price
                AppText(
                  car.demandPrice.isNotEmpty
                      ? PriceFormatter.formatPriceReadable(car.demandPrice)
                      : 'Price not available',
                  style: Ts.semiBold16(color: AppColor.secondary),
                ),
                const Hbox(12),

                // Image Thumbnails
                if (car.imagePaths.isNotEmpty)
                  SizedBox(
                    height: 64,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: car.imagePaths.length,
                      separatorBuilder: (_, __) => const Wbox(8),
                      itemBuilder: (context, i) => GestureDetector(
                        onTap: () => controller.selectImage(i),
                        child: Obx(() {
                          final isSelected =
                              controller.selectedImageIndex.value == i;
                          return Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: isSelected
                                    ? AppColor.secondary
                                    : Colors.transparent,
                                width: 2,
                              ),
                            ),
                            child: _buildImageThumbnail(car.imagePaths[i]),
                          );
                        }),
                      ),
                    ),
                  ),
                const Hbox(16),

                // Car Specifications
                _buildSpecGrid(car),
                const Hbox(16),

                // Car Details Section
                _buildDetailsSection(car),
                const Hbox(24),

                // Action Buttons
                _buildActionButtons(),
                const Hbox(24),
              ],
            ),
          );
        });
      }),
    );
  }

  // Navigate to Dealer Page (This is where the dealer layout should go)
  void _navigateToDealerPage() {
    final car = controller.car;
    if (car == null) return;

    // Navigate to the separate dealer page with proper dealer ID
    Get.to(
      () => const DealerView(),
      arguments: {
        'dealerId': controller.sellerId.value, // Pass the actual dealer ID
      },
    );
  }

  // Build Main Car Image
  Widget _buildMainImage(String imagePath) {
    final bool isNetworkImage =
        imagePath.startsWith('http://') || imagePath.startsWith('https://');

    if (isNetworkImage) {
      return CachedImage(
        imageUrl: imagePath,
        height: 200,
        width: double.infinity,
        fit: BoxFit.cover,
        errorWidget: Container(
          height: 200,
          width: double.infinity,
          color: AppColor.gray200,
          child: const Center(
            child: Icon(Icons.car_rental, size: 60, color: AppColor.gray500),
          ),
        ),
      );
    } else {
      return Container(
        height: 200,
        width: double.infinity,
        color: AppColor.gray200,
        child: const Center(
          child: Icon(Icons.car_rental, size: 60, color: AppColor.gray500),
        ),
      );
    }
  }

  // Build Image Thumbnail
  Widget _buildImageThumbnail(String imagePath) {
    final bool isNetworkImage =
        imagePath.startsWith('http://') || imagePath.startsWith('https://');

    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: isNetworkImage
          ? CachedImage(
              imageUrl: imagePath,
              height: 64,
              width: 96,
              fit: BoxFit.cover,
              errorWidget: Container(
                height: 64,
                width: 96,
                color: AppColor.gray200,
                child: const Icon(
                  Icons.car_rental,
                  size: 20,
                  color: AppColor.gray500,
                ),
              ),
            )
          : Container(
              height: 64,
              width: 96,
              color: AppColor.gray200,
              child: const Icon(
                Icons.car_rental,
                size: 20,
                color: AppColor.gray500,
              ),
            ),
    );
  }

  // Build Specification Item (always shows, using '-' fallback if value is empty/null/NA)
  Widget _buildSpecItem(IconData icon, String value, String label) {
    final displayValue = (value.trim().isEmpty || value.trim() == '-' || value.toLowerCase() == 'n/a') ? '-' : value;

    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            height: 32,
            width: 32,
            decoration: BoxDecoration(
              color: AppColor.secondary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 18, color: AppColor.secondary),
          ),
          const Hbox(6),
          AppText(
            displayValue,
            style: Ts.semiBold12(color: AppColor.textcolor),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const Hbox(2),
          AppText(
            label,
            style: Ts.regular10(color: AppColor.gray600),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  // Build Specifications Grid
  Widget _buildSpecGrid(dynamic car) {
    final String kmsValue = (car.kmsDriven.toString().trim().isEmpty || car.kmsDriven.toString().toLowerCase() == 'n/a')
        ? '-'
        : '${car.kmsDriven} kms';

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColor.gray300),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText(
            'Car Specifications',
            style: Ts.semiBold14(color: AppColor.textcolor),
          ),
          const Hbox(16),
          Row(
            children: [
              _buildSpecItem(Icons.calendar_today, car.yearOfManufacture.toString(), 'Year'),
              _buildSpecItem(Icons.person, car.owner.toString(), 'Owner'),
              _buildSpecItem(Icons.color_lens, car.color.toString(), 'Colour'),
              _buildSpecItem(Icons.directions_car, car.variant.toString(), 'Variant'),
            ],
          ),
          const Hbox(16),
          Row(
            children: [
              _buildSpecItem(Icons.speed, kmsValue, 'Kms Driven'),
              _buildSpecItem(Icons.local_gas_station, car.fuelType.toString(), 'Fuel'),
              _buildSpecItem(Icons.settings, car.transmission.toString(), 'Transmission'),
              _buildSpecItem(Icons.verified_user, car.insurance.toString(), 'Insurance'),
            ],
          ),
          const Hbox(16),
          Row(
            children: [
              _buildSpecItem(Icons.badge_outlined, car.licenseType.toString(), 'License'),
              _buildSpecItem(Icons.event_seat_outlined, car.seatType.toString(), 'Seats'),
              const Expanded(child: SizedBox.shrink()),
              const Expanded(child: SizedBox.shrink()),
            ],
          ),
        ],
      ),
    );
  }

  // Build Details Section
  Widget _buildDetailsSection(dynamic car) {
    // Helper function to create detail row only if value is not empty or N/A
    Widget? detailRow(String label, String value) {
      if (value.isEmpty || value.toLowerCase() == 'n/a') {
        return null;
      }
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            Expanded(
              child: AppText(
                label,
                style: Ts.regular12(color: AppColor.gray600),
              ),
            ),
            AppText(value, style: Ts.semiBold12(color: AppColor.textcolor)),
          ],
        ),
      );
    }

    // Create list of valid detail rows
    List<Widget> detailRows = [];

    // Add rows only if they have valid values
    final nameRow = detailRow('Name', car.name);
    if (nameRow != null) detailRows.add(nameRow);

    final modelRow = detailRow('Model', car.model);
    if (modelRow != null) detailRows.add(modelRow);

    final variantRow = detailRow('Variant', car.variant);
    if (variantRow != null) detailRows.add(variantRow);

    final yearRow = detailRow('Year', car.yearOfManufacture);
    if (yearRow != null) detailRows.add(yearRow);

    final ownerRow = detailRow('Owner', car.owner);
    if (ownerRow != null) detailRows.add(ownerRow);

    final colorRow = detailRow('Colour', car.color);
    if (colorRow != null) detailRows.add(colorRow);

    final fuelRow = detailRow('Fuel Type', car.fuelType);
    if (fuelRow != null) detailRows.add(fuelRow);

    final transmissionRow = detailRow('Transmission', car.transmission);
    if (transmissionRow != null) detailRows.add(transmissionRow);

    final insuranceRow = detailRow('Insurance', car.insurance);
    if (insuranceRow != null) detailRows.add(insuranceRow);

    final licenseRow = detailRow('License Type', car.licenseType);
    if (licenseRow != null) detailRows.add(licenseRow);

    final seatRow = detailRow('Seat Capacity', car.seatType);
    if (seatRow != null) detailRows.add(seatRow);

    final kmsRow = detailRow(
      'Kms Driven',
      car.kmsDriven.isEmpty ? '' : '${car.kmsDriven} km',
    );
    if (kmsRow != null) detailRows.add(kmsRow);

    final mileageRow = detailRow(
      'Mileage',
      car.mileage.isEmpty ? '' : '${car.mileage} km/L',
    );
    if (mileageRow != null) detailRows.add(mileageRow);

    final tankRow = detailRow('Tank Capacity', car.tankCapacity);
    if (tankRow != null) detailRows.add(tankRow);

    final priceRow = detailRow(
      'Customer Demand Price',
      car.demandPrice.isNotEmpty ? PriceFormatter.formatPriceReadable(car.demandPrice) : '',
    );
    if (priceRow != null) detailRows.add(priceRow);

    // If no details to show, return empty container
    if (detailRows.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColor.gray300),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText(
            'Car Details',
            style: Ts.semiBold14(color: AppColor.textcolor),
          ),
          const Hbox(8),
          ...detailRows,
        ],
      ),
    );
  }

  // Build Action Buttons
  Widget _buildActionButtons() {
    return Obx(() {
      if (controller.isUserCar.value || controller.isCarSold.value) {
        return const SizedBox.shrink();
      }

      return Row(
        children: [
          Expanded(
            child: SizedBox(
              height: 48,
              child: OutlinedButton.icon(
                onPressed: () => controller.callSeller(),
                icon: const Icon(Icons.call, size: 20, color: AppColor.secondary),
                label: AppText('Call Now', style: Ts.semiBold16(color: AppColor.secondary)),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColor.secondary, width: 2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ),
          const Wbox(12),
          Expanded(
            child: SizedBox(
              height: 48,
              child: ElevatedButton.icon(
                onPressed: controller.isSubmittingInquiry.value ? null : () => controller.inquireAboutCar(),
                icon: controller.isSubmittingInquiry.value
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(Icons.info_outline, size: 20, color: Colors.white),
                label: AppText(
                  controller.isSubmittingInquiry.value ? 'Sending...' : 'Inquire',
                  style: Ts.semiBold16(color: Colors.white)
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColor.secondary,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: AppColor.secondary.withOpacity(0.7),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ),
        ],
      );
    });
  }
}
