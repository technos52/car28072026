import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_color.dart';
import '../../../core/utils/ts.dart';
import '../../../core/utils/app_text.dart';
import '../../../core/utils/size.dart';
import '../../../core/utils/cached_image.dart';
import '../../../core/utils/price_formatter.dart';
import '../../routes/app_routes.dart';
import 'controller/owner_cars_controller.dart';

class OwnerCarsView extends GetView<OwnerCarsController> {
  const OwnerCarsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        automaticallyImplyLeading: true,
        title: Obx(() => AppText(
          '${controller.ownerName.value}\'s Cars',
          style: Ts.semiBold16(color: AppColor.secondary),
        )),
        centerTitle: false,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.ownerCars.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.directions_car_outlined,
                    size: 64,
                    color: AppColor.gray400,
                  ),
                  const Hbox(16),
                  AppText(
                    'No cars found',
                    style: Ts.semiBold16(color: AppColor.textcolor),
                  ),
                  const Hbox(8),
                  AppText(
                    'This owner hasn\'t listed any cars yet',
                    style: Ts.regular14(color: AppColor.gray600),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            await controller.loadOwnerCars();
          },
          child: CustomScrollView(
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
                              '${controller.ownerCars.length} car${controller.ownerCars.length != 1 ? 's' : ''} listed',
                              style: Ts.semiBold14(color: AppColor.textcolor),
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
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final car = controller.ownerCars[index];
                      final carKey = controller.getCarKey(car);
                      final carId = controller.carIdMap[carKey];
                      
                      String imageUrl = '';
                      if (car.imagePaths.isNotEmpty) {
                        final firstImage = car.imagePaths.first;
                        if (firstImage.startsWith('[') && firstImage.endsWith(']')) {
                          try {
                            final List<dynamic> parsed = jsonDecode(firstImage);
                            imageUrl = parsed.isNotEmpty ? parsed.first.toString() : '';
                          } catch (e) {
                            imageUrl = firstImage;
                          }
                        } else {
                          imageUrl = firstImage;
                        }
                      }
                      
                      final isAvailable = carId != null ? (controller.carAvailabilityMap[carId] ?? true) : true;
                      return GestureDetector(
                        onTap: () {
                          Get.toNamed(
                            AppRoutes.carDetail,
                            arguments: {
                              'car': car,
                              'carId': carId,
                            },
                          );
                        },
                        child: _CarCard(
                          imageUrl: imageUrl,
                          title: car.name.isNotEmpty ? car.name : 'N/A',
                          variant: car.variant.isNotEmpty ? car.variant : (car.model.isNotEmpty ? car.model : ''),
                          spec1: car.owner.isNotEmpty ? car.owner : 'N/A',
                          price: PriceFormatter.formatPrice(car.demandPrice),
                          isAvailable: isAvailable,
                        ),
                      );
                    },
                    childCount: controller.ownerCars.length,
                  ),
                ),
              ),
              const SliverPadding(
                padding: EdgeInsets.only(bottom: 24),
              ),
            ],
          ),
        );
      }),
    );
  }
}

class _CarCard extends StatelessWidget {
  const _CarCard({
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
                        ? (imageUrl.startsWith('http://') || imageUrl.startsWith('https://'))
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
                                errorBuilder: (context, error, stackTrace) => Container(
                                  height: 70,
                                  width: double.infinity,
                                  color: AppColor.gray200,
                                  child: const Icon(Icons.error, size: 24),
                                ),
                              )
                        : Container(
                            height: 70,
                            width: double.infinity,
                            color: AppColor.gray200,
                            child: const Icon(Icons.image_not_supported, size: 24),
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
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
            child: Icon(Icons.favorite_border, size: 18, color: AppColor.gray400),
          ),
        ),
      ],
    );
  }
}

