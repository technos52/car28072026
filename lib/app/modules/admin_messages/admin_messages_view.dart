import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/app_color.dart';
import '../../../core/constants/app_images.dart';
import '../../../core/utils/ts.dart';
import '../../../core/utils/app_text.dart';
import '../../../core/utils/size.dart';
import '../../routes/app_routes.dart';
import 'controller/admin_messages_controller.dart';

class AdminMessagesView extends GetView<AdminMessagesController> {
  const AdminMessagesView({super.key});

  // Valid app routes
  static final List<String> _validRoutes = [
    AppRoutes.splash,
    AppRoutes.home,
    AppRoutes.auth,
    AppRoutes.phone,
    AppRoutes.otp,
    AppRoutes.profile,
    AppRoutes.shop,
    AppRoutes.verification,
    AppRoutes.verificationDocs,
    AppRoutes.addCar,
    AppRoutes.cars,
    AppRoutes.carDetail,
    AppRoutes.root,
    AppRoutes.search,
    AppRoutes.ownerCars,
  ];

  // Helper method to check if a string is a valid app route
  bool _isValidRoute(String route) {
    // Normalize route (ensure it starts with /)
    final normalizedRoute = route.startsWith('/') ? route : '/$route';
    return _validRoutes.contains(normalizedRoute);
  }

  // Helper method to check if a string looks like a URL
  bool _isUrl(String str) {
    if (str.isEmpty) return false;

    // Check if it contains a dot and doesn't contain spaces (common URL pattern)
    if (str.contains('.') && !str.contains(' ')) {
      // Check for common TLD patterns
      final tldPattern = RegExp(
        r'\.(com|org|net|edu|gov|io|co|uk|de|fr|in|au|ca|jp|cn|ru|br|es|it|nl|se|no|dk|fi|pl|cz|gr|pt|ie|at|ch|be|tr|kr|mx|ar|za|nz|sg|hk|my|th|ph|id|vn|ae|sa|il|eg|ng|ke|ma|dz|tn|ly|sd|et|gh|ci|sn|cm|ug|tz|mw|zm|bw|na|mu|sc|mg|rw|bi|dj|km|so|er|ss|cf|td|ne|ml|bf|mr|gm|gw|sl|lr|tg|bj|cv|st|gq|ga|cg|cd|ao|mz|zw|ls|sz|bot|ai|ag|aw|bs|bb|bz|bm|vg|ky|dm|do|gd|gy|ht|jm|ms|kn|lc|vc|sr|tt|tc|vi|as|gu|mp|pr|um|us|vi|ax|al|ad|am|az|by|ba|bg|hr|cy|ee|fo|ge|gi|gl|gg|hu|is|im|je|li|lt|lu|mk|md|mc|me|ro|sm|rs|sk|si|ua|va)(/|$|\?|#|:|\s)',
        caseSensitive: false,
      );
      if (tldPattern.hasMatch(str)) {
        return true;
      }
      // Check for IP address pattern
      if (RegExp(r'^\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}').hasMatch(str)) {
        return true;
      }
      // Check for localhost
      if (str.toLowerCase().startsWith('localhost')) {
        return true;
      }
    }

    return false;
  }

