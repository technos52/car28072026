import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'home_controller.dart';
import '../../../core/utils/cached_image.dart';
import '../admin_messages/controller/admin_messages_controller.dart';
import '../root/controller/root_controller.dart';
import '../../routes/app_routes.dart';
import '../search/search_view.dart';
import '../search/controller/search_controller.dart' as search_ctrl;
import '../../../core/utils/price_formatter.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(HomeController());
    final searchCtrl = Get.put(search_ctrl.SearchController());

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: Column(
          children: [
            // Header Section
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ), // Reduced vertical padding
              color: Colors.white,
              child: Column(
                children: [
                  // Top Row with greeting and notification
                  Row(
                    children: [
                      // Profile Avatar
                      Obx(
                        () => CircleAvatar(
                          radius: 22, // Slightly smaller
                          backgroundColor: Colors.grey[300],
                          backgroundImage:
                              controller.userAvatarUrl.value.isNotEmpty
                              ? NetworkImage(controller.userAvatarUrl.value)
                              : null,
                          child: controller.userAvatarUrl.value.isEmpty
                              ? const Icon(
                                  Icons.person,
                                  color: Colors.grey,
                                  size: 20,
                                )
                              : null,
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Greeting
                      Expanded(
                        child: Obx(
                          () => Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${controller.getGreeting()} 👋',
                                style: const TextStyle(
                                  fontSize: 14, // Slightly smaller
                                  color: Colors.grey,
                                ),
                              ),
                              Text(
                                controller.userName.value.isNotEmpty
                                    ? controller.userName.value
                                    : controller.shopName.value.isNotEmpty
                                    ? controller.shopName.value
                                    : 'User',
                                style: const TextStyle(
                                  fontSize: 16, // Slightly smaller
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      // Notification Icon with unread count
                      Builder(
                        builder: (context) {
                          return Obx(() {
                            int unread = 0;
                            try {
                              if (Get.isRegistered<AdminMessagesController>()) {
                                final adminController =
                                    Get.find<AdminMessagesController>();
                                unread = adminController.unreadCount.value;
                              }
                            } catch (e) {
                              // Controller not initialized yet, keep unread as 0
                            }

                            return IconButton(
                              onPressed: () {
                                // Navigate to notifications/messages
                                try {
                                  if (Get.isRegistered<RootController>()) {
                                    final rootController =
                                        Get.find<RootController>();
                                    rootController.navigateToNotifications();
                                  }
                                } catch (e) {
                                  // Handle navigation error gracefully
                                }
                              },
                              icon: Stack(
                                clipBehavior: Clip.none,
                                children: [
                                  const Icon(
                                    Icons.notifications_outlined,
                                    size: 24,
                                  ),
                                  if (unread > 0)
                                    Positioned(
                                      right: -2,
                                      top: -2,
                                      child: Container(
                                        padding: const EdgeInsets.all(2),
                                        decoration: BoxDecoration(
                                          color: Colors.red,
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: Colors.white,
                                            width: 1.5,
                                          ),
                                        ),
                                        constraints: const BoxConstraints(
                                          minWidth: 16,
                                          minHeight: 16,
                                        ),
                                        child: Text(
                                          unread > 99 ? '99+' : '$unread',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 9,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            );
                          });
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16), // Adjusted spacing
                  // Search Bar with Suggestions
                  Column(
                    children: [
                      Container(
                        height: 44, // Fixed height to prevent overflow
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey[300]!),
                        ),
                        child: Obx(
                          () => TextField(
                            controller: controller.searchController,
                            onChanged: (val) {
                              controller.onSearchChanged(val);
                              searchCtrl.query.value = val;
                              searchCtrl.applyFilters();
                            },
                            onSubmitted: (val) {
                              controller.carSuggestions.clear();
                              controller.filteredBrandSuggestions.clear();
                              controller.filteredDealerSuggestions.clear();
                            },
                            decoration: InputDecoration(
                              hintText: 'Search cars, brands, dealers...',
                              hintStyle: TextStyle(
                                color: Colors.grey[500],
                                fontSize: 14,
                              ),
                              prefixIcon: Icon(
                                Icons.search,
                                color: Colors.grey[500],
                                size: 20,
                              ),
                              suffixIcon: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (controller.searchQuery.value.isNotEmpty)
                                    IconButton(
                                      icon: Icon(
                                        Icons.clear,
                                        color: Colors.grey[500],
                                        size: 18,
                                      ),
                                      onPressed: () {
                                        controller.clearSearch();
                                        if (Get.isRegistered<
                                          search_ctrl.SearchController
                                        >()) {
                                          final searchCtrl =
                                              Get.find<
                                                search_ctrl.SearchController
                                              >();
                                          searchCtrl.query.value = '';
                                          searchCtrl.applyFilters();
                                        }
                                      },
                                    ),
                                  IconButton(
                                    icon: Icon(
                                      Icons.tune,
                                      color: Colors.grey[500],
                                      size: 20,
                                    ),
                                    onPressed: () {
                                      final searchCtrl =
                                          Get.isRegistered<
                                            search_ctrl.SearchController
                                          >()
                                          ? Get.find<
                                              search_ctrl.SearchController
                                            >()
                                          : Get.put(
                                              search_ctrl.SearchController(),
                                            );

                                      showModalBottomSheet(
                                        context: context,
                                        isScrollControlled: true,
                                        backgroundColor: Colors.transparent,
                                        builder: (context) =>
                                            FilterSheetContent(
                                              controller: searchCtrl,
                                            ),
                                      ).then((_) {
                                        controller.refreshCars();
                                      });
                                    },
                                  ),
                                  const SizedBox(width: 4),
                                ],
                              ),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                            ),
                          ),
                        ),
                      ),
                      // Search Suggestions Dropdown
                      Builder(
                        builder: (context) {
                          return Obx(() {
                            final hasCarSuggestions =
                                controller.carSuggestions.isNotEmpty;
                            final hasBrandSuggestions =
                                controller.filteredBrandSuggestions.isNotEmpty;
                            final hasDealerSuggestions =
                                controller.filteredDealerSuggestions.isNotEmpty;

                            if (!hasCarSuggestions && !hasBrandSuggestions && !hasDealerSuggestions) {
                              return const SizedBox.shrink();
                            }

                            return Container(
                              margin: const EdgeInsets.only(top: 4),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.grey[300]!),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withValues(alpha: 0.1),
                                    spreadRadius: 1,
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              constraints: const BoxConstraints(maxHeight: 200),
                              child: ListView(
                                shrinkWrap: true,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 4,
                                ),
                                children: [
                                  // Car Suggestions
                                  if (hasCarSuggestions) ...[
                                    if (hasBrandSuggestions)
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: 8,
                                        ),
                                        child: Text(
                                          'Cars',
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                      ),
                                    ...controller.carSuggestions.map((
                                      suggestion,
                                    ) {
                                      final car = suggestion['car'] as dynamic;
                                      final displayText =
                                          suggestion['displayText'] as String;

                                      return ListTile(
                                        dense: true,
                                        leading: const Icon(
                                          Icons.car_rental,
                                          size: 20,
                                          color: Colors.blue,
                                        ),
                                        title: Text(
                                          displayText,
                                          style: const TextStyle(fontSize: 14),
                                        ),
                                        subtitle: car.demandPrice.isNotEmpty
                                            ? Text(
                                                PriceFormatter.formatPriceReadable(car.demandPrice),
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.grey[600],
                                                ),
                                              )
                                            : null,
                                        onTap: () =>
                                            controller.selectCarFromSuggestions(
                                              suggestion,
                                            ),
                                      );
                                    }).toList(),
                                  ],
                                  // Brand Suggestions
                                  if (hasBrandSuggestions) ...[
                                    if (hasCarSuggestions)
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: 8,
                                        ),
                                        child: Text(
                                          'Brands',
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                      ),
                                    ...controller.filteredBrandSuggestions.map((
                                      brand,
                                    ) {
                                      return ListTile(
                                        dense: true,
                                        leading: const Icon(
                                          Icons.business,
                                          size: 20,
                                          color: Colors.orange,
                                        ),
                                        title: Text(
                                          brand,
                                          style: const TextStyle(fontSize: 14),
                                        ),
                                        onTap: () => controller
                                            .selectBrandFromSearch(brand),
                                      );
                                    }).toList(),
                                  ],
                                  // Dealer Suggestions
                                  if (hasDealerSuggestions) ...[
                                    if (hasCarSuggestions || hasBrandSuggestions)
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: 8,
                                        ),
                                        child: Text(
                                          'Dealers',
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                      ),
                                    ...controller.filteredDealerSuggestions.map((
                                      dealer,
                                    ) {
                                      return ListTile(
                                        dense: true,
                                        leading: const Icon(
                                          Icons.storefront,
                                          size: 20,
                                          color: Colors.green,
                                        ),
                                        title: Text(
                                          dealer,
                                          style: const TextStyle(fontSize: 14),
                                        ),
                                        onTap: () => controller
                                            .selectDealerFromSearch(dealer),
                                      );
                                    }).toList(),
                                  ],
                                ],
                              ),
                            );
                          });
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Main Content
            Expanded(
              child: RefreshIndicator(
                onRefresh: controller.refreshCars,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    children: [
                    // Carousel Section - Only show if images exist
                    Obx(
                      () => controller.carouselImages.isNotEmpty
                          ? Container(
                              height: 200, // Increased height from 140 to 200
                              width: double.infinity, // Full width
                              decoration: const BoxDecoration(
                                // Removed borderRadius for sharp corners
                                gradient: LinearGradient(
                                  colors: [
                                    Color(0xFF1E3A8A),
                                    Color(0xFF3B82F6),
                                  ],
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                ),
                              ),
                              child: PageView.builder(
                                controller: controller.carouselController,
                                onPageChanged: (index) {
                                  if (controller.carouselImages.isNotEmpty) {
                                    controller.currentCarouselImage.value =
                                        index % controller.carouselImages.length;
                                  }
                                },
                                itemBuilder: (context, index) {
                                  if (controller.carouselImages.isEmpty) {
                                    return const SizedBox.shrink();
                                  }
                                  final realIndex =
                                      index % controller.carouselImages.length;
                                   return CachedImage(
                                     imageUrl:
                                         controller.carouselImages[realIndex],
                                     width: double.infinity,
                                     height: 200,
                                     fit: BoxFit.cover,
                                   );
                                },
                              ),
                            )
                          : const SizedBox.shrink(), // Hide carousel completely
                    ),

                    // Add spacing only if carousel is visible
                    Obx(
                      () => controller.carouselImages.isNotEmpty
                          ? const SizedBox(height: 16)
                          : const SizedBox.shrink(),
                    ),
                    // Cars Grid with Firebase Data
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Obx(() => _buildCarsGrid(controller)),
                    ),
                  ],
                ),
              ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCarsGrid(HomeController controller) {
    // Check if SearchController has active filters/query
    final searchCtrl = Get.isRegistered<search_ctrl.SearchController>()
        ? Get.find<search_ctrl.SearchController>()
        : null;

    bool hasActiveSearch = false;
    if (searchCtrl != null) {
      hasActiveSearch =
          searchCtrl.hasActiveFilters || searchCtrl.query.value.isNotEmpty;
    }

    final displayCars = <dynamic>[];

    if (hasActiveSearch && searchCtrl != null) {
      // Use filtered results from SearchController
      for (var car in searchCtrl.searchResults) {
        bool isUserCar = controller.userCars.any(
          (c) => controller.getCarKey(c) == searchCtrl.getCarKey(car),
        );
        displayCars.add({'car': car, 'isUserCar': isUserCar});
      }

      if (displayCars.isEmpty) {
        return const Center(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 40.0),
            child: Text(
              'No cars found matching your filters.',
              style: TextStyle(color: Colors.grey),
            ),
          ),
        );
      }
    } else {
      // Add user cars first (they're now sorted newest first in controller)
      for (var car in controller.userCars) {
        displayCars.add({'car': car, 'isUserCar': true});
      }

      // Add other cars (show all available cars)
      for (var car in controller.allOtherCars) {
        displayCars.add({'car': car, 'isUserCar': false});
      }
    }

    // If no Firebase data, show empty state
    if (displayCars.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 40.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.car_rental_outlined,
                size: 64,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 16),
              const Text(
                'No cars available yet.',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Check back later or try adding a car!',
                style: TextStyle(color: Colors.grey, fontSize: 14),
              ),
            ],
          ),
        ),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.78, // Decreased to fix bottom overflow
        crossAxisSpacing: 10, // Reduced spacing
        mainAxisSpacing: 10, // Reduced spacing
      ),
      itemCount: displayCars.length,
      itemBuilder: (context, index) {
        if (index >= displayCars.length) {
          return const SizedBox.shrink(); // Safety check
        }
        final item = displayCars[index];
        final car = item['car'];
        final isUserCar = item['isUserCar'] as bool;

        return _buildCarCard(car, controller, isUserCar);
      },
    );
  }

  Widget _buildCarCard(dynamic car, HomeController controller, bool isUserCar) {
    return GestureDetector(
      onTap: () async {
        // Navigate to car detail page
        final carKey = controller.getCarKey(car);
        final carId = controller.carIdMap[carKey];
        if (carId != null) {
          await Get.toNamed(
            AppRoutes.carDetail,
            arguments: {'car': car, 'carId': carId},
          );
          controller.refreshCars();
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12), // Slightly smaller radius
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.1),
              spreadRadius: 1,
              blurRadius: 6, // Reduced blur
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
                    // Car Image from Firebase
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
                    // Wishlist Button
                    Positioned(
                      top: 6,
                      right: 6,
                      child: GestureDetector(
                        onTap: () => controller.toggleWishlist(car),
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.9),
                            shape: BoxShape.circle,
                          ),
                          child: Obx(
                            () => Icon(
                              controller.isInWishlist(car)
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              color: controller.isInWishlist(car)
                                  ? Colors.red
                                  : Colors.grey,
                              size: 14,
                            ),
                          ),
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
                padding: const EdgeInsets.all(6), // Reduced from 8
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${car.name} ${car.model}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 10, // Reduced from 11
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (car.yearOfManufacture.isNotEmpty)
                      Text(
                        car.yearOfManufacture,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 8,
                        ), // Reduced from 9
                      ),
                    if (car.fuelType.isNotEmpty)
                      Text(
                        car.fuelType,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 8,
                        ), // Reduced from 9
                      ),
                    if (car.owner.isNotEmpty)
                      Text(
                        'Owner: ${car.owner}',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 8,
                        ), // Reduced from 9
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    const Spacer(), // Changed from Expanded(child: SizedBox())
                    if (car.demandPrice.isNotEmpty)
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              PriceFormatter.formatPriceReadable(car.demandPrice),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.blue,
                                fontSize: 10, // Reduced from 11
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
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
