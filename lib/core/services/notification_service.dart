import 'dart:async';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import '../constants/firebase_config.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();
  final FirebaseFirestore _db = FirebaseConfig.firestoreDatabaseId != null
      ? FirebaseFirestore.instanceFor(
          app: Firebase.app(),
          databaseId: FirebaseConfig.firestoreDatabaseId!,
        )
      : FirebaseFirestore.instance;

  bool _initialized = false;
  StreamSubscription<QuerySnapshot>? _notificationListener;
  StreamSubscription<User?>? _authListener;

  /// Android notification channel for high-priority car enquiry alerts
  static const AndroidNotificationChannel _channel = AndroidNotificationChannel(
    'car_dealer_notifications',
    'Car Dealer Notifications',
    description: 'Notifications for car inquiries and admin messages',
    importance: Importance.high,
    playSound: true,
    enableVibration: true,
    showBadge: true,
  );

  Future<void> initialize() async {
    if (_initialized) return;

    try {
      // Request permission (iOS + Android 13+)
      NotificationSettings settings = await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        print('User granted notification permission');
      } else {
        print('User declined or has not accepted notification permission');
      }

      // Create the Android notification channel
      final androidPlugin = _localNotifications
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      if (androidPlugin != null) {
        await androidPlugin.createNotificationChannel(_channel);
        print('Android notification channel created');
      }

      // Initialize local notifications for Android
      const AndroidInitializationSettings initializationSettingsAndroid =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      const DarwinInitializationSettings initializationSettingsIOS =
          DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      const InitializationSettings initializationSettings =
          InitializationSettings(
        android: initializationSettingsAndroid,
        iOS: initializationSettingsIOS,
      );

      await _localNotifications.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: (NotificationResponse response) {
          // Handle notification tap
          print('Notification tapped: ${response.payload}');
        },
      );

      // Get FCM token and save it
      await _saveFCMToken();

      // Listen for token refresh
      _messaging.onTokenRefresh.listen((newToken) {
        _saveFCMTokenToFirestore(newToken);
      });

      // Handle foreground messages (from Cloud Functions push)
      FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

      // Handle background messages (when app is in background)
      FirebaseMessaging.onMessageOpenedApp.listen(_handleBackgroundMessage);

      // Check if app was opened from a notification
      RemoteMessage? initialMessage = await _messaging.getInitialMessage();
      if (initialMessage != null) {
        _handleBackgroundMessage(initialMessage);
      }

      // Start listening for auth state changes to manage Firestore listener
      _authListener = FirebaseAuth.instance.authStateChanges().listen((user) {
        if (user != null) {
          _startNotificationListener(user.uid);
          // Re-save FCM token whenever user signs in
          _saveFCMToken();
        } else {
          _stopNotificationListener();
        }
      });

      // If user is already logged in, start the listener now
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        _startNotificationListener(currentUser.uid);
      }

      _initialized = true;
      print('NotificationService initialized successfully');
    } catch (e) {
      print('Error initializing NotificationService: $e');
    }
  }

  /// Starts a real-time Firestore listener on the user's notifications subcollection.
  /// This shows a local push notification on the phone's notification bar
  /// the instant a new enquiry notification document is created.
  void _startNotificationListener(String userId) {
    _stopNotificationListener(); // Cancel any existing listener

    print('Starting real-time notification listener for user: $userId');

    _notificationListener = _db
        .collection('users')
        .doc(userId)
        .collection('notifications')
        .where('isRead', isEqualTo: false)
        .limit(20)
        .snapshots()
        .listen(
      (snapshot) {
        for (final change in snapshot.docChanges) {
          if (change.type == DocumentChangeType.added) {
            final data = change.doc.data();
            if (data == null) continue;

            // Only show local notification for new unread notifications
            // Skip if the doc has been around (avoid firing on first listen)
            final timestamp = data['timestamp'];
            if (timestamp != null && timestamp is Timestamp) {
              final docTime = timestamp.toDate();
              final now = DateTime.now();
              // Only show notification if it was created in the last 30 seconds
              // This prevents spamming on first app load
              if (now.difference(docTime).inSeconds > 30) continue;
            } else {
              // No timestamp yet (server timestamp pending) — this is a brand new doc
              // Show notification
            }

            _showLocalNotification(data);
          }
        }
      },
      onError: (error) {
        print('Notification listener error: $error');
      },
    );
  }

  void _stopNotificationListener() {
    _notificationListener?.cancel();
    _notificationListener = null;
  }

  /// Shows a local notification on the device's notification bar.
  Future<void> _showLocalNotification(Map<String, dynamic> data) async {
    final type = data['type'] ?? '';
    String title;
    String body;

    if (type == 'car_inquiry') {
      final buyerName = data['buyerName'] ?? 'Someone';
      final carName = data['carName'] ?? '';
      final carModel = data['carModel'] ?? '';
      title = 'New Car Enquiry! 🚗';
      body = '$buyerName is interested in your $carName $carModel';
    } else {
      title = data['title'] ?? 'New Notification';
      body = data['message'] ?? '';
    }

    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'car_dealer_notifications',
      'Car Dealer Notifications',
      channelDescription: 'Notifications for car inquiries and admin messages',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
      playSound: true,
      enableVibration: true,
      icon: '@mipmap/ic_launcher',
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      DateTime.now().millisecondsSinceEpoch.remainder(100000),
      title,
      body,
      details,
      payload: type,
    );
  }

  Future<void> _saveFCMToken() async {
    try {
      final token = await _messaging.getToken();
      if (token != null) {
        await _saveFCMTokenToFirestore(token);
        print('FCM Token: $token');
      }
    } catch (e) {
      print('Error getting FCM token: $e');
    }
  }

  Future<void> _saveFCMTokenToFirestore(String token) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await _db.collection('users').doc(user.uid).set({
          'fcmToken': token,
          'fcmTokenUpdatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
        print('FCM token saved to Firestore for user: ${user.uid}');
      }
    } catch (e) {
      print('Error saving FCM token to Firestore: $e');
    }
  }

  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    print('Foreground FCM message received: ${message.notification?.title}');

    // Show local notification when FCM push arrives while app is in foreground
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'car_dealer_notifications',
      'Car Dealer Notifications',
      channelDescription: 'Notifications for car inquiries and admin messages',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
      playSound: true,
      enableVibration: true,
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      message.hashCode,
      message.notification?.title ?? 'New Notification',
      message.notification?.body ?? '',
      platformChannelSpecifics,
      payload: message.data.toString(),
    );
  }

  void _handleBackgroundMessage(RemoteMessage message) {
    print('Background message received: ${message.notification?.title}');
    // Handle navigation or other actions when notification is tapped
  }

  /// Clean up resources
  void dispose() {
    _stopNotificationListener();
    _authListener?.cancel();
  }
}
