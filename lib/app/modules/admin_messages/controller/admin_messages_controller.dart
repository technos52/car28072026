import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import '../../../../core/services/remote_service.dart';

class AdminMessagesController extends GetxController {
  final RxList<Map<String, dynamic>> messages = <Map<String, dynamic>>[].obs;
  final RxBool isLoading = true.obs;
  final RxInt unreadCount = 0.obs;

  StreamSubscription<QuerySnapshot>? _adminMsgListener;
  StreamSubscription<QuerySnapshot>? _userNotifListener;

  @override
  void onInit() {
    super.onInit();
    _startRealtimeListeners();
  }

  @override
  void onClose() {
    _adminMsgListener?.cancel();
    _userNotifListener?.cancel();
    super.onClose();
  }

  /// Sets up real-time Firestore snapshot listeners so notifications appear
  /// instantly without needing to reopen the app.
  void _startRealtimeListeners() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      messages.clear();
      isLoading.value = false;
      return;
    }

    final db = FirebaseFirestore.instance;
    isLoading.value = true;

    // Track which sources have completed their first snapshot
    bool adminMsgLoaded = false;
    bool userNotifLoaded = false;
    final List<Map<String, dynamic>> adminMessages = [];
    final List<Map<String, dynamic>> userNotifications = [];

    void mergeAndUpdate() {
      final allMessages = <Map<String, dynamic>>[
        ...adminMessages,
        ...userNotifications,
      ];

      allMessages.sort((a, b) {
        final aTime = a['timestamp'];
        final bTime = b['timestamp'];
        if (aTime == null && bTime == null) return 0;
        if (aTime == null) return 1;
        if (bTime == null) return -1;

        DateTime aDate, bDate;
        if (aTime is DateTime) {
          aDate = aTime;
        } else if (aTime is Timestamp) {
          aDate = aTime.toDate();
        } else {
          return 0;
        }

        if (bTime is DateTime) {
          bDate = bTime;
        } else if (bTime is Timestamp) {
          bDate = bTime.toDate();
        } else {
          return 0;
        }

        return bDate.compareTo(aDate);
      });

      messages.assignAll(allMessages);

      // Count unread
      int unread = 0;
      for (var message in allMessages) {
        if (message['isRead'] == false || message['isRead'] == null) {
          unread++;
        }
      }
      unreadCount.value = unread;

      if (adminMsgLoaded && userNotifLoaded) {
        isLoading.value = false;
      }
    }

    // Listen to admin messages (personal messages from admin to this user)
    _adminMsgListener = db
        .collection('users')
        .doc(user.uid)
        .collection('adminMessages')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .listen(
      (snapshot) {
        adminMsgLoaded = true;
        adminMessages.clear();
        for (var doc in snapshot.docs) {
          final data = doc.data();
          data['id'] = doc.id;
          data['notificationType'] = data['type'] ?? 'admin_message';
          adminMessages.add(data);
        }
        mergeAndUpdate();
      },
      onError: (e) {
        print('Error listening to admin messages: $e');
        adminMsgLoaded = true;
        mergeAndUpdate();
      },
    );

    // Listen to user notifications (car inquiries, etc.)
    _userNotifListener = db
        .collection('users')
        .doc(user.uid)
        .collection('notifications')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .listen(
      (snapshot) {
        userNotifLoaded = true;
        userNotifications.clear();
        for (var doc in snapshot.docs) {
          final data = doc.data();
          data['id'] = doc.id;
          if (data['type'] != null) {
            data['notificationType'] = data['type'];
          } else {
            data['notificationType'] = 'user_notification';
          }
          userNotifications.add(data);
        }
        mergeAndUpdate();
      },
      onError: (e) {
        print('Error listening to user notifications: $e');
        userNotifLoaded = true;
        mergeAndUpdate();
      },
    );
  }

  Future<void> loadMessages() async {
    // Kept for manual refresh; real-time listeners handle the rest
    _adminMsgListener?.cancel();
    _userNotifListener?.cancel();
    _startRealtimeListeners();
  }

  Future<void> markAsRead(String messageId, String notificationType) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      if (!Get.isRegistered<RemoteService>()) {
        Get.put(RemoteService());
      }
      final remoteService = Get.find<RemoteService>();

      if (notificationType == 'admin_message') {
        await remoteService.markAdminMessageAsRead(user.uid, messageId);
      } else if (notificationType == 'car_inquiry' ||
          notificationType == 'kyc_upload' ||
          notificationType == 'admin_notification') {
        await remoteService.markAdminNotificationAsRead(messageId);
      } else {
        await remoteService.markUserNotificationAsRead(user.uid, messageId);
      }

      // Local state update is automatic via Firestore snapshot listener
    } catch (e) {
      print('Error marking message as read: $e');
    }
  }

  Future<void> markAllAsRead() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      if (!Get.isRegistered<RemoteService>()) {
        Get.put(RemoteService());
      }
      final remoteService = Get.find<RemoteService>();

      for (var message in messages) {
        if (message['isRead'] == false || message['isRead'] == null) {
          final notificationType =
              message['notificationType'] ?? 'user_notification';
          if (notificationType == 'admin_message') {
            await remoteService.markAdminMessageAsRead(user.uid, message['id']);
          } else if (notificationType == 'car_inquiry' ||
              notificationType == 'kyc_upload' ||
              notificationType == 'admin_notification') {
            await remoteService.markAdminNotificationAsRead(message['id']);
          } else {
            await remoteService.markUserNotificationAsRead(
              user.uid,
              message['id'],
            );
          }
        }
      }

      // Local state update is automatic via Firestore snapshot listener
    } catch (e) {
      print('Error marking all messages as read: $e');
    }
  }
}
