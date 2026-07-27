import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

Future<void> main() async {
  // Initialize Firebase
  await Firebase.initializeApp();

  final firestore = FirebaseFirestore.instance;

  // Sample carousel images (you can replace these with actual image URLs)
  final carouselImages = [
    {
      'imageUrl':
          'https://images.unsplash.com/photo-1549317661-bd32c8ce0db2?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=2070&q=80',
      'order': 1,
      'title': 'Premium Cars',
      'description': 'Find your dream car today',
      'createdAt': FieldValue.serverTimestamp(),
    },
    {
      'imageUrl':
          'https://images.unsplash.com/photo-1552519507-da3b142c6e3d?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=2070&q=80',
      'order': 2,
      'title': 'Best Deals',
      'description': 'Luxury cars for low prices',
      'createdAt': FieldValue.serverTimestamp(),
    },
    {
      'imageUrl':
          'https://images.unsplash.com/photo-1503376780353-7e6692767b70?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=2070&q=80',
      'order': 3,
      'title': 'Sports Cars',
      'description': 'Experience the thrill',
      'createdAt': FieldValue.serverTimestamp(),
    },
  ];

  try {
    // Check if carousel images already exist
    final existingImages = await firestore.collection('carousel_images').get();

    if (existingImages.docs.isEmpty) {
      print('Adding sample carousel images to Firebase...');

      // Add each carousel image
      for (int i = 0; i < carouselImages.length; i++) {
        await firestore
            .collection('carousel_images')
            .doc('carousel_${i + 1}')
            .set(carouselImages[i]);

        print('Added carousel image ${i + 1}');
      }

      print('Successfully added ${carouselImages.length} carousel images!');
    } else {
      print(
        'Carousel images already exist in Firebase (${existingImages.docs.length} images)',
      );

      // List existing images
      for (var doc in existingImages.docs) {
        final data = doc.data();
        print('- ${doc.id}: ${data['imageUrl']}');
      }
    }
  } catch (e) {
    print('Error adding carousel images: $e');
  }
}
