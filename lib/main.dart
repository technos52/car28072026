import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'firebase_options.dart';
import 'app/routes/app_pages.dart';
import 'app/routes/app_routes.dart';
import 'core/database/database_service.dart';
import 'core/services/remote_service.dart';
import 'core/services/storage_service.dart';
import 'core/services/notification_service.dart';
import 'core/utils/check_missing_fields.dart';

// Background message handler for Firebase Messaging
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  print('Handling a background message: ${message.messageId}');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    print('Initializing Firebase...');
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('Firebase initialized successfully');

    print('Initializing GetStorage...');
    await GetStorage.init();
    print('GetStorage initialized successfully');

    if (!kIsWeb) {
      print('Initializing DatabaseService...');
      try {
        await Get.putAsync<DatabaseService>(
          () async => DatabaseService(),
          permanent: true,
        ).timeout(const Duration(seconds: 5));
        print('DatabaseService initialized successfully');
      } catch (e) {
        print('DatabaseService initialization failed or timed out: $e');
      }
    } else {
      print(
        'Skipping DatabaseService initialization on web (SQLite not supported)',
      );
    }

    print('Initializing RemoteService...');
    try {
      Get.put(RemoteService(), permanent: true);
      print('RemoteService initialized successfully');
    } catch (e) {
      print('RemoteService initialization failed: $e');
    }

    print('Initializing StorageService...');
    try {
      Get.put(StorageService(), permanent: true);
      print('StorageService initialized successfully');
    } catch (e) {
      print('StorageService initialization failed: $e');
    }

    // Initialize Notification Service (non-blocking)
    print('Initializing NotificationService...');
    NotificationService()
        .initialize()
        .then((_) {
          print('NotificationService initialized successfully');
        })
        .catchError((e) {
          print('Error initializing NotificationService: $e');
        });

    // Set up background message handler
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    // Check for missing fields in Firebase (non-blocking)
    CheckMissingFields.checkAndReportMissingFields().catchError((e) {
      print('Error checking missing fields: $e');
    });

    // Uncomment the line below to automatically update cars with data from description
    // await CheckMissingFields.updateCarsWithDescriptionData();

    print('Starting app...');
    runApp(const MyApp());
  } catch (e) {
    print('Error initializing app: $e');
    runApp(
      MaterialApp(
        home: Scaffold(body: Center(child: Text('Error initializing app: $e'))),
      ),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Deal Matee',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      initialRoute: AppRoutes.splash,
      getPages: AppPages.pages,
      builder: (context, child) {
        return Overlay(
          initialEntries: [
            OverlayEntry(
              builder: (context) => child ?? const SizedBox(),
            ),
          ],
        );
      },
    );
  }
}
