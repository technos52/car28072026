import 'package:cloud_firestore/cloud_firestore.dart';

class CarouselSetup {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Add sample carousel images to Firebase
  static Future<void> addSampleCarouselImages() async {
    try {
      // Check if images already exist
      final existingImages = await _firestore
          .collection('carousel_images')
          .get();

      if (existingImages.docs.isNotEmpty) {
        print(
          'Carousel images already exist (${existingImages.docs.length} images)',
        );
        return;
      }

      final sampleImages = [
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
        {
          'imageUrl':
              'https://images.unsplash.com/photo-1583121274602-3e2820c69888?ixlib=rb-4.0.3&auto=format&fit=crop&w=2070&q=80',
          'order': 4,
          'title': 'Electric Vehicles',
          'description': 'Future of transportation',
          'createdAt': FieldValue.serverTimestamp(),
        },
        {
          'imageUrl':
              'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?ixlib=rb-4.0.3&auto=format&fit=crop&w=2070&q=80',
          'order': 5,
          'title': 'Luxury Collection',
          'description': 'Premium automotive experience',
          'createdAt': FieldValue.serverTimestamp(),
        },
      ];

      print('Adding ${sampleImages.length} carousel images to Firebase...');

      for (int i = 0; i < sampleImages.length; i++) {
        await _firestore
            .collection('carousel_images')
            .doc('carousel_${i + 1}')
            .set(sampleImages[i]);

        print('✅ Added carousel image ${i + 1}: ${sampleImages[i]['title']}');
      }

      print('🎉 Successfully added all carousel images!');
    } catch (e) {
      print('❌ Error adding carousel images: $e');
      rethrow;
    }
  }

  /// Get all carousel images from Firebase
  static Future<List<Map<String, dynamic>>> getCarouselImages() async {
    try {
      final snapshot = await _firestore
          .collection('carousel_images')
          .orderBy('order', descending: false)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      print('Error fetching carousel images: $e');
      return [];
    }
  }

  /// Delete all carousel images (for testing)
  static Future<void> clearCarouselImages() async {
    try {
      final snapshot = await _firestore.collection('carousel_images').get();

      for (var doc in snapshot.docs) {
        await doc.reference.delete();
      }

      print('🗑️ Cleared all carousel images');
    } catch (e) {
      print('Error clearing carousel images: $e');
      rethrow;
    }
  }

  /// Add a custom carousel image
  static Future<void> addCarouselImage({
    required String imageUrl,
    required int order,
    required String title,
    required String description,
  }) async {
    try {
      await _firestore
          .collection('carousel_images')
          .doc('carousel_custom_${DateTime.now().millisecondsSinceEpoch}')
          .set({
            'imageUrl': imageUrl,
            'order': order,
            'title': title,
            'description': description,
            'createdAt': FieldValue.serverTimestamp(),
          });

      print('✅ Added custom carousel image: $title');
    } catch (e) {
      print('Error adding custom carousel image: $e');
      rethrow;
    }
  }
}
