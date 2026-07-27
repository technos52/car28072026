import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import '../constants/firebase_config.dart';

class RemoteService {
  final FirebaseFirestore _db = FirebaseConfig.firestoreDatabaseId != null
      ? FirebaseFirestore.instanceFor(
          app: Firebase.app(),
          databaseId: FirebaseConfig.firestoreDatabaseId!,
        )
      : FirebaseFirestore.instance;

  Future<void> saveUser({
    required String id,
    required String name,
    required String email,
    required String phone,
    required String gender,
    String? avatarUrl,
  }) async {
    await _db.collection('users').doc(id).set({
      'name': name,
      'email': email,
      'phone': phone,
      'gender': gender,
      'avatarUrl': avatarUrl,
      'updatedAt': FieldValue.serverTimestamp(),
      'createdAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> saveShop({
    required String id,
    required String userId,
    required String shopName,
    required String ownerName,
    required String phone,
    required String email,
    required String address,
    required String city,
    required String state,
    required String pincode,
    String? logoUrl,
  }) async {
    final Map<String, dynamic> shopData = {
      'shopName': shopName,
      'ownerName': ownerName,
      'phone': phone,
      'email': email,
      'address': address,
      'city': city,
      'state': state,
      'pincode': pincode,
      'updatedAt': FieldValue.serverTimestamp(),
      'createdAt': FieldValue.serverTimestamp(),
    };

    if (logoUrl != null) {
      shopData['logoUrl'] = logoUrl;
    }

    await _db
        .collection('users')
        .doc(userId)
        .collection('shops')
        .doc(id)
        .set(shopData, SetOptions(merge: true));
  }

  Future<Map<String, dynamic>?> getShop(String userId, String shopId) async {
    final doc = await _db
        .collection('users')
        .doc(userId)
        .collection('shops')
        .doc(shopId)
        .get();
    if (doc.exists) {
      return doc.data();
    }
    return null;
  }

  Future<Map<String, dynamic>?> getUserShop(String userId) async {
    final snapshot = await _db
        .collection('users')
        .doc(userId)
        .collection('shops')
        .limit(1)
        .get();
    if (snapshot.docs.isNotEmpty) {
      return snapshot.docs.first.data();
    }
    return null;
  }

  Future<List<Map<String, dynamic>>> getAdminMessages(String userId) async {
    try {
      final snapshot = await _db
          .collection('users')
          .doc(userId)
          .collection('adminMessages')
          .orderBy('timestamp', descending: true)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        data['notificationType'] = 'admin_message';
        return data;
      }).toList();
    } catch (e) {
      print('Error fetching admin messages: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getUserNotifications(String userId) async {
    try {
      final snapshot = await _db
          .collection('users')
          .doc(userId)
          .collection('notifications')
          .orderBy('timestamp', descending: true)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        if (data['type'] != null) {
          data['notificationType'] = data['type'];
        } else {
          data['notificationType'] = 'user_notification';
        }
        return data;
      }).toList();
    } catch (e) {
      print('Error fetching user notifications: $e');
      return [];
    }
  }

  Future<void> markAdminMessageAsRead(String userId, String messageId) async {
    try {
      await _db
          .collection('users')
          .doc(userId)
          .collection('adminMessages')
          .doc(messageId)
          .update({'isRead': true});
    } catch (e) {
      print('Error marking admin message as read: $e');
    }
  }

  Future<void> markUserNotificationAsRead(
    String userId,
    String notificationId,
  ) async {
    try {
      await _db
          .collection('users')
          .doc(userId)
          .collection('notifications')
          .doc(notificationId)
          .update({'isRead': true});
    } catch (e) {
      print('Error marking user notification as read: $e');
    }
  }

  Future<bool> isAdmin(String userId) async {
    try {
      final doc = await _db.collection('admins').doc(userId).get();
      return doc.exists;
    } catch (e) {
      print('Error checking admin status: $e');
      return false;
    }
  }

  Future<List<Map<String, dynamic>>> getAdminNotifications() async {
    try {
      final snapshot = await _db
          .collection('admin_notifications')
          .orderBy('timestamp', descending: true)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        if (data['type'] != null) {
          data['notificationType'] = data['type'];
        } else {
          data['notificationType'] = 'admin_notification';
        }
        return data;
      }).toList();
    } catch (e) {
      print('Error fetching admin notifications: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getCarInquiryNotifications() async {
    try {
      final snapshot = await _db
          .collection('admin_notifications')
          .where('type', isEqualTo: 'car_inquiry')
          .orderBy('timestamp', descending: true)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        data['notificationType'] = 'car_inquiry';
        return data;
      }).toList();
    } catch (e) {
      print('Error fetching car inquiry notifications: $e');
      return [];
    }
  }

  Future<void> markAdminNotificationAsRead(String notificationId) async {
    try {
      await _db.collection('admin_notifications').doc(notificationId).update({
        'isRead': true,
      });
    } catch (e) {
      print('Error marking admin notification as read: $e');
    }
  }

  Stream<Map<String, dynamic>?> getUserShopStream(String userId) {
    return _db
        .collection('users')
        .doc(userId)
        .collection('shops')
        .limit(1)
        .snapshots()
        .map((snapshot) {
          if (snapshot.docs.isNotEmpty) {
            return snapshot.docs.first.data();
          }
          return null;
        });
  }

  Future<bool> userExists(String userId) async {
    final doc = await _db.collection('users').doc(userId).get();
    return doc.exists;
  }

  Future<Map<String, dynamic>?> getUser(String userId) async {
    final doc = await _db.collection('users').doc(userId).get();
    if (doc.exists) {
      return doc.data();
    }
    return null;
  }

  Stream<Map<String, dynamic>?> getUserStream(String userId) {
    return _db.collection('users').doc(userId).snapshots().map((doc) {
      if (doc.exists) {
        return doc.data();
      }
      return null;
    });
  }

  // Car operations
  Future<void> saveCar({
    required String id,
    required String userId,
    required String make,
    required String model,
    required String year,
    required String price,
    String? imageUrl,
    List<String>? imageUrls,
    String? description,
    String? owner,
    String? color,
    String? variant,
    String? kmsDriven,
    String? fuelType,
    String? transmission,
    String? insurance,
    String? mileage,
    String? tankCapacity,
    String? state,
    String? city,
    String? pincode,
    bool isAvailable = true,
  }) async {
    final publicCarRef = _db.collection('cars').doc(id);
    final publicCarDoc = await publicCarRef.get();
    final isNewCar = !publicCarDoc.exists;

    final Map<String, dynamic> carData = {
      'make': make,
      'model': model,
      'year': year,
      'price': price,
      'description': description,
      'owner': owner ?? '',
      'color': color ?? '',
      'variant': variant ?? '',
      'kmsDriven': kmsDriven ?? '',
      'fuelType': fuelType ?? '',
      'transmission': transmission ?? '',
      'insurance': insurance ?? '',
      'mileage': mileage ?? '',
      'tankCapacity': tankCapacity ?? '',
      'state': state ?? '',
      'city': city ?? '',
      'pincode': pincode ?? '',
      'isAvailable': isAvailable,
      'updatedAt': FieldValue.serverTimestamp(),
    };

    if (isNewCar) {
      carData['createdAt'] = FieldValue.serverTimestamp();
      carData['soldCount'] = 0;
    }

    if (imageUrls != null && imageUrls.isNotEmpty) {
      carData['imageUrls'] = imageUrls;
      carData['imageUrl'] = imageUrls.first;
    } else if (imageUrl != null) {
      carData['imageUrl'] = imageUrl;
      try {
        if (imageUrl.startsWith('[') && imageUrl.endsWith(']')) {
          final List<dynamic> parsed = jsonDecode(imageUrl);
          carData['imageUrls'] = parsed.cast<String>();
          carData['imageUrl'] = parsed.isNotEmpty ? parsed.first : imageUrl;
        }
      } catch (e) {}
    }

    await _db
        .collection('users')
        .doc(userId)
        .collection('cars')
        .doc(id)
        .set(carData, SetOptions(merge: true));

    final Map<String, dynamic> publicCarData = {'userId': userId, ...carData};
    await publicCarRef.set(publicCarData, SetOptions(merge: true));
  }

  Future<List<Map<String, dynamic>>> getUserCars(String userId) async {
    final snapshot = await _db
        .collection('users')
        .doc(userId)
        .collection('cars')
        .get();
    return snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>?;
      final result = <String, dynamic>{'id': doc.id};
      if (data != null) {
        result.addAll(data);
        if (result['soldCount'] == null) {
          result['soldCount'] = 0;
        }
      }
      return result;
    }).toList();
  }

  Future<List<Map<String, dynamic>>> getAllCars({String? excludeUserId}) async {
    final snapshot = await _db.collection('cars').get();
    final allCars = snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>?;
      final result = <String, dynamic>{'id': doc.id};
      if (data != null) {
        result.addAll(data);
        if (result['soldCount'] == null) {
          result['soldCount'] = 0;
        }
      }
      return result;
    }).toList();

    // Filter out user's own cars if excludeUserId is provided
    if (excludeUserId != null) {
      allCars.removeWhere((car) => car['userId'] == excludeUserId);
    }

    // Sort by createdAt descending (most recent first)
    allCars.sort((a, b) {
      final aCreated = a['createdAt'] as Timestamp?;
      final bCreated = b['createdAt'] as Timestamp?;
      if (aCreated != null && bCreated != null) {
        return bCreated.compareTo(aCreated);
      } else if (aCreated != null) {
        return -1;
      } else if (bCreated != null) {
        return 1;
      }
      final aYear = int.tryParse(a['year']?.toString() ?? '') ?? 0;
      final bYear = int.tryParse(b['year']?.toString() ?? '') ?? 0;
      return bYear.compareTo(aYear);
    });

    return allCars;
  }

  Future<List<Map<String, dynamic>>> getCarsByOwner(String ownerId) async {
    try {
      Query query = _db
          .collection('cars')
          .where('userId', isEqualTo: ownerId)
          .where('isAvailable', isEqualTo: true);

      final snapshot = await query.get();

      final cars = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>?;
        final result = <String, dynamic>{'id': doc.id};
        if (data != null) {
          result.addAll(data);
          if (result['soldCount'] == null) {
            result['soldCount'] = 0;
          }
        }
        return result;
      }).toList();

      cars.sort((a, b) {
        final aCreated = a['createdAt'] as Timestamp?;
        final bCreated = b['createdAt'] as Timestamp?;
        if (aCreated != null && bCreated != null) {
          return bCreated.compareTo(aCreated);
        }
        return 0;
      });

      return cars;
    } catch (e) {
      print('Error getting cars by owner: $e');
      return [];
    }
  }

  Future<void> deleteCar(String userId, String carId) async {
    await _db
        .collection('users')
        .doc(userId)
        .collection('cars')
        .doc(carId)
        .delete();
    await _db.collection('cars').doc(carId).delete();
  }

  Future<List<String>> getUniqueBrands() async {
    final snapshot = await _db
        .collection('cars')
        .where('isAvailable', isEqualTo: true)
        .get();

    final brands = <String>{};
    for (var doc in snapshot.docs) {
      final data = doc.data();
      final make = data['make']?.toString();
      if (make != null && make.isNotEmpty) {
        brands.add(make);
      }
    }

    return brands.toList()..sort();
  }

  Future<void> addToWishlist(String userId, String carId) async {
    await _db
        .collection('users')
        .doc(userId)
        .collection('wishlist')
        .doc(carId)
        .set({
          'carId': carId,
          'addedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
  }

  Future<void> removeFromWishlist(String userId, String carId) async {
    await _db
        .collection('users')
        .doc(userId)
        .collection('wishlist')
        .doc(carId)
        .delete();
  }

  Future<List<String>> getWishlist(String userId) async {
    final snapshot = await _db
        .collection('users')
        .doc(userId)
        .collection('wishlist')
        .get();
    return snapshot.docs.map((doc) => doc.id).toList();
  }

  Future<Map<String, dynamic>?> getCarById(String carId) async {
    final doc = await _db.collection('cars').doc(carId).get();
    if (doc.exists) {
      final data = doc.data();
      if (data != null) {
        final result = <String, dynamic>{'id': doc.id};
        result.addAll(data);
        return result;
      }
    }
    return null;
  }

  Future<void> updateCarFields(
    String carId,
    Map<String, dynamic> fieldsToUpdate,
  ) async {
    await _db.collection('cars').doc(carId).update(fieldsToUpdate);

    final carData = await _db.collection('cars').doc(carId).get();
    if (carData.exists) {
      final userId = carData.data()?['userId'] as String?;
      if (userId != null) {
        await _db
            .collection('users')
            .doc(userId)
            .collection('cars')
            .doc(carId)
            .update(fieldsToUpdate);
      }
    }
  }

  Future<void> incrementSoldCount(String carId) async {
    final carData = await _db.collection('cars').doc(carId).get();
    if (!carData.exists) {
      throw Exception('Car not found');
    }

    final currentSoldCount = (carData.data()?['soldCount'] as int?) ?? 0;
    final newSoldCount = currentSoldCount + 1;

    await _db.collection('cars').doc(carId).update({
      'soldCount': newSoldCount,
      'updatedAt': FieldValue.serverTimestamp(),
    });

    final userId = carData.data()?['userId'] as String?;
    if (userId != null) {
      await _db
          .collection('users')
          .doc(userId)
          .collection('cars')
          .doc(carId)
          .update({
            'soldCount': newSoldCount,
            'updatedAt': FieldValue.serverTimestamp(),
          });
    }
  }

  Future<void> markCarAsSold(String carId) async {
    await updateCarFields(carId, {
      'isAvailable': false,
      'updatedAt': FieldValue.serverTimestamp(),
    });
    await incrementSoldCount(carId);
  }

  Future<void> saveKycDocument({
    required String id,
    required String userId,
    String? panPath,
    String? aadhaarPath,
    String? addressProofPath,
    bool isVerified = false,
  }) async {
    await _db
        .collection('users')
        .doc(userId)
        .collection('kyc_documents')
        .doc(id)
        .set({
          'panPath': panPath,
          'aadhaarPath': aadhaarPath,
          'addressProofPath': addressProofPath,
          'isVerified': isVerified,
          'updatedAt': FieldValue.serverTimestamp(),
          'createdAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
  }

  Future<Map<String, dynamic>?> getKycDocument(String userId) async {
    final snapshot = await _db
        .collection('users')
        .doc(userId)
        .collection('kyc_documents')
        .limit(1)
        .get();
    if (snapshot.docs.isNotEmpty) {
      return snapshot.docs.first.data();
    }
    return null;
  }

  Future<void> sendKycUploadNotificationToAdmin({
    required String userId,
    required String userName,
    required String userEmail,
    String? panPath,
    String? aadhaarPath,
    String? addressProofPath,
  }) async {
    try {
      final notificationId =
          '${userId}_kyc_${DateTime.now().millisecondsSinceEpoch}';

      await _db.collection('admin_notifications').doc(notificationId).set({
        'userId': userId,
        'userName': userName,
        'userEmail': userEmail,
        'type': 'kyc_upload',
        'panPath': panPath,
        'aadhaarPath': aadhaarPath,
        'addressProofPath': addressProofPath,
        'status': 'pending',
        'isRead': false,
        'timestamp': FieldValue.serverTimestamp(),
        'createdAt': FieldValue.serverTimestamp(),
      });

      print('KYC upload notification sent to admin for user: $userId');
    } catch (e) {
      print('Error sending KYC notification to admin: $e');
    }
  }

  Future<void> sendInquiryNotification({
    required String buyerId,
    required String buyerName,
    required String buyerEmail,
    required String sellerId,
    required String carId,
    required String carName,
    required String carModel,
    required String carPrice,
    String? carImageUrl,
  }) async {
    try {
      final sellerData = await getUser(sellerId);
      final sellerName = sellerData?['name']?.toString() ?? 'Unknown Seller';

      // If no carImageUrl provided, try to fetch it from Firestore
      String? resolvedImageUrl = carImageUrl;
      if (resolvedImageUrl == null || resolvedImageUrl.isEmpty) {
        try {
          final carDoc = await _db.collection('cars').doc(carId).get();
          if (carDoc.exists) {
            final carData = carDoc.data();
            if (carData != null) {
              if (carData['imageUrls'] is List &&
                  (carData['imageUrls'] as List).isNotEmpty) {
                resolvedImageUrl = (carData['imageUrls'] as List).first.toString();
              } else if (carData['imageUrl'] is String &&
                  (carData['imageUrl'] as String).isNotEmpty) {
                final raw = carData['imageUrl'] as String;
                if (raw.startsWith('[')) {
                  try {
                    final parsed = jsonDecode(raw) as List;
                    if (parsed.isNotEmpty) resolvedImageUrl = parsed.first.toString();
                  } catch (_) {}
                } else {
                  resolvedImageUrl = raw;
                }
              }
            }
          }
          // Fallback: try seller subcollection
          if (resolvedImageUrl == null || resolvedImageUrl.isEmpty) {
            final sellerCarDoc = await _db
                .collection('users')
                .doc(sellerId)
                .collection('cars')
                .doc(carId)
                .get();
            if (sellerCarDoc.exists) {
              final carData = sellerCarDoc.data();
              if (carData != null) {
                if (carData['imageUrls'] is List &&
                    (carData['imageUrls'] as List).isNotEmpty) {
                  resolvedImageUrl = (carData['imageUrls'] as List).first.toString();
                } else if (carData['imageUrl'] is String &&
                    (carData['imageUrl'] as String).isNotEmpty) {
                  final raw = carData['imageUrl'] as String;
                  if (raw.startsWith('[')) {
                    try {
                      final parsed = jsonDecode(raw) as List;
                      if (parsed.isNotEmpty) resolvedImageUrl = parsed.first.toString();
                    } catch (_) {}
                  } else {
                    resolvedImageUrl = raw;
                  }
                }
              }
            }
          }
        } catch (e) {
          print('Error fetching car image for notification: $e');
        }
      }

      final notificationId =
          '${buyerId}_${carId}_${DateTime.now().millisecondsSinceEpoch}';

      final notificationData = {
        'buyerId': buyerId,
        'buyerName': buyerName,
        'buyerEmail': buyerEmail,
        'sellerId': sellerId,
        'sellerName': sellerName,
        'carId': carId,
        'carName': carName,
        'carModel': carModel,
        'carPrice': carPrice,
        'type': 'car_inquiry',
        'message':
            '$sellerName was inquired by $buyerName for $carName $carModel',
        'isRead': false,
        'timestamp': FieldValue.serverTimestamp(),
        'createdAt': FieldValue.serverTimestamp(),
      };

      // Embed image URL directly so admin panel doesn't need a secondary fetch
      if (resolvedImageUrl != null && resolvedImageUrl.isNotEmpty) {
        notificationData['carImageUrl'] = resolvedImageUrl;
      }

      await _db.collection('admin_notifications').doc(notificationId).set(notificationData);

      final sellerNotificationId =
          '${buyerId}_${carId}_seller_${DateTime.now().millisecondsSinceEpoch}';

      await _db
          .collection('users')
          .doc(sellerId)
          .collection('notifications')
          .doc(sellerNotificationId)
          .set({
            'buyerId': buyerId,
            'buyerName': buyerName,
            'buyerEmail': buyerEmail,
            'carId': carId,
            'carName': carName,
            'carModel': carModel,
            'carPrice': carPrice,
            'type': 'car_inquiry',
            'message':
                '$buyerName has shown interest in buying your $carName $carModel',
            'isRead': false,
            'timestamp': FieldValue.serverTimestamp(),
            'createdAt': FieldValue.serverTimestamp(),
          });

      print('Inquiry notification sent to admin and seller');
    } catch (e) {
      print('Error sending inquiry notification: $e');
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getAllCarsWithMissingFields() async {
    final snapshot = await _db.collection('cars').get();
    final carsWithMissingFields = <Map<String, dynamic>>[];

    final requiredFields = [
      'owner',
      'color',
      'variant',
      'kmsDriven',
      'fuelType',
      'transmission',
      'insurance',
      'mileage',
      'tankCapacity',
    ];

    for (var doc in snapshot.docs) {
      final data = doc.data();
      final missingFields = <String>[];

      for (var field in requiredFields) {
        if (data[field] == null ||
            (data[field] is String && (data[field] as String).isEmpty)) {
          missingFields.add(field);
        }
      }

      if (missingFields.isNotEmpty) {
        carsWithMissingFields.add({
          'id': doc.id,
          'make': data['make'] ?? '',
          'model': data['model'] ?? '',
          'missingFields': missingFields,
          'data': data,
        });
      }
    }

    return carsWithMissingFields;
  }

  Future<List<String>> getCarouselImages() async {
    try {
      final snapshot = await _db
          .collection('carousel_images')
          .orderBy('order', descending: false)
          .get();
      return snapshot.docs
          .map((doc) => doc.data()['imageUrl'] as String? ?? '')
          .where((url) => url.isNotEmpty)
          .toList();
    } catch (e) {
      try {
        final snapshot = await _db
            .collection('carousel_images')
            .orderBy('createdAt', descending: false)
            .get();
        return snapshot.docs
            .map((doc) => doc.data()['imageUrl'] as String? ?? '')
            .where((url) => url.isNotEmpty)
            .toList();
      } catch (e2) {
        return [];
      }
    }
  }
}
