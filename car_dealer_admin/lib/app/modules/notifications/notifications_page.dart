import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import '../../../core/services/admin_service.dart';
import '../../../core/widgets/admin_layout.dart';
import '../../../core/utils/toast.dart';
import '../../routes/app_routes.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  final AdminService _adminService = AdminService();
  List<Map<String, dynamic>> _enquiries = [];
  bool _isLoading = true;
  String _filter = 'all';

  @override
  void initState() {
    super.initState();
    _loadEnquiries();
  }

  Future<void> _loadEnquiries() async {
    setState(() => _isLoading = true);
    try {
      final enquiries = await _adminService.getAdminNotifications();
      setState(() {
        _enquiries = enquiries;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        Toast.showError('Failed to load enquiries: $e');
      }
    }
  }

  List<Map<String, dynamic>> get _filteredEnquiries {
    if (_filter == 'all') return _enquiries;
    if (_filter == 'unread') {
      return _enquiries.where((e) => e['isRead'] != true).toList();
    }
    return _enquiries.where((e) => e['isRead'] == true).toList();
  }

  Future<void> _markAsRead(String enquiryId) async {
    try {
      await _adminService.markNotificationAsRead(enquiryId);
      await _loadEnquiries();
    } catch (e) {
      if (mounted) {
        Get.snackbar(
          'Error',
          'Failed to mark as read: $e',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    }
  }

  Future<void> _markCarAsSold(String carId, String enquiryId) async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Mark Car as Sold'),
        content: const Text('Are you sure you want to mark this car as sold? This will make it unavailable for other buyers.'),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            style: TextButton.styleFrom(foregroundColor: Colors.green),
            child: const Text('Mark as Sold'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      Get.dialog(
        const Center(child: CircularProgressIndicator()),
        barrierDismissible: false,
      );

      await _adminService.updateCarAvailability(carId, false);
      await _markAsRead(enquiryId);

      Get.back();

      if (mounted) {
        Get.snackbar(
          'Success',
          'Car marked as sold successfully',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.back();
      if (mounted) {
        Get.snackbar(
          'Error',
          'Failed to mark car as sold: $e',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    }
  }

  Future<void> _markAllAsRead() async {
    try {
      Get.dialog(
        const Center(child: CircularProgressIndicator()),
        barrierDismissible: false,
      );
      await _adminService.markAllEnquiriesAsRead();
      Get.back();
      await _loadEnquiries();
      if (mounted) {
        Get.snackbar(
          'Success',
          'All enquiries marked as read',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.back();
      if (mounted) {
        Get.snackbar(
          'Error',
          'Failed to mark all as read: $e',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    }
  }

  String _formatTimestamp(dynamic timestamp) {
    if (timestamp == null) return 'Unknown date';
    try {
      DateTime date;
      if (timestamp is DateTime) {
        date = timestamp;
      } else {
        date = (timestamp as dynamic).toDate();
      }
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inDays == 0) {
        if (difference.inHours == 0) {
          if (difference.inMinutes == 0) {
            return 'Just now';
          }
          return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
        }
        return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
      } else if (difference.inDays == 1) {
        return 'Yesterday';
      } else if (difference.inDays < 7) {
        return '${difference.inDays} days ago';
      } else {
        return DateFormat('MMM dd, yyyy').format(date);
      }
    } catch (e) {
      return 'Unknown date';
    }
  }

  @override
  Widget build(BuildContext context) {
    final unreadCount = _enquiries.where((e) => e['isRead'] != true).length;

    return AdminLayout(
      currentRoute: AppRoutes.notifications,
      title: 'Car Enquiries',
      actions: [
        if (unreadCount > 0)
          TextButton.icon(
            onPressed: _markAllAsRead,
            icon: const Icon(Icons.done_all_rounded, size: 18),
            label: Text('Mark all read ($unreadCount)'),
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFF6366F1),
            ),
          ),
        IconButton(
          icon: const Icon(Icons.refresh_rounded),
          onPressed: _loadEnquiries,
          tooltip: 'Refresh',
        ),
      ],
      child: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF6366F1).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  Icons.notifications_rounded,
                                  color: Color(0xFF6366F1),
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Car Enquiries',
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'View all enquiries made by users for cars',
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (unreadCount > 0)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.red,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    '$unreadCount new',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: ChoiceChip(
                          label: Text('All (${_enquiries.length})'),
                          selected: _filter == 'all',
                          onSelected: (selected) {
                            if (selected) setState(() => _filter = 'all');
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ChoiceChip(
                          label: Text('Unread ($unreadCount)'),
                          selected: _filter == 'unread',
                          onSelected: (selected) {
                            if (selected) setState(() => _filter = 'unread');
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ChoiceChip(
                          label: Text('Read (${_enquiries.length - unreadCount})'),
                          selected: _filter == 'read',
                          onSelected: (selected) {
                            if (selected) setState(() => _filter = 'read');
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Expanded(
                    child: _filteredEnquiries.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.inbox_rounded,
                                  size: 64,
                                  color: Colors.grey[400],
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  _filter == 'unread'
                                      ? 'No unread enquiries'
                                      : _filter == 'read'
                                          ? 'No read enquiries'
                                          : 'No enquiries yet',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          )
                        : RefreshIndicator(
                            onRefresh: _loadEnquiries,
                            child: ListView.builder(
                              itemCount: _filteredEnquiries.length,
                              itemBuilder: (context, index) {
                                final enquiry = _filteredEnquiries[index];
                                final isRead = enquiry['isRead'] == true;
                                final type = enquiry['type'] ?? 'car_inquiry';
                                final isKyc = type == 'kyc_upload';
                                
                                final timestamp = enquiry['timestamp'];
                                
                                if (isKyc) {
                                  final userName = enquiry['userName']?.toString() ?? 'Unknown User';
                                  final userEmail = enquiry['userEmail']?.toString() ?? '';
                                  final userId = enquiry['userId']?.toString();

                                  return Card(
                                    margin: const EdgeInsets.only(bottom: 12),
                                    elevation: isRead ? 0 : 2,
                                    color: isRead ? Colors.white : Colors.orange.shade50,
                                    child: InkWell(
                                      onTap: () {
                                        if (!isRead) {
                                          _markAsRead(enquiry['id']);
                                        }
                                        if (userId != null) {
                                          Get.toNamed(AppRoutes.userDetail.replaceAll(':id', userId));
                                        }
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.all(16.0),
                                        child: Row(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Container(
                                              width: 48,
                                              height: 48,
                                              decoration: BoxDecoration(
                                                color: isRead
                                                    ? Colors.grey[300]
                                                    : Colors.orange,
                                                shape: BoxShape.circle,
                                              ),
                                              child: Icon(
                                                Icons.assignment_ind_rounded,
                                                color: isRead ? Colors.grey[600] : Colors.white,
                                                size: 24,
                                              ),
                                            ),
                                            const SizedBox(width: 16),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Row(
                                                    children: [
                                                      Expanded(
                                                        child: Text(
                                                          '$userName uploaded KYC documents',
                                                          style: TextStyle(
                                                            fontSize: 16,
                                                            fontWeight: isRead
                                                                ? FontWeight.normal
                                                                : FontWeight.bold,
                                                            color: Colors.black87,
                                                          ),
                                                        ),
                                                      ),
                                                      if (!isRead)
                                                        Container(
                                                          width: 8,
                                                          height: 8,
                                                          decoration: const BoxDecoration(
                                                            color: Colors.orange,
                                                            shape: BoxShape.circle,
                                                          ),
                                                        ),
                                                    ],
                                                  ),
                                                  const SizedBox(height: 8),
                                                  _buildInfoRow(
                                                    Icons.email_outlined,
                                                    userEmail,
                                                    '',
                                                  ),
                                                  const SizedBox(height: 4),
                                                  _buildInfoRow(
                                                    Icons.info_outline_rounded,
                                                    'Status: Pending Verification',
                                                    '',
                                                  ),
                                                  const SizedBox(height: 8),
                                                  Row(
                                                    children: [
                                                      Icon(
                                                        Icons.access_time_rounded,
                                                        size: 14,
                                                        color: Colors.grey[600],
                                                      ),
                                                      const SizedBox(width: 4),
                                                      Text(
                                                        _formatTimestamp(timestamp),
                                                        style: TextStyle(
                                                          fontSize: 12,
                                                          color: Colors.grey[600],
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                            PopupMenuButton<String>(
                                              icon: const Icon(Icons.more_vert_rounded),
                                              onSelected: (value) async {
                                                if (value == 'view_user' && userId != null) {
                                                  Get.toNamed(AppRoutes.userDetail.replaceAll(':id', userId));
                                                } else if (value == 'mark_read' && !isRead) {
                                                  await _markAsRead(enquiry['id']);
                                                } else if (value == 'mark_unread' && isRead) {
                                                  await _adminService.markNotificationAsUnread(enquiry['id']);
                                                  await _loadEnquiries();
                                                }
                                              },
                                              itemBuilder: (context) => [
                                                if (userId != null)
                                                  const PopupMenuItem(
                                                    value: 'view_user',
                                                    child: Row(
                                                      children: [
                                                        Icon(Icons.person_rounded, size: 18),
                                                        SizedBox(width: 8),
                                                        Text('View User Profile'),
                                                      ],
                                                    ),
                                                  ),
                                                const PopupMenuItem(
                                                  value: 'view_kyc',
                                                  child: Row(
                                                    children: [
                                                      Icon(Icons.verified_user_rounded, size: 18),
                                                      SizedBox(width: 8),
                                                      Text('Go to KYC Tab'),
                                                    ],
                                                  ),
                                                ),
                                                if (!isRead)
                                                  const PopupMenuItem(
                                                    value: 'mark_read',
                                                    child: Row(
                                                      children: [
                                                        Icon(Icons.done_rounded, size: 18),
                                                        SizedBox(width: 8),
                                                        Text('Mark as Read'),
                                                      ],
                                                    ),
                                                  ),
                                                if (isRead)
                                                  const PopupMenuItem(
                                                    value: 'mark_unread',
                                                    child: Row(
                                                      children: [
                                                        Icon(Icons.mark_email_unread_rounded, size: 18),
                                                        SizedBox(width: 8),
                                                        Text('Mark as Unread'),
                                                      ],
                                                    ),
                                                  ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                }

                                final buyerName = enquiry['buyerName']?.toString() ?? 'Unknown Buyer';
                                final buyerEmail = enquiry['buyerEmail']?.toString() ?? '';
                                final sellerName = enquiry['sellerName']?.toString() ?? 'Unknown Seller';
                                final carName = enquiry['carName']?.toString() ?? 'Unknown Car';
                                final carModel = enquiry['carModel']?.toString() ?? '';
                                final carPrice = enquiry['carPrice']?.toString() ?? '';
                                final carId = enquiry['carId']?.toString();
                                final buyerId = enquiry['buyerId']?.toString();
                                final sellerId = enquiry['sellerId']?.toString();
                                // Direct embedded image URL — no secondary fetch needed
                                final carImageUrl = enquiry['carImageUrl']?.toString();

                                return Card(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  elevation: isRead ? 0 : 2,
                                  color: isRead ? Colors.white : Colors.blue.shade50,
                                  child: InkWell(
                                    onTap: () {
                                      if (!isRead) {
                                        _markAsRead(enquiry['id']);
                                      }
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          CarEnquiryImage(
                                            carId: carId,
                                            sellerId: sellerId,
                                            carImageUrl: carImageUrl,
                                            isRead: isRead,
                                          ),
                                          const SizedBox(width: 16),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  children: [
                                                    Expanded(
                                                      child: Text(
                                                        '$buyerName enquired about $carName $carModel',
                                                        style: TextStyle(
                                                          fontSize: 16,
                                                          fontWeight: isRead
                                                              ? FontWeight.normal
                                                              : FontWeight.bold,
                                                          color: Colors.black87,
                                                        ),
                                                      ),
                                                    ),
                                                    if (!isRead)
                                                      Container(
                                                        width: 8,
                                                        height: 8,
                                                        decoration: const BoxDecoration(
                                                          color: Colors.blue,
                                                          shape: BoxShape.circle,
                                                        ),
                                                      ),
                                                  ],
                                                ),
                                                const SizedBox(height: 8),
                                                _buildInfoRow(
                                                  Icons.person_rounded,
                                                  'Buyer: $buyerName',
                                                  buyerEmail.isNotEmpty ? ' ($buyerEmail)' : '',
                                                ),
                                                const SizedBox(height: 4),
                                                _buildInfoRow(
                                                  Icons.store_rounded,
                                                  'Seller: $sellerName',
                                                  '',
                                                ),
                                                const SizedBox(height: 4),
                                                _buildInfoRow(
                                                  Icons.attach_money_rounded,
                                                  'Price: ₹$carPrice',
                                                  '',
                                                ),
                                                const SizedBox(height: 8),
                                                Row(
                                                  children: [
                                                    Icon(
                                                      Icons.access_time_rounded,
                                                      size: 14,
                                                      color: Colors.grey[600],
                                                    ),
                                                    const SizedBox(width: 4),
                                                    Text(
                                                      _formatTimestamp(timestamp),
                                                      style: TextStyle(
                                                        fontSize: 12,
                                                        color: Colors.grey[600],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                          PopupMenuButton<String>(
                                            icon: const Icon(Icons.more_vert_rounded),
                                            onSelected: (value) async {
                                              if (value == 'view_buyer' && buyerId != null) {
                                                Get.toNamed('/users/$buyerId');
                                              } else if (value == 'view_seller' && sellerId != null) {
                                                Get.toNamed('/users/$sellerId');
                                              } else if (value == 'mark_sold' && carId != null) {
                                                await _markCarAsSold(carId, enquiry['id']);
                                              } else if (value == 'mark_read' && !isRead) {
                                                await _markAsRead(enquiry['id']);
                                              } else if (value == 'mark_unread' && isRead) {
                                                await _adminService.markNotificationAsUnread(enquiry['id']);
                                                await _loadEnquiries();
                                              }
                                            },
                                            itemBuilder: (context) => [
                                              if (buyerId != null)
                                                const PopupMenuItem(
                                                  value: 'view_buyer',
                                                  child: Row(
                                                    children: [
                                                      Icon(Icons.person_rounded, size: 18),
                                                      SizedBox(width: 8),
                                                      Text('View Buyer'),
                                                    ],
                                                  ),
                                                ),
                                              if (sellerId != null)
                                                const PopupMenuItem(
                                                  value: 'view_seller',
                                                  child: Row(
                                                    children: [
                                                      Icon(Icons.store_rounded, size: 18),
                                                      SizedBox(width: 8),
                                                      Text('View Seller'),
                                                    ],
                                                  ),
                                                ),
                                              if (carId != null)
                                                const PopupMenuItem(
                                                  value: 'mark_sold',
                                                  child: Row(
                                                    children: [
                                                      Icon(Icons.check_circle_rounded, size: 18, color: Colors.green),
                                                      SizedBox(width: 8),
                                                      Text('Mark as Sold', style: TextStyle(color: Colors.green)),
                                                    ],
                                                  ),
                                                ),
                                              if (!isRead)
                                                const PopupMenuItem(
                                                  value: 'mark_read',
                                                  child: Row(
                                                    children: [
                                                      Icon(Icons.done_rounded, size: 18),
                                                      SizedBox(width: 8),
                                                      Text('Mark as Read'),
                                                    ],
                                                  ),
                                                ),
                                              if (isRead)
                                                const PopupMenuItem(
                                                  value: 'mark_unread',
                                                  child: Row(
                                                    children: [
                                                      Icon(Icons.mark_email_unread_rounded, size: 18),
                                                      SizedBox(width: 8),
                                                      Text('Mark as Unread'),
                                                    ],
                                                  ),
                                                ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  );
                                }
                            ),
                          ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String suffix) {
    return Row(
      children: [
        Icon(icon, size: 14, color: Colors.grey[600]),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            '$label$suffix',
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[700],
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class CarEnquiryImage extends StatefulWidget {
  final String? carId;
  final String? sellerId;
  final String? carImageUrl;
  final bool isRead;

  const CarEnquiryImage({
    super.key,
    required this.carId,
    this.sellerId,
    this.carImageUrl,
    required this.isRead,
  });

  @override
  State<CarEnquiryImage> createState() => _CarEnquiryImageState();
}

class _CarEnquiryImageState extends State<CarEnquiryImage> {
  static final Map<String, String?> _imageCache = {};
  bool _isLoading = false;
  String? _imageUrl;

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  @override
  void didUpdateWidget(CarEnquiryImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.carId != widget.carId || oldWidget.sellerId != widget.sellerId) {
      _loadImage();
    }
  }

  Future<void> _loadImage() async {
    final cid = widget.carId;

    // PRIMARY PATH: Use the embedded carImageUrl from the notification document.
    // This is the fastest and most reliable path — no extra Firestore fetch needed.
    if (widget.carImageUrl != null && widget.carImageUrl!.isNotEmpty) {
      if (mounted) {
        setState(() {
          _imageUrl = widget.carImageUrl;
          _isLoading = false;
        });
      }
      return;
    }

    // FALLBACK PATH: For legacy notifications that don't have carImageUrl embedded.
    if (cid == null || cid.isEmpty) {
      if (mounted) {
        setState(() {
          _imageUrl = null;
          _isLoading = false;
        });
      }
      return;
    }

    final cacheKey = '${cid}_${widget.sellerId ?? ""}';
    if (_imageCache.containsKey(cacheKey)) {
      if (mounted) {
        setState(() {
          _imageUrl = _imageCache[cacheKey];
          _isLoading = false;
        });
      }
      return;
    }

    if (mounted) {
      setState(() {
        _isLoading = true;
      });
    }

    String? url;
    try {
      // Try root 'cars' collection first
      try {
        final doc = await FirebaseFirestore.instance.collection('cars').doc(cid).get();
        if (doc.exists && doc.data() != null) {
          url = _extractImageUrl(doc.data()!);
        }
      } catch (e) {
        debugPrint('CarEnquiryImage: root cars fetch error: $e');
      }

      // If still null, try seller subcollection
      if ((url == null || url.isEmpty) &&
          widget.sellerId != null &&
          widget.sellerId!.isNotEmpty) {
        try {
          final sellerDoc = await FirebaseFirestore.instance
              .collection('users')
              .doc(widget.sellerId)
              .collection('cars')
              .doc(cid)
              .get();
          if (sellerDoc.exists && sellerDoc.data() != null) {
            url = _extractImageUrl(sellerDoc.data()!);
          }
        } catch (e) {
          debugPrint('CarEnquiryImage: seller cars fetch error: $e');
        }
      }
    } catch (e) {
      debugPrint('CarEnquiryImage: unexpected error: $e');
    }

    _imageCache[cacheKey] = url;
    if (mounted) {
      setState(() {
        _imageUrl = url;
        _isLoading = false;
      });
    }
  }

  /// Extracts the first available image URL from a Firestore car document map.
  String? _extractImageUrl(Map<String, dynamic> data) {
    // Try imageUrls list
    if (data['imageUrls'] is List && (data['imageUrls'] as List).isNotEmpty) {
      return (data['imageUrls'] as List).first.toString();
    }
    // Try imageUrls as JSON-encoded string
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
    // Try imageUrl string
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
    // Try imagePaths list
    if (data['imagePaths'] is List && (data['imagePaths'] as List).isNotEmpty) {
      return (data['imagePaths'] as List).first.toString();
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: widget.isRead ? Colors.grey[200] : const Color(0xFF6366F1).withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: const Padding(
          padding: EdgeInsets.all(12.0),
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }

    final url = _imageUrl;
    if (url != null && url.isNotEmpty) {
      return Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: Colors.grey[100],
          shape: BoxShape.circle,
        ),
        child: ClipOval(
          child: Image.network(
            url,
            width: 48,
            height: 48,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
          ),
        ),
      );
    }

    return _buildPlaceholder();
  }

  Widget _buildPlaceholder() {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: widget.isRead ? Colors.grey[300] : const Color(0xFF6366F1),
        shape: BoxShape.circle,
      ),
      child: Icon(
        Icons.car_rental_rounded,
        color: widget.isRead ? Colors.grey[600] : Colors.white,
        size: 24,
      ),
    );
  }
}

