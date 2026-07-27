import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_color.dart';
import '../../../core/utils/ts.dart';
import '../../../core/utils/app_text.dart';
import '../../../core/utils/cached_image.dart';
import '../../../core/utils/price_formatter.dart';
import '../../../core/models/car.dart' as CarModel;
import '../../routes/app_routes.dart';
import 'wishlist_controller.dart';

class WishlistView extends StatefulWidget {
  const WishlistView({super.key});

  @override
  State<WishlistView> createState() => _WishlistViewState();
}

class _WishlistViewState extends State<WishlistView>
    with WidgetsBindingObserver {
  late WishlistController controller;

  @override
  void initState() {
    super.initState();
    if (!Get.isRegistered<WishlistController>()) {
      Get.put(WishlistController());
    }
    controller = Get.find<WishlistController>();

    // Add observer for app lifecycle changes
    WidgetsBinding.instance.addObserver(this);

    // Refresh wishlist when page is initialized
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.refreshWishlist();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      // Refresh wishlist when app comes back to foreground
      controller.refreshWishlist();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: true,
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        title: AppText(
          'The Wishlist',
          style: Ts.semiBold16(color: AppColor.secondary),
        ),
        centerTitle: false,
        actions: [
          // Add refresh button in app bar
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => controller.refreshWishlist(),
            tooltip: 'Refresh wishlist',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await controller.refreshWishlist();
        },
        child: Obx(() {
          if (controller.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }

          if (controller.wishlistCars.isEmpty) {
            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: SizedBox(
                height: MediaQuery.of(context).size.height * 0.7,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.favorite_border,
                        size: 64,
                        color: AppColor.gray400,
                      ),
                      const SizedBox(height: 16),
                      AppText(
                        'No items in wishlist',
                        style: Ts.regular14(color: AppColor.gray600),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => controller.refreshWishlist(),
                        child: const Text('Refresh'),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }

          return Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 20),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final double maxExtent = 200;
                return GridView.builder(
                  itemCount: controller.wishlistCars.length,
                  gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: maxExtent,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1 / 0.95,
                  ),
                  itemBuilder: (context, index) {
                    final car = controller.wishlistCars[index];
                    final carKey =
                        '${car.name}_${car.model}_${car.yearOfManufacture}_${car.demandPrice}';
                    final carId = controller.wishlistCarIdMap[carKey];
                    final isAvailable = carId != null
                        ? (controller.carAvailabilityMap[carId] ?? true)
                        : true;
                    return _WishlistCard(
                      car: car,
                      isAvailable: isAvailable,
                      onTap: () => Get.toNamed(
                        AppRoutes.carDetail,
                        arguments: {'car': car, 'carId': carId},
                      ),
                      onRemove: () => controller.removeFromWishlist(car),
                    );
                  },
                );
              },
            ),
          );
        }),
      ),
    );
  }
}

class _WishlistCard extends StatelessWidget {
  const _WishlistCard({
    required this.car,
    required this.isAvailable,
    required this.onTap,
    required this.onRemove,
  });

  final CarModel.Car car;
  final bool isAvailable;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  Widget _buildCarImage(String imagePath, double height) {
    final bool isLocalFile =
        imagePath.startsWith('/') || imagePath.startsWith('file://');
    final bool isNetworkImage =
        imagePath.startsWith('http://') || imagePath.startsWith('https://');

    if (isLocalFile && !isNetworkImage) {
      return Image.file(
        File(imagePath.replaceFirst('file://', '')),
        height: height,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Container(
          height: height,
          color: AppColor.gray100,
          child: const Icon(Icons.error, size: 24),
        ),
      );
    } else if (isNetworkImage) {
      return CachedImage(
        imageUrl: imagePath,
        height: height,
        width: double.infinity,
        fit: BoxFit.cover,
        errorWidget: Container(
          height: height,
          color: AppColor.gray100,
          child: const Icon(Icons.error, size: 24),
        ),
      );
    } else {
      return CachedImage(
        imageUrl:
            'https://tse2.mm.bing.net/th/id/OIP.3BnpuUo3Lrwh_-t2I9VjKgHaDl?rs=1&pid=ImgDetMain&o=7&rm=3',
        height: height,
        width: double.infinity,
        fit: BoxFit.cover,
        errorWidget: Container(
          height: height,
          color: AppColor.gray100,
          child: const Icon(Icons.error, size: 24),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFB7CAE6)),
            ),
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Stack(
                    children: [
                      car.imagePaths.isNotEmpty
                          ? _buildCarImage(car.imagePaths.first, 60)
                          : CachedImage(
                              imageUrl:
                                  'https://tse2.mm.bing.net/th/id/OIP.3BnpuUo3Lrwh_-t2I9VjKgHaDl?rs=1&pid=ImgDetMain&o=7&rm=3',
                              height: 60,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              errorWidget: const Icon(Icons.error),
                            ),
                      if (!isAvailable)
                        Container(
                          height: 60,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                Flexible(
                  child: AppText(
                    '${car.name} ${car.model}',
                    style: Ts.semiBold12(color: AppColor.secondary),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(height: 1),
                Flexible(
                  child: AppText(
                    '${car.yearOfManufacture} model',
                    style: Ts.regular10(color: AppColor.textcolor),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(height: 1),
                Flexible(
                  child: AppText(
                    PriceFormatter.formatPrice(car.demandPrice),
                    style: Ts.semiBold12(color: AppColor.secondary),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
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
              onTap: onRemove,
              child: const Icon(Icons.favorite, size: 18, color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}
