import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'core/services/remote_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp();
    print('✅ Firebase initialized successfully');

    // Test carousel images
    await testCarouselImages();
  } catch (e) {
    print('❌ Error initializing Firebase: $e');
  }
}

Future<void> testCarouselImages() async {
  try {
    print('\n🔍 Testing carousel images from Firebase...');

    // Initialize RemoteService
    final remoteService = RemoteService();

    // Fetch carousel images
    final images = await remoteService.getCarouselImages();

    if (images.isEmpty) {
      print('⚠️  No carousel images found in Firebase');
      print('📝 Adding sample carousel images...');

      await addSampleCarouselImages();

      // Try fetching again
      final newImages = await remoteService.getCarouselImages();
      if (newImages.isNotEmpty) {
        print(
          '✅ Successfully added and fetched ${newImages.length} carousel images',
        );
        for (int i = 0; i < newImages.length; i++) {
          print('   ${i + 1}. ${newImages[i]}');
        }
      } else {
        print('❌ Failed to add carousel images');
      }
    } else {
      print('✅ Found ${images.length} carousel images in Firebase:');
      for (int i = 0; i < images.length; i++) {
        print('   ${i + 1}. ${images[i]}');
      }
    }
  } catch (e) {
    print('❌ Error testing carousel images: $e');
  }
}

Future<void> addSampleCarouselImages() async {
  try {
    final firestore = FirebaseFirestore.instance;

    final carouselImages = [
      {
        'imageUrl':
            'https://images.unsplash.com/photo-1549317661-bd32c8ce0db2?ixlib=rb-4.0.3&auto=format&fit=crop&w=2070&q=80',
        'order': 1,
        'title': 'Premium Cars',
        'description': 'Find your dream car today',
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'imageUrl':
            'https://images.unsplash.com/photo-1552519507-da3b142c6e3d?ixlib=rb-4.0.3&auto=format&fit=crop&w=2070&q=80',
        'order': 2,
        'title': 'Best Deals',
        'description': 'Luxury cars for low prices',
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'imageUrl':
            'https://images.unsplash.com/photo-1503376780353-7e6692767b70?ixlib=rb-4.0.3&auto=format&fit=crop&w=2070&q=80',
        'order': 3,
        'title': 'Sports Cars',
        'description': 'Experience the thrill',
        'createdAt': FieldValue.serverTimestamp(),
      },
    ];

    for (int i = 0; i < carouselImages.length; i++) {
      await firestore
          .collection('carousel_images')
          .doc('carousel_${i + 1}')
          .set(carouselImages[i]);
    }

    print('✅ Added ${carouselImages.length} sample carousel images');
  } catch (e) {
    print('❌ Error adding sample carousel images: $e');
  }
}
