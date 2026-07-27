import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../constants/app_color.dart';
import '../utils/cached_image.dart';
import '../utils/ts.dart';
import '../utils/app_text.dart';
import '../utils/price_formatter.dart';

class CarCard extends StatelessWidget {
  final dynamic car;
  final VoidCallback? onTap;
  final bool showWishlist;
  final VoidCallback? onWishlistTap;
  final bool isWishlisted;

  const CarCard({
    super.key,
    required this.car,
    this.onTap,
    this.showWishlist = false,
    this.onWishlistTap,
    this.isWishlisted = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
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
                  color: AppColor.gray100,
                ),
                child: Stack(
                  children: [
                    // Car Image
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(12),
                      ),
                      child: _buildCarImage(),
                    ),
                    // Wishlist Button
                    if (showWishlist)
                      Positioned(
                        top: 6,
                        right: 6,
                        child: GestureDetector(
                          onTap: onWishlistTap,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.9),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              isWishlisted
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              color: isWishlisted ? Colors.red : Colors.grey,
                              size: 14,
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
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AppText(
                      _getCarName(),
                      style: Ts.semiBold12(color: AppColor.secondary),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (_getCarYear().isNotEmpty) ...[
                      const SizedBox(height: 2),
                      AppText(
                        _getCarYear(),
                        style: Ts.regular10(color: AppColor.gray600),
                      ),
                    ],
                    if (_getCarFuel().isNotEmpty) ...[
                      const SizedBox(height: 2),
                      AppText(
                        _getCarFuel(),
                        style: Ts.regular10(color: AppColor.gray600),
                      ),
                    ],
                    const Spacer(),
                    if (_getCarPrice().isNotEmpty)
                      Row(
                        children: [
                          Expanded(
                            child: AppText(
                              PriceFormatter.formatPriceReadable(_getCarPrice()),
                              style: Ts.semiBold12(color: AppColor.primary),
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

  Widget _buildCarImage() {
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
        errorWidget: _buildPlaceholder(),
      );
    }

    return _buildPlaceholder();
  }

  Widget _buildPlaceholder() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: AppColor.gray100,
      child: const Center(
        child: Icon(Icons.directions_car, size: 32, color: AppColor.gray400),
      ),
    );
  }

  String _getCarName() {
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

  String _getCarYear() {
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

  String _getCarFuel() {
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

  String _getCarPrice() {
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
}
