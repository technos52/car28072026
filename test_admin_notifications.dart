import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:DealMatee/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  print('Initializing Firebase...');
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('✅ Firebase initialized successfully');

    final db = FirebaseFirestore.instance;
    final notifications = await db.collection('admin_notifications')
        .where('type', isEqualTo: 'car_inquiry')
        .get();

    print('\nFound ${notifications.docs.length} car inquiries:');
    for (var doc in notifications.docs) {
      final data = doc.data();
      final carId = data['carId']?.toString();
      final sellerId = data['sellerId']?.toString();
      final buyerName = data['buyerName']?.toString();
      final carName = data['carName']?.toString();
      final carModel = data['carModel']?.toString();
      
      print('\nNotification: $buyerName enquired about $carName $carModel (ID: ${doc.id})');
      print('  carId: $carId');
      print('  sellerId: $sellerId');
      
      if (carId == null || carId.isEmpty) {
        print('  ❌ No carId in notification');
        continue;
      }

      // Check root collection
      final rootDoc = await db.collection('cars').doc(carId).get();
      if (rootDoc.exists) {
        print('  ✅ Found in root collection /cars/$carId');
        print('    Root car fields: ${rootDoc.data()?.keys.toList()}');
        print('    Root imageUrl: ${rootDoc.data()?['imageUrl']}');
        print('    Root imageUrls: ${rootDoc.data()?['imageUrls']}');
        print('    Root imagePaths: ${rootDoc.data()?['imagePaths']}');
      } else {
        print('  ❌ Not found in root collection /cars/$carId');
      }

      // Check user-specific collection
      if (sellerId != null && sellerId.isNotEmpty) {
        final sellerDoc = await db.collection('users').doc(sellerId).collection('cars').doc(carId).get();
        if (sellerDoc.exists) {
          print('  ✅ Found in seller subcollection /users/$sellerId/cars/$carId');
          print('    Seller car fields: ${sellerDoc.data()?.keys.toList()}');
          print('    Seller imageUrl: ${sellerDoc.data()?['imageUrl']}');
          print('    Seller imageUrls: ${sellerDoc.data()?['imageUrls']}');
          print('    Seller imagePaths: ${sellerDoc.data()?['imagePaths']}');
        } else {
          print('  ❌ Not found in seller subcollection /users/$sellerId/cars/$carId');
        }
      } else {
        print('  ⚠️ No sellerId provided to check subcollection');
      }
    }
  } catch (e) {
    print('❌ Error: $e');
  }
  print('\nDone. Exiting...');
}
