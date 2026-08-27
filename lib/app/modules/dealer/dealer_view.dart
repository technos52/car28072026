import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/app_color.dart';
import '../../../core/utils/ts.dart';
import '../../../core/utils/app_text.dart';
import '../../../core/utils/cached_image.dart';
import '../../../core/services/remote_service.dart';
import '../../routes/app_routes.dart';
import '../../../core/utils/price_formatter.dart';
import '../home/home_controller.dart';

bool _isLocalFile(String url) {
  return url.startsWith('/') ||
      url.startsWith('file://') ||
      (!url.startsWith('http://') && !url.startsWith('https://'));
}

class DealerView extends StatefulWidget {
  const DealerView({super.key});

  @override
  State<DealerView> createState() => _DealerViewState();
}

class _DealerViewState extends State<DealerView> {
  final RxString dealerName = ''.obs;
  final RxString dealerAvatarUrl = ''.obs;
  final RxString dealerShopImageUrl = ''.obs;
  final RxList<dynamic> dealerCars = <dynamic>[].obs;
  final RxBool isLoading = true.obs;

  // Shop details
  final RxString shopName = ''.obs;
  final RxString ownerName = ''.obs;
  final RxString phone = ''.obs;
  final RxString email = ''.obs;
  final RxString address = ''.obs;
  final RxString city = ''.obs;
  final RxString state = ''.obs;
  final RxString pincode = ''.obs;

  String? dealerId;

  @override
  void initState() {
    super.initState();
    _loadDealerData();
  }