  @override
  Widget build(BuildContext context) {
    // Mark all messages as read when the view is opened
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (controller.unreadCount.value > 0) {
        controller.markAllAsRead();
      }
    });

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Image.asset(AppImage.logo, fit: BoxFit.contain),
        ),
        title: AppText(
          'Notifications',
          style: Ts.semiBold18(color: AppColor.secondary),
        ),
        centerTitle: true,
        actions: [
          Obx(() {
            if (controller.unreadCount.value > 0) {
              return TextButton(
                onPressed: () {
                  controller.markAllAsRead();
                },
                child: AppText(
                  'Mark as Read',
                  style: Ts.medium14(color: AppColor.secondary),
                ),
              );
            }
            return const SizedBox.shrink();
          }),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.messages.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.notifications_outlined,
                    size: 80,
                    color: AppColor.gray400,
                  ),
                  const Hbox(24),
                  AppText(
                    'No Notifications',
                    style: Ts.semiBold16(color: AppColor.textcolor),
                  ),
                  const Hbox(12),
                  AppText(
                    'You will see notifications from admin and car inquiries here',
                    style: Ts.regular14(color: AppColor.gray600),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: controller.messages.length,
          itemBuilder: (context, index) {
            final message = controller.messages[index];
            final notificationType =
                message['notificationType'] ?? 'user_notification';
            final isUnread =
                message['isRead'] == false || message['isRead'] == null;

            return GestureDetector(
              onTap: () {
                if (isUnread) {
                  controller.markAsRead(
                    message['id'],
                    notificationType,
                    sourceCollection: message['sourceCollection'],
                  );
                }
              },
              child: Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isUnread
                      ? AppColor.secondary.withOpacity(0.02)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isUnread
                        ? AppColor.secondary.withOpacity(0.3)
                        : AppColor.gray200,
                    width: isUnread ? 1.5 : 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: message['notificationType'] == 'car_inquiry'
                                ? Colors.green.withOpacity(0.1)
                                : AppColor.secondary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            message['notificationType'] == 'car_inquiry'
                                ? Icons.car_rental
                                : Icons.admin_panel_settings,
                            color: message['notificationType'] == 'car_inquiry'
                                ? Colors.green
                                : AppColor.secondary,
                            size: 20,
                          ),
                        ),
                        const Wbox(12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              AppText(
                                message['notificationType'] == 'car_inquiry'
                                    ? 'Car Inquiry'
                                    : 'Admin',
                                style: Ts.semiBold14(color: AppColor.textcolor),
                              ),
                              if (message['timestamp'] != null)
                                AppText(
                                  _formatTimestamp(message['timestamp']),
                                  style: Ts.regular12(color: AppColor.gray600),
                                ),
                            ],
                          ),
                        ),
                        if (isUnread)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    if (message['title'] != null) ...[
                      AppText(
                        message['title'],
                        style: Ts.semiBold16(
                          color: isUnread
                              ? AppColor.textcolor
                              : AppColor.gray600,
                        ),
                      ),
                      const Hbox(8),
                    ],
                    const Hbox(12),
                    AppText(
                      message['message'] ?? '',
                      style: Ts.regular14(
                        color: isUnread ? AppColor.textcolor : AppColor.gray600,
                      ),
                    ),
                    if (message['imageUrl'] != null &&
                        message['imageUrl'].toString().isNotEmpty) ...[
                      const Hbox(12),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          message['imageUrl'],
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Container(
                                height: 200,
                                color: AppColor.gray200,
                                child: Center(
                                  child: Icon(
                                    Icons.broken_image,
                                    color: AppColor.gray400,
                                    size: 48,
                                  ),
                                ),
                              ),
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Container(
                              height: 200,
                              color: AppColor.gray200,
                              child: Center(
                                child: CircularProgressIndicator(
                                  value:
                                      loadingProgress.expectedTotalBytes != null
                                      ? loadingProgress.cumulativeBytesLoaded /
                                            loadingProgress.expectedTotalBytes!
                                      : null,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                    if (message['buttonText'] != null &&
                        message['buttonText'].toString().isNotEmpty) ...[
                      const Hbox(12),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () async {
                            final buttonAction = message['buttonAction']
                                ?.toString();
                            if (buttonAction != null &&
                                buttonAction.isNotEmpty) {
                              try {
                                String urlString = buttonAction.trim();

                                // Check if it's already a full URL (starts with http:// or https://)
                                if (urlString.startsWith('http://') ||
                                    urlString.startsWith('https://')) {
                                  // Already a full URL, use as is
                                }
                                // Check if it's a valid internal route
                                else if (_isValidRoute(urlString)) {
                                  final route = urlString.startsWith('/')
                                      ? urlString
                                      : '/$urlString';
                                  try {
                                    Get.toNamed(route);
                                  } catch (e) {
                                    print(
                                      'Error navigating to route $route: $e',
                                    );
                                    if (Get.context != null &&
                                        Get.context!.mounted) {
                                      Get.snackbar(
                                        'Error',
                                        'Invalid route',
                                        snackPosition: SnackPosition.BOTTOM,
                                        backgroundColor: Colors.red,
                                        colorText: Colors.white,
                                      );
                                    }
                                  }
                                  return;
                                }
                                // Check if it looks like a URL/domain (contains dot, TLD, etc.)
                                else if (_isUrl(urlString)) {
                                  urlString = 'https://$urlString';
                                }
                                // Default: treat as URL and add https:// (always route unknown actions to browser)
                                else {
                                  urlString = 'https://$urlString';
                                }

                                // Try to parse and launch the URL
                                final Uri url = Uri.parse(urlString);
                                try {
                                  final canLaunch = await canLaunchUrl(url);
                                  if (canLaunch) {
                                    launchUrl(
                                      url,
                                      mode: LaunchMode.externalApplication,
                                    ).catchError((e) {
                                      print('Error launching URL: $e');
                                      return false;
                                    });
                                  } else {
                                    if (Get.context != null &&
                                        Get.context!.mounted) {
                                      Get.snackbar(
                                        'Error',
                                        'Could not open the link',
                                        snackPosition: SnackPosition.BOTTOM,
                                        backgroundColor: Colors.red,
                                        colorText: Colors.white,
                                      );
                                    }
                                  }
                                } catch (e) {
                                  print('Error checking/launching URL: $e');
                                  if (Get.context != null &&
                                      Get.context!.mounted) {
                                    Get.snackbar(
                                      'Error',
                                      'Could not open the link',
                                      snackPosition: SnackPosition.BOTTOM,
                                      backgroundColor: Colors.red,
                                      colorText: Colors.white,
                                    );
                                  }
                                }
                              } catch (e) {
                                print('Error handling button action: $e');
                                if (Get.context != null &&
                                    Get.context!.mounted) {
                                  Get.snackbar(
                                    'Error',
                                    'Failed to open link',
                                    snackPosition: SnackPosition.BOTTOM,
                                    backgroundColor: Colors.red,
                                    colorText: Colors.white,
                                  );
                                }
                              }
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColor.secondary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: AppText(
                            message['buttonText'],
                            style: Ts.semiBold14(color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                    if (message['notificationType'] == 'car_inquiry' &&
                        message['buyerName'] != null) ...[
                      const Hbox(8),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColor.gray100,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.person_outline,
                              size: 16,
                              color: AppColor.gray600,
                            ),
                            const Wbox(8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  AppText(
                                    'Buyer: ${message['buyerName']}',
                                    style: Ts.semiBold12(
                                      color: AppColor.textcolor,
                                    ),
                                  ),
                                  if (message['carName'] != null &&
                                      message['carModel'] != null)
                                    AppText(
                                      'Car: ${message['carName']} ${message['carModel']}',
                                      style: Ts.regular12(
                                        color: AppColor.gray600,
                                      ),
                                    ),
                                  if (message['carPrice'] != null)
                                    AppText(
                                      'Price: ${message['carPrice']}',
                                      style: Ts.regular12(
                                        color: AppColor.secondary,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            );
          },
        );
      }),
    );
  }

  String _formatTimestamp(dynamic timestamp) {
    if (timestamp == null) return '';

    DateTime dateTime;
    if (timestamp is DateTime) {
      dateTime = timestamp;
    } else if (timestamp is Timestamp) {
      dateTime = timestamp.toDate();
    } else {
      return '';
    }

    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
    } else {
      return 'Just now';
    }
  }
}
