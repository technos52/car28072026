import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:DealMatee/firebase_options.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  
  test('Query admin notifications and print details', () async {
    // Initialize Firebase
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('✅ Firebase initialized');

    final firestore = FirebaseFirestore.instance;

    print('\n--- ADMIN NOTIFICATIONS ---');
    final snapshot = await firestore.collection('admin_notifications').get();
    print('Found ${snapshot.docs.length} notifications');
    for (var doc in snapshot.docs) {
      print('Notification ID: ${doc.id}');
      print('Data: ${doc.data()}');
    }

    print('\n--- ALL CARS ---');
    final carsSnapshot = await firestore.collection('cars').get();
    print('Found ${carsSnapshot.docs.length} cars in root collection');
    for (var doc in carsSnapshot.docs) {
      print('Car ID: ${doc.id}');
      print('Data: ${doc.data()}');
    }

    print('\n--- USERS CODES AND THEIR CARS ---');
    final usersSnapshot = await firestore.collection('users').get();
    print('Found ${usersSnapshot.docs.length} users');
    for (var uDoc in usersSnapshot.docs) {
      print('User ID: ${uDoc.id} (${uDoc.data()['name']})');
      final uCarsSnapshot = await firestore.collection('users').doc(uDoc.id).collection('cars').get();
      print('  User Cars Count: ${uCarsSnapshot.docs.length}');
      for (var doc in uCarsSnapshot.docs) {
        print('  Car ID: ${doc.id}');
        print('  Car Data: ${doc.data()}');
      }
    }
  });
}
