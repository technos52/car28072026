import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'home_controller.dart';
import '../../../core/utils/cached_image.dart';
import '../../routes/app_routes.dart';
import '../../../core/utils/price_formatter.dart';

class MyCarsView extends GetView<HomeController> {
  const MyCarsView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.isRegistered<HomeController>()
        ? Get.find<HomeController>()
        : Get.put(HomeController());

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        title: const Text(
          'My Cars',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
      ),
      body: Obx(() {
        if (controller.userCars.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.directions_car_filled_outlined,
                  size: 64,
                  color: Colors.grey[300],
                ),
                const SizedBox(height: 16),
                Text(
                  'You haven\'t uploaded any cars yet.',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () {
                    // Navigate to Add Car tab
                    if (Get.isRegistered<dynamic>()) {
                      // We can access RootController if it's there
                      try {
                        Get.find<dynamic>().setIndex(2);
                      } catch (e) {
                        // ignore
                      }
                    }
                  },
                  child: const Text('Add your first car'),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: controller.refreshCars,
          child: GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.9,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: controller.userCars.length,
            itemBuilder: (context, index) {
              final car = controller.userCars[index];
              return _buildCarCard(car, controller);
            },
          ),
        );
      }),
    );
  }

  Widget _buildCarCard(dynamic car, HomeController controller) {
    return GestureDetector(
      onTap: () {
        final carKey = controller.getCarKey(car);
        final carId = controller.carIdMap[carKey];
        if (carId != null) {
          Get.toNamed(
            AppRoutes.carDetail,
            arguments: {'car': car, 'carId': carId},
          );
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.1),
              spreadRadius: 1,
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Car Image
            Expanded(
              flex: 3,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(12),
                  ),
                  color: Colors.grey[100],
                ),
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(12),
                      ),
                      child: car.imagePaths.isNotEmpty
                          ? CachedImage(
                              imageUrl: car.imagePaths.first,
                              width: double.infinity,
                              height: double.infinity,
                              fit: BoxFit.cover,
                              errorWidget: const Center(
                                child: Icon(
                                  Icons.car_rental,
                                  size: 32,
                                  color: Colors.grey,
                                ),
                              ),
                            )
                          : const Center(
                              child: Icon(
                                Icons.car_rental,
                                size: 32,
                                color: Colors.grey,
                              ),
                            ),
                    ),
                  ],
                ),
              ),
            ),
            // Car Details
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${car.name} ${car.model}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${car.yearOfManufacture} • ${car.fuelType}',
                      style: TextStyle(color: Colors.grey[600], fontSize: 10),
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        Text(
                          PriceFormatter.formatPriceReadable(car.demandPrice),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
