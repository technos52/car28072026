import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AdminService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<bool> isAdmin(String? uid) async {
    if (uid == null) return false;
    final doc = await _db.collection('admins').doc(uid).get();
    return doc.exists;
  }

  Future<List<Map<String, dynamic>>> getAllUsers() async {
    final usersSnapshot = await _db.collection('users').get();
    
    return usersSnapshot.docs.map((doc) {
      final data = doc.data();
      return {'id': doc.id, ...data};
    }).toList();
  }

  Future<Map<String, dynamic>?> getUser(String userId) async {
    final doc = await _db.collection('users').doc(userId).get();
    if (doc.exists) {
      return {'id': doc.id, ...doc.data()!};
    }
    return null;
  }

  Future<List<Map<String, dynamic>>> getUserShops(String userId) async {
    final snapshot = await _db
        .collection('users')
        .doc(userId)
        .collection('shops')
        .get();
    return snapshot.docs.map((doc) {
      final data = doc.data();
      return {'id': doc.id, ...data};
    }).toList();
  }

  Future<List<Map<String, dynamic>>> getUserCars(String userId) async {
    final snapshot = await _db
        .collection('users')
        .doc(userId)
        .collection('cars')
        .get();
    return snapshot.docs.map((doc) {
      final data = doc.data();
      return {'id': doc.id, ...data};
    }).toList();
  }

  Future<Map<String, dynamic>?> getKycDocument(String userId) async {
    final snapshot = await _db
        .collection('users')
        .doc(userId)
        .collection('kyc_documents')
        .limit(1)
        .get();
    if (snapshot.docs.isNotEmpty) {
      return {
        'id': snapshot.docs.first.id,
        ...snapshot.docs.first.data(),
      };
    }
    return null;
  }


  Future<List<Map<String, dynamic>>> getAllCars() async {
    final snapshot = await _db.collection('cars').get();
    
    final carsList = await Future.wait(snapshot.docs.map((doc) async {
      final data = doc.data();
      String? shopName = data['shopName']?.toString().isNotEmpty == true 
          ? data['shopName'] 
          : data['sellerName']?.toString().isNotEmpty == true 
              ? data['sellerName'] 
              : null;
              
      if (shopName == null && data['userId'] != null) {
        final shopsSnapshot = await _db
            .collection('users')
            .doc(data['userId'])
            .collection('shops')
            .limit(1)
            .get();
            
        if (shopsSnapshot.docs.isNotEmpty) {
          shopName = shopsSnapshot.docs.first.data()['shopName'];
        } else {
          final userDoc = await _db.collection('users').doc(data['userId']).get();
          if (userDoc.exists) {
            shopName = userDoc.data()?['name'] ?? userDoc.data()?['displayName'];
          }
        }
      }
      
      return {'id': doc.id, 'shopName': shopName, ...data};
    }));
    
    return carsList.toList();
  }

  Future<void> deleteCar(String carId) async {
    final carDoc = await _db.collection('cars').doc(carId).get();
    if (carDoc.exists) {
      final data = carDoc.data() ?? {};
      final userId = data['userId'] ?? data['userid'] ?? data['sellerId'];
      final shopId = data['shopId'] ?? data['shopid'];

      if (userId != null) {
        // Delete from user's cars
        try {
          await _db
              .collection('users')
              .doc(userId)
              .collection('cars')
              .doc(carId)
              .delete();
        } catch (e) {
          print('Error deleting from user subcollection: $e');
        }

        // Delete from shop's cars if applicable
        if (shopId != null) {
          try {
            await _db
                .collection('users')
                .doc(userId)
                .collection('shops')
                .doc(shopId)
                .collection('cars')
                .doc(carId)
                .delete();
          } catch (e) {
            print('Error deleting from shop subcollection: $e');
          }
        }
      }
      
      // Delete from global cars collection
      await _db.collection('cars').doc(carId).delete();
    }
  }

  Future<void> updateCarAvailability(String carId, bool isAvailable) async {
    await _db.collection('cars').doc(carId).update({
      'isAvailable': isAvailable,
      'updatedAt': FieldValue.serverTimestamp(),
    });
    final carDoc = await _db.collection('cars').doc(carId).get();
    if (carDoc.exists) {
      final userId = carDoc.data()?['userId'];
      if (userId != null) {
        await _db
            .collection('users')
            .doc(userId)
            .collection('cars')
            .doc(carId)
            .update({
          'isAvailable': isAvailable,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
    }
  }


  Future<List<Map<String, dynamic>>> getAdminNotifications() async {
    try {
      final snapshot = await _db
          .collection('admin_notifications')
          .orderBy('timestamp', descending: true)
          .get();

      final rawDocs = snapshot.docs.map((doc) {
        final data = doc.data();
        return {'id': doc.id, ...data};
      }).toList();

      // Collect docs that are missing important details
      final docsNeedingUpdate = rawDocs.where((doc) {
        if (doc['type'] != 'car_inquiry') return false;
        final hasImage = doc['carImageUrl']?.toString().isNotEmpty == true;
        final hasCarName = doc['carName']?.toString().isNotEmpty == true;
        final hasBuyerName = doc['buyerName']?.toString().isNotEmpty == true;
        final hasSellerName = doc['sellerName']?.toString().isNotEmpty == true;
        return !hasImage || !hasCarName || !hasBuyerName || !hasSellerName;
      }).toList();

      if (docsNeedingUpdate.isEmpty) return rawDocs;

      // Fetch missing data in parallel
      final results = await Future.wait(
        docsNeedingUpdate.map((doc) => _resolveEnquiryDetails(doc)),
      );

      // Backfill found data into Firestore (batch write)
      final batch = _db.batch();
      bool hasBatchUpdates = false;

      for (int i = 0; i < docsNeedingUpdate.length; i++) {
        final updates = results[i];
        if (updates.isNotEmpty) {
          final docId = docsNeedingUpdate[i]['id'] as String;
          // Apply to local list immediately
          docsNeedingUpdate[i].addAll(updates);
          // Persist to Firestore
          batch.update(_db.collection('admin_notifications').doc(docId), updates);
          hasBatchUpdates = true;
        }
      }

      if (hasBatchUpdates) {
        batch.commit().catchError((e) {
          print('Backfill batch error (non-fatal): $e');
        });
      }

      return rawDocs;
    } catch (e) {
      print('Error fetching notifications: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>> _resolveEnquiryDetails(Map<String, dynamic> doc) async {
    final Map<String, dynamic> updates = {};
    
    // Resolve Car
    if (doc['carId'] != null) {
      final carId = doc['carId'] as String;
      String? sellerId = doc['sellerId'] as String?;
      
      DocumentSnapshot<Map<String, dynamic>>? carDoc;
      try { carDoc = await _db.collection('cars').doc(carId).get(); } catch (_) {}

      if (carDoc == null || !carDoc.exists) {
        if (sellerId != null && sellerId.isNotEmpty) {
          try { carDoc = await _db.collection('users').doc(sellerId).collection('cars').doc(carId).get(); } catch (_) {}
        }
      }

      if (carDoc != null && carDoc.exists && carDoc.data() != null) {
        final data = carDoc.data()!;
        if (doc['carImageUrl']?.toString().isNotEmpty != true) {
          final url = _extractFirstImageUrl(data);
          if (url != null) updates['carImageUrl'] = url;
        }
        if (doc['carName']?.toString().isNotEmpty != true) {
          updates['carName'] = data['make'] ?? 'Unknown Make';
        }
        if (doc['carModel']?.toString().isNotEmpty != true) {
          updates['carModel'] = data['model'] ?? '';
        }
        if (doc['carPrice']?.toString().isNotEmpty != true) {
          updates['carPrice'] = data['price']?.toString() ?? '';
        }
      }
    }

    // Resolve Buyer
    if (doc['buyerId'] != null && doc['buyerName']?.toString().isNotEmpty != true) {
      try {
        final userDoc = await _db.collection('users').doc(doc['buyerId']).get();
        if (userDoc.exists && userDoc.data() != null) {
          updates['buyerName'] = userDoc.data()!['name'] ?? userDoc.data()!['displayName'] ?? 'Unknown Buyer';
          updates['buyerEmail'] = userDoc.data()!['email'] ?? '';
        }
      } catch (_) {}
    }

    // Resolve Seller
    if (doc['sellerId'] != null && doc['sellerName']?.toString().isNotEmpty != true) {
      try {
        final shopDoc = await _db.collection('users').doc(doc['sellerId']).collection('shops').limit(1).get();
        if (shopDoc.docs.isNotEmpty) {
          updates['sellerName'] = shopDoc.docs.first.data()['shopName'] ?? 'Unknown Shop';
        } else {
          final userDoc = await _db.collection('users').doc(doc['sellerId']).get();
          if (userDoc.exists && userDoc.data() != null) {
            updates['sellerName'] = userDoc.data()!['name'] ?? userDoc.data()!['displayName'] ?? 'Unknown Seller';
          }
        }
      } catch (_) {}
    }

    return updates;
  }



  /// Extracts the first image URL from a Firestore car document.
  String? _extractFirstImageUrl(Map<String, dynamic> data) {
    // imageUrls as List
    if (data['imageUrls'] is List && (data['imageUrls'] as List).isNotEmpty) {
      return (data['imageUrls'] as List).first.toString();
    }
    // imageUrls as JSON-encoded string
    if (data['imageUrls'] is String) {
      final raw = data['imageUrls'] as String;
      if (raw.startsWith('[')) {
        try {
          final parsed = jsonDecode(raw) as List;
          if (parsed.isNotEmpty) return parsed.first.toString();
        } catch (_) {}
      } else if (raw.isNotEmpty) {
        return raw;
      }
    }
    // imageUrl as plain string or JSON-encoded list
    if (data['imageUrl'] is String && (data['imageUrl'] as String).isNotEmpty) {
      final raw = data['imageUrl'] as String;
      if (raw.startsWith('[')) {
        try {
          final parsed = jsonDecode(raw) as List;
          if (parsed.isNotEmpty) return parsed.first.toString();
        } catch (_) {}
      } else {
        return raw;
      }
    }
    // imagePaths as List
    if (data['imagePaths'] is List && (data['imagePaths'] as List).isNotEmpty) {
      return (data['imagePaths'] as List).first.toString();
    }
    return null;
  }


  Future<int> getUnreadNotificationsCount() async {
    try {
      final snapshot = await _db
          .collection('admin_notifications')
          .where('isRead', isEqualTo: false)
          .get();
      return snapshot.docs.length;
    } catch (e) {
      print('Error getting unread count: $e');
      return 0;
    }
  }

  Future<void> markNotificationAsRead(String notificationId) async {
    await _db.collection('admin_notifications').doc(notificationId).update({
      'isRead': true,
    });
  }

  Future<void> markNotificationAsUnread(String notificationId) async {
    await _db.collection('admin_notifications').doc(notificationId).update({
      'isRead': false,
    });
  }

  Future<void> markAllEnquiriesAsRead() async {
    try {
      final snapshot = await _db
          .collection('admin_notifications')
          .where('type', isEqualTo: 'car_inquiry')
          .where('isRead', isEqualTo: false)
          .get();
      
      final batch = _db.batch();
      for (var doc in snapshot.docs) {
        batch.update(doc.reference, {'isRead': true});
      }
      await batch.commit();
    } catch (e) {
      final snapshot = await _db
          .collection('admin_notifications')
          .where('isRead', isEqualTo: false)
          .get();
      
      final batch = _db.batch();
      for (var doc in snapshot.docs) {
        if (doc.data()['type'] == 'car_inquiry') {
          batch.update(doc.reference, {'isRead': true});
        }
      }
      await batch.commit();
    }
  }

  Future<Map<String, dynamic>> getDashboardStats() async {
    final usersSnapshot = await _db.collection('users').get();
    final carsSnapshot = await _db.collection('cars').get();
    final notificationsSnapshot = await _db
        .collection('admin_notifications')
        .where('isRead', isEqualTo: false)
        .get();

    int totalUsers = usersSnapshot.docs.length;
    int totalCars = carsSnapshot.docs.length;
    int availableCars = carsSnapshot.docs
        .where((doc) => doc.data()['isAvailable'] == true)
        .length;
    int pendingKyc = 0;
    int verifiedKyc = 0;

    for (var userDoc in usersSnapshot.docs) {
      final kycSnapshot = await _db
          .collection('users')
          .doc(userDoc.id)
          .collection('kyc_documents')
          .limit(1)
          .get();
      if (kycSnapshot.docs.isNotEmpty) {
        final isVerified = kycSnapshot.docs.first.data()['isVerified'] ?? false;
        if (isVerified) {
          verifiedKyc++;
        } else {
          pendingKyc++;
        }
      }
    }

    final unreadEnquiries = await getUnreadNotificationsCount();

    return {
      'totalUsers': totalUsers,
      'totalCars': totalCars,
      'availableCars': availableCars,
      'soldCars': totalCars - availableCars,
      'pendingKyc': pendingKyc,
      'verifiedKyc': verifiedKyc,
      'unreadNotifications': notificationsSnapshot.docs.length,
      'unreadEnquiries': unreadEnquiries,
    };
  }

  Future<void> deleteUser(String userId) async {
    final batch = _db.batch();
    final userRef = _db.collection('users').doc(userId);

    final shopsSnapshot =
        await _db.collection('users').doc(userId).collection('shops').get();
    for (var shop in shopsSnapshot.docs) {
      batch.delete(shop.reference);
    }

    final carsSnapshot =
        await _db.collection('users').doc(userId).collection('cars').get();
    for (var car in carsSnapshot.docs) {
      batch.delete(car.reference);
      final publicCarRef = _db.collection('cars').doc(car.id);
      batch.delete(publicCarRef);
    }

    final kycSnapshot = await _db
        .collection('users')
        .doc(userId)
        .collection('kyc_documents')
        .get();
    for (var kyc in kycSnapshot.docs) {
      batch.delete(kyc.reference);
    }

    batch.delete(userRef);
    await batch.commit();
  }

  // Admin management methods
  Future<List<Map<String, dynamic>>> getAllAdmins() async {
    try {
      final snapshot = await _db.collection('admins').get();
      final List<Map<String, dynamic>> admins = [];
      
      for (var doc in snapshot.docs) {
        try {
          final uid = doc.id;
          final adminData = doc.data();
          
          String email = adminData['email'] ?? 'N/A';
          String name = adminData['name'] ?? 'N/A';
          String password = adminData['password'] ?? 'N/A';
          
          if (email == 'N/A' || email.isEmpty) {
            email = 'User ID: ${uid.length > 8 ? uid.substring(0, 8) : uid}...';
          }
          if (name == 'N/A' || name.isEmpty) {
            name = 'Admin User';
          }
          
          admins.add({
            'uid': uid,
            'email': email,
            'name': name,
            'password': password,
            'createdAt': adminData['createdAt'],
            'updatedAt': adminData['updatedAt'],
          });
        } catch (e) {
          final uid = doc.id;
          final adminData = doc.data();
          
          admins.add({
            'uid': uid,
            'email': adminData['email'] ?? 'User ID: ${uid.length > 8 ? uid.substring(0, 8) : uid}...',
            'name': adminData['name'] ?? 'Admin User',
            'password': adminData['password'] ?? 'N/A',
            'createdAt': adminData['createdAt'],
            'updatedAt': adminData['updatedAt'],
          });
        }
      }
      
      return admins;
    } catch (e) {
      return [];
    }
  }

  Future<bool> addAdmin(String uid) async {
    try {
      // Check if already admin
      final adminDoc = await _db.collection('admins').doc(uid).get();
      if (adminDoc.exists) {
        return false; // Already an admin
      }
      
      // Add to admins collection (user might exist in Auth but not in users collection)
      await _db.collection('admins').doc(uid).set({
        'createdAt': FieldValue.serverTimestamp(),
        'addedBy': _auth.currentUser?.uid,
      });
      
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> removeAdmin(String uid) async {
    try {
      // Prevent removing yourself
      if (uid == _auth.currentUser?.uid) {
        return false;
      }
      
      await _db.collection('admins').doc(uid).delete();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<Map<String, dynamic>?> getUserByEmail(String email) async {
    try {
      final snapshot = await _db
          .collection('users')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();
      
      if (snapshot.docs.isEmpty) {
        return null;
      }
      
      final doc = snapshot.docs.first;
      return {
        'uid': doc.id,
        ...doc.data(),
      };
    } catch (e) {
      return null;
    }
  }

  Future<Map<String, dynamic>> createAdminAccount({
    required String email,
    required String password,
    String? name,
  }) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        return {
          'success': false,
          'error': 'You must be logged in to create admin accounts',
        };
      }

      final currentUserIsAdmin = await isAdmin(currentUser.uid);
      if (!currentUserIsAdmin) {
        return {
          'success': false,
          'error': 'Permission denied. Only admins can create new admin accounts. Your UID: ${currentUser.uid}',
        };
      }

      String normalizedEmail = email.trim();
      
      if (!normalizedEmail.contains('@')) {
        normalizedEmail = '$normalizedEmail@admin.local';
      }

      String normalizedPassword = password;
      if (normalizedPassword.length < 6) {
        normalizedPassword = normalizedPassword.padRight(6, '0');
      }

      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: normalizedEmail,
        password: normalizedPassword,
      );

      final uid = userCredential.user!.uid;

      final displayName = name ?? (email.contains('@') ? email.split('@')[0] : email);
      await userCredential.user!.updateDisplayName(displayName);

      await _db.collection('admins').doc(uid).set({
        'createdAt': FieldValue.serverTimestamp(),
        'addedBy': currentUser.uid,
        'email': email,
        'name': name ?? displayName,
        'password': normalizedPassword,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      return {
        'success': true,
        'uid': uid,
        'email': email,
      };
    } catch (e) {
      String errorMessage = e.toString();
      if (errorMessage.contains('invalid-email')) {
        errorMessage = 'Invalid email format. Firebase requires a valid email address (e.g., user@example.com)';
      } else if (errorMessage.contains('weak-password')) {
        errorMessage = 'Password is too weak. Firebase requires at least 6 characters';
      } else if (errorMessage.contains('email-already-in-use')) {
        errorMessage = 'An account with this email already exists';
      } else if (errorMessage.contains('permission-denied')) {
        errorMessage = 'Permission denied. Make sure your UID (${_auth.currentUser?.uid ?? "unknown"}) exists in the admins collection in Firestore.';
      }
      return {
        'success': false,
        'error': errorMessage,
      };
    }
  }

  Future<bool> resetAdminPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<Map<String, dynamic>> updateAdminAccount({
    required String uid,
    String? email,
    String? name,
    String? password,
  }) async {
    try {
      final updates = <String, dynamic>{
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (email != null && email.isNotEmpty) {
        updates['email'] = email;
      }

      if (name != null && name.isNotEmpty) {
        updates['name'] = name;
      }

      if (password != null && password.isNotEmpty) {
        updates['password'] = password;
      }

      await _db.collection('admins').doc(uid).update(updates);

      return {
        'success': true,
        'message': email != null 
          ? 'Admin updated. Note: Email change in Firestore only. User needs to update email in Firebase Auth settings.'
          : 'Admin updated successfully',
      };
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  Future<Map<String, dynamic>> deleteAdminAccount(String uid) async {
    try {
      await _db.collection('admins').doc(uid).delete();

      return {
        'success': true,
        'message': 'Admin account removed from admins collection. Note: Firebase Auth account must be deleted manually from Firebase Console.',
      };
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  Future<void> verifyKycAndNotify(String userId, bool isVerified) async {
    final snapshot = await _db
        .collection('users')
        .doc(userId)
        .collection('kyc_documents')
        .limit(1)
        .get();
    
    if (snapshot.docs.isNotEmpty) {
      await snapshot.docs.first.reference.update({
        'isVerified': isVerified,
        'verifiedAt': FieldValue.serverTimestamp(),
        'verifiedBy': _auth.currentUser?.uid,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      if (isVerified) {
        final userDoc = await _db.collection('users').doc(userId).get();
        final userData = userDoc.data();
        final userName = userData?['name'] ?? 'User';

        await _db.collection('users').doc(userId).collection('notifications').add({
          'title': 'KYC Verification Approved',
          'message': 'Your KYC documents have been verified. You can now add cars to the platform.',
          'type': 'kyc_verified',
          'isRead': false,
          'timestamp': FieldValue.serverTimestamp(),
        });

        await _db.collection('admin_notifications').add({
          'userId': userId,
          'userName': userName,
          'title': 'KYC Verified',
          'message': 'KYC documents for $userName have been verified',
          'type': 'kyc_verified',
          'isRead': true,
          'timestamp': FieldValue.serverTimestamp(),
        });
      }
    }
  }

  Future<List<Map<String, dynamic>>> getCarouselImages() async {
    try {
      final snapshot = await _db
          .collection('carousel_images')
          .orderBy('order', descending: false)
          .get();
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          ...data,
        };
      }).toList();
    } catch (e) {
      try {
        final snapshot = await _db
            .collection('carousel_images')
            .orderBy('createdAt', descending: false)
            .get();
        return snapshot.docs.map((doc) {
          final data = doc.data();
          return {
            'id': doc.id,
            ...data,
          };
        }).toList();
      } catch (e2) {
        return [];
      }
    }
  }

  Future<String> uploadCarouselImage(String imageUrl) async {
    try {
      final existingImages = await getCarouselImages();
      final nextOrder = existingImages.length;
      final docRef = await _db.collection('carousel_images').add({
        'imageUrl': imageUrl,
        'order': nextOrder,
        'createdAt': FieldValue.serverTimestamp(),
        'createdBy': _auth.currentUser?.uid,
      });
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to save carousel image: $e');
    }
  }

  Future<void> deleteCarouselImage(String imageId) async {
    try {
      await _db.collection('carousel_images').doc(imageId).delete();
    } catch (e) {
      throw Exception('Failed to delete carousel image: $e');
    }
  }

  Future<void> updateCarouselImageOrder(String imageId, int order) async {
    try {
      await _db.collection('carousel_images').doc(imageId).update({
        'order': order,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to update carousel image order: $e');
    }
  }

  Future<void> updateCarouselImage(String imageId, String imageUrl) async {
    try {
      await _db.collection('carousel_images').doc(imageId).update({
        'imageUrl': imageUrl,
        'updatedAt': FieldValue.serverTimestamp(),
        'updatedBy': _auth.currentUser?.uid,
      });
    } catch (e) {
      throw Exception('Failed to update carousel image: $e');
    }
  }

  // Send message to all users
  Future<Map<String, dynamic>> sendBroadcastMessage({
    required String title,
    required String message,
    String? imageUrl,
    String? buttonText,
    String? buttonAction,
  }) async {
    try {
      final usersSnapshot = await _db.collection('users').get();
      final adminUidsSnapshot = await _db.collection('admins').get();
      final adminUids = adminUidsSnapshot.docs.map((doc) => doc.id).toSet();

      int successCount = 0;
      int failCount = 0;

      final batch = _db.batch();
      int batchCount = 0;

      for (var userDoc in usersSnapshot.docs) {
        // Skip admins
        if (adminUids.contains(userDoc.id)) continue;

        final notificationData = {
          'title': title,
          'message': message,
          'type': 'admin_message',
          'notificationType': 'admin_message',
          'isRead': false,
          'timestamp': FieldValue.serverTimestamp(),
          'sentBy': _auth.currentUser?.uid,
          'sentByType': 'admin',
        };

        if (imageUrl != null && imageUrl.isNotEmpty) {
          notificationData['imageUrl'] = imageUrl;
        }

        if (buttonText != null && buttonText.isNotEmpty) {
          notificationData['buttonText'] = buttonText;
          if (buttonAction != null && buttonAction.isNotEmpty) {
            notificationData['buttonAction'] = buttonAction;
          }
        }

        final notificationRef = _db
            .collection('users')
            .doc(userDoc.id)
            .collection('notifications')
            .doc();

        batch.set(notificationRef, notificationData);
        batchCount++;
        successCount++;

        // Firestore batch limit is 500
        if (batchCount >= 500) {
          await batch.commit();
          batchCount = 0;
        }
      }

      if (batchCount > 0) {
        await batch.commit();
      }

      return {
        'success': true,
        'message': 'Message sent to $successCount users',
        'successCount': successCount,
        'failCount': failCount,
      };
    } catch (e) {
      return {
        'success': false,
        'error': 'Failed to send broadcast message: $e',
      };
    }
  }

  // Send message to individual user
  Future<Map<String, dynamic>> sendIndividualMessage({
    required String userId,
    required String title,
    required String message,
    String? imageUrl,
    String? buttonText,
    String? buttonAction,
  }) async {
    try {
      // Check if user exists
      final userDoc = await _db.collection('users').doc(userId).get();
      if (!userDoc.exists) {
        return {
          'success': false,
          'error': 'User not found',
        };
      }

      final notificationData = {
        'title': title,
        'message': message,
        'type': 'admin_message',
        'notificationType': 'admin_message',
        'isRead': false,
        'timestamp': FieldValue.serverTimestamp(),
        'sentBy': _auth.currentUser?.uid,
        'sentByType': 'admin',
      };

      if (imageUrl != null && imageUrl.isNotEmpty) {
        notificationData['imageUrl'] = imageUrl;
      }

      if (buttonText != null && buttonText.isNotEmpty) {
        notificationData['buttonText'] = buttonText;
        if (buttonAction != null && buttonAction.isNotEmpty) {
          notificationData['buttonAction'] = buttonAction;
        }
      }

      await _db
          .collection('users')
          .doc(userId)
          .collection('notifications')
          .add(notificationData);

      return {
        'success': true,
        'message': 'Message sent successfully',
      };
    } catch (e) {
      return {
        'success': false,
        'error': 'Failed to send message: $e',
      };
    }
  }
}