  Future<void> _loadDealerData() async {
    try {
      final args = Get.arguments;
      if (args != null && args['dealerId'] != null) {
        dealerId = args['dealerId'];
        print('Loading dealer data for ID: $dealerId');

        // Get services
        final remoteService = Get.find<RemoteService>();

        // Load dealer profile data
        final dealerData = await remoteService.getUser(dealerId!);
        if (dealerData != null) {
          dealerName.value = dealerData['name'] ?? 'Dealer';
          dealerAvatarUrl.value = dealerData['avatarUrl']?.toString() ?? '';
          print(
            'Dealer data loaded: ${dealerData['name']}, Avatar: ${dealerData['avatarUrl']}',
          );
        }

        // Load dealer shop data
        final shopData = await remoteService.getUserShop(dealerId!);
        print('Raw shop data from Firebase: $shopData');
        if (shopData != null) {
          print('Shop data keys: ${shopData.keys.toList()}');
          print('logoUrl value: ${shopData['logoUrl']}');

          // Use logoUrl specifically for shop banner image
          dealerShopImageUrl.value = shopData['logoUrl']?.toString() ?? '';

          // Load shop details
          shopName.value = shopData['shopName']?.toString() ?? '';
          ownerName.value = shopData['ownerName']?.toString() ?? '';
          phone.value = shopData['phone']?.toString() ?? '';
          email.value = shopData['email']?.toString() ?? '';
          address.value = shopData['address']?.toString() ?? '';
          city.value = shopData['city']?.toString() ?? '';
          state.value = shopData['state']?.toString() ?? '';
          pincode.value = shopData['pincode']?.toString() ?? '';

          print('Shop data loaded: $shopData');
          print('Final shop image URL: ${dealerShopImageUrl.value}');
        } else {
          print('No shop data found for dealer: $dealerId');
        }

        // Load dealer cars
        final cars = await remoteService.getUserCars(dealerId!);
        dealerCars.value = cars;
        print('Loaded ${cars.length} cars for dealer');
      }
    } catch (e) {
      print('Error loading dealer data: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Widget _buildDefaultBanner() {
    return Container(
      width: double.infinity,
      height: 200,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColor.secondary,
            AppColor.secondary.withValues(alpha: 0.8),
          ],
        ),
      ),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.store, size: 60, color: Colors.white),
            SizedBox(height: 8),
            Text(
              'Car Dealership',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDefaultAvatar() {
    return Container(
      width: 118.8,
      height: 118.8,
      color: AppColor.primary,
      child: const Icon(Icons.person, size: 60, color: Colors.white),
    );
  }

  Widget _buildCarCard(dynamic car) {
    final homeController = Get.isRegistered<HomeController>()
        ? Get.find<HomeController>()
        : Get.put(HomeController());

    String? carId;
    if (car is Map<String, dynamic>) {
      carId = car['id']?.toString() ?? car['carId']?.toString();
    } else if (car != null) {
      try {
        carId = car.id;
      } catch (_) {}
    }

    return GestureDetector(
      onTap: () {
        // Navigate to car detail page
        Get.toNamed(
          AppRoutes.carDetail,
          arguments: {
            'car': car,
            'carId': carId ?? '',
            'dealerId': dealerId,
          },
        );
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
                      child: _buildCarImage(car),
                    ),
                    // Wishlist Button
                    Positioned(
                      top: 6,
                      right: 6,
                      child: GestureDetector(
                        onTap: () async {
                          if (carId != null && carId.isNotEmpty) {
                            await homeController.toggleWishlistById(carId);
                          } else {
                            Get.snackbar(
                              'Wishlist',
                              'Car details unavailable for wishlist',
                              snackPosition: SnackPosition.BOTTOM,
                            );
                          }
                        },
                        child: Obx(() {
                          final isWishlisted =
                              carId != null &&
                              homeController.wishlistCarIds.contains(carId);
                          return Container(
                            padding: const EdgeInsets.all(5),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.9),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              isWishlisted
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              color: isWishlisted ? Colors.red : Colors.grey[700],
                              size: 15,
                            ),
                          );
                        }),
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
                      _getCarName(car),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 10, // Reduced from 11
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (_getCarYear(car).isNotEmpty)
                      Text(
                        _getCarYear(car),
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 8,
                        ), // Reduced from 9
                      ),
                    if (_getCarFuel(car).isNotEmpty)
                      Text(
                        _getCarFuel(car),
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 8,
                        ), // Reduced from 9
                      ),
                    if (_getCarOwner(car).isNotEmpty)
                      Text(
                        'Owner: ${_getCarOwner(car)}',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 8,
                        ), // Reduced from 9
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    const Spacer(), // Changed from Expanded(child: SizedBox())
                    if (_getCarPrice(car).isNotEmpty)
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              PriceFormatter.formatPriceReadable(_getCarPrice(car)),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 10, // Reduced from 11
                                color: Colors.blue,
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

  Widget _buildCarImage(dynamic car) {
    // Handle different car data structures
    String? imageUrl;

    if (car is Map<String, dynamic>) {
      imageUrl = car['imageUrl']?.toString();
    } else {
      // Handle car object with imagePaths property
      try {
        final imagePaths = car.imagePaths;
        if (imagePaths != null && imagePaths.isNotEmpty) {
          imageUrl = imagePaths.first;
        }
      } catch (e) {
        // Fallback for different object structures
        imageUrl = null;
      }
    }

    if (imageUrl != null && imageUrl.isNotEmpty) {
      return CachedImage(
        imageUrl: imageUrl,
        width: double.infinity,
        height: double.infinity,
        fit: BoxFit.cover,
        errorWidget: _buildCarPlaceholder(),
      );
    }

    return _buildCarPlaceholder();
  }

  Widget _buildCarPlaceholder() {
    return const Center(
      child: Icon(Icons.car_rental, size: 32, color: Colors.grey),
    );
  }

  String _getCarName(dynamic car) {
    if (car is Map<String, dynamic>) {
      final name = car['name']?.toString() ?? '';
      final model = car['model']?.toString() ?? '';
      if (name.isNotEmpty && model.isNotEmpty) {
        return '$name $model';
      }
      return name.isNotEmpty ? name : (model.isNotEmpty ? model : 'Car Name');
    } else {
      try {
        return '${car.name} ${car.model}';
      } catch (e) {
        return 'Car Name';
      }
    }
  }

  String _getCarYear(dynamic car) {
    if (car is Map<String, dynamic>) {
      return car['year']?.toString() ??
          car['yearOfManufacture']?.toString() ??
          '';
    } else {
      try {
        return car.yearOfManufacture?.toString() ?? '';
      } catch (e) {
        return '';
      }
    }
  }

  String _getCarFuel(dynamic car) {
    if (car is Map<String, dynamic>) {
      return car['fuel']?.toString() ?? car['fuelType']?.toString() ?? '';
    } else {
      try {
        return car.fuelType?.toString() ?? '';
      } catch (e) {
        return '';
      }
    }
  }

  String _getCarOwner(dynamic car) {
    if (car is Map<String, dynamic>) {
      return car['owner']?.toString() ?? '';
    } else {
      try {
        return car.owner?.toString() ?? '';
      } catch (e) {
        return '';
      }
    }
  }

  String _getCarPrice(dynamic car) {
    if (car is Map<String, dynamic>) {
      return car['price']?.toString() ?? car['demandPrice']?.toString() ?? '';
    } else {
      try {
        return car.demandPrice?.toString() ?? '';
      } catch (e) {
        return '';
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        automaticallyImplyLeading: true,
        title: Obx(
          () => AppText(
            dealerName.value.isNotEmpty ? dealerName.value : 'Dealer',
            style: Ts.semiBold16(color: AppColor.secondary),
          ),
        ),
        centerTitle: false,
      ),
      body: Obx(() {
        if (isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Banner Section with Shop Image and Dealer Profile
              Container(
                height: 200,
                width: double.infinity,
                child: Stack(
                  clipBehavior: Clip.none, // Allow overflow for profile image
                  children: [
                    // Shop Banner Image Container
                    Container(
                      height: 200,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: AppColor.gray100,
                      ),
                      child: Stack(
                        children: [
                          // Shop Banner Image
                          ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Obx(() {
                              print(
                                'Building banner image. URL: ${dealerShopImageUrl.value}',
                              );

                              // Only use shop image for banner, never profile image
                              if (dealerShopImageUrl.value.isNotEmpty) {
                                if (_isLocalFile(dealerShopImageUrl.value)) {
                                  return Image.file(
                                    File(dealerShopImageUrl.value),
                                    width: double.infinity,
                                    height: 200,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      print('Error loading local file: $error');
                                      return _buildDefaultBanner();
                                    },
                                  );
                                } else {
                                  return CachedImage(
                                    imageUrl: dealerShopImageUrl.value,
                                    width: double.infinity,
                                    height: 200,
                                    fit: BoxFit.cover,
                                    errorWidget: _buildDefaultBanner(),
                                  );
                                }
                              } else {
                                print(
                                  'No shop image URL, showing default banner',
                                );
                                return _buildDefaultBanner();
                              }
                            }),
                          ),
                          // Gradient Overlay
                          Container(
                            width: double.infinity,
                            height: 200,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.transparent,
                                  Colors.black.withValues(alpha: 0.7),
                                ],
                              ),
                            ),
                          ),
                          // Dealer Name and Info
                          Positioned(
                            bottom: 16,
                            left: 16,
                            right: 160, // Leave space for profile image
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Obx(
                                  () => AppText(
                                    dealerName.value.isNotEmpty
                                        ? dealerName.value
                                        : 'Dealer Name',
                                    style: Ts.semiBold20(color: Colors.white),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                AppText(
                                  'Authorized Car Dealer',
                                  style: Ts.regular14(color: Colors.white70),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Large Circular Dealer Profile Image (overlapping banner)
                    Positioned(
                      bottom: -60, // Half extends below banner (120/2 = 60)
                      right: 20,
                      child: Container(
                        width: 118.8, // Reduced by 0.5% (119.4 * 0.995)
                        height: 118.8, // Reduced by 0.5% (119.4 * 0.995)
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 4),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.3),
                              blurRadius: 12,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: ClipOval(
                          child: Obx(() {
                            print(
                              'Building profile image. URL: ${dealerAvatarUrl.value}',
                            );
                            if (dealerAvatarUrl.value.isNotEmpty) {
                              if (_isLocalFile(dealerAvatarUrl.value)) {
                                return Image.file(
                                  File(dealerAvatarUrl.value),
                                  width: 118.8,
                                  height: 118.8,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    print(
                                      'Error loading profile image: $error',
                                    );
                                    return _buildDefaultAvatar();
                                  },
                                );
                              } else {
                                return CachedImage(
                                  imageUrl: dealerAvatarUrl.value,
                                  width: 118.8,
                                  height: 118.8,
                                  fit: BoxFit.cover,
                                  errorWidget: _buildDefaultAvatar(),
                                );
                              }
                            } else {
                              print('No avatar URL, showing default avatar');
                              return _buildDefaultAvatar();
                            }
                          }),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 20,
              ), // Reduced spacing between banner and vendor info
              // Vendor Information Section
              _buildVendorInfoSection(),
              const SizedBox(height: 24),

              // Cars Section
              AppText(
                'Cars Listed',
                style: Ts.semiBold18(color: AppColor.secondary),
              ),
              const SizedBox(height: 16),

              Obx(() {
                if (dealerCars.isEmpty) {
                  return Container(
                    padding: const EdgeInsets.all(40),
                    child: Column(
                      children: [
                        Icon(
                          Icons.directions_car_outlined,
                          size: 60,
                          color: AppColor.gray400,
                        ),
                        const SizedBox(height: 16),
                        AppText(
                          'No cars listed yet',
                          style: Ts.regular16(color: AppColor.gray600),
                        ),
                      ],
                    ),
                  );
                }

                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.78, // Adjusted to fix bottom overflow on cards
                    crossAxisSpacing: 10, // Match home page spacing
                    mainAxisSpacing: 10, // Match home page spacing
                  ),
                  itemCount: dealerCars.length,
                  itemBuilder: (context, index) {
                    final car = dealerCars[index];
                    return _buildCarCard(car);
                  },
                );
              }),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildVendorInfoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Shop Name - Large and prominent in blue
        Obx(
          () => AppText(
            shopName.value.isNotEmpty
                ? shopName.value.toUpperCase()
                : 'SHOP NAME',
            style: Ts.semiBold24(color: AppColor.secondary),
          ),
        ),
        const SizedBox(height: 8),

        // Vendor Name - Smaller, gray text
        Obx(
          () => AppText(
            ownerName.value.isNotEmpty ? ownerName.value : dealerName.value,
            style: Ts.regular16(color: AppColor.gray600),
          ),
        ),
        const SizedBox(height: 16),

        // Contact Details in bordered container
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: AppColor.gray400, width: 2),
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Phone Number
              Obx(() {
                if (phone.value.isEmpty) return const SizedBox.shrink();
                return _buildCompactContactItem(
                  icon: Icons.phone,
                  value: phone.value,
                  onTap: () => _launchPhone(phone.value),
                );
              }),

              // Email
              Obx(() {
                if (email.value.isEmpty) return const SizedBox.shrink();
                return _buildCompactContactItem(
                  icon: Icons.email,
                  value: email.value,
                  onTap: () => _launchEmail(email.value),
                  showDivider: phone.value.isNotEmpty,
                );
              }),

              // Address
              Obx(() {
                final fullAddress = _buildFullAddress();
                if (fullAddress.isEmpty) return const SizedBox.shrink();
                return _buildCompactContactItem(
                  icon: Icons.location_on,
                  value: fullAddress,
                  onTap: () => _launchMaps(fullAddress),
                  showDivider: phone.value.isNotEmpty || email.value.isNotEmpty,
                );
              }),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCompactContactItem({
    required IconData icon,
    required String value,
    required VoidCallback onTap,
    bool showDivider = false,
  }) {
    return Column(
      children: [
        if (showDivider) ...[
          const SizedBox(height: 12),
          Divider(color: AppColor.gray300, height: 1),
          const SizedBox(height: 12),
        ],
        GestureDetector(
          onTap: onTap,
          child: Row(
            children: [
              Icon(icon, color: AppColor.secondary, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: AppText(
                  value,
                  style: Ts.regular14(color: AppColor.secondary),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _buildFullAddress() {
    List<String> addressParts = [];

    if (address.value.isNotEmpty) addressParts.add(address.value);
    if (city.value.isNotEmpty) addressParts.add(city.value);
    if (state.value.isNotEmpty) addressParts.add(state.value);
    if (pincode.value.isNotEmpty) addressParts.add(pincode.value);

    return addressParts.join(', ');
  }

  Future<void> _launchPhone(String phoneNumber) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    } else {
      Get.snackbar(
        'Error',
        'Could not launch phone app',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> _launchEmail(String emailAddress) async {
    final Uri emailUri = Uri(scheme: 'mailto', path: emailAddress);
    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    } else {
      Get.snackbar(
        'Error',
        'Could not launch email app',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> _launchMaps(String address) async {
    final String encodedAddress = Uri.encodeComponent(address);
    final Uri mapsUri = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=$encodedAddress',
    );

    if (await canLaunchUrl(mapsUri)) {
      await launchUrl(mapsUri, mode: LaunchMode.externalApplication);
    } else {
      Get.snackbar(
        'Error',
        'Could not launch maps',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
}
