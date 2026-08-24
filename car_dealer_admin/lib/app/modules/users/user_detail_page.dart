import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:html' as html;
import 'dart:ui_web' as ui_web;
import '../../../core/services/admin_service.dart';
import '../../../core/widgets/admin_layout.dart';
import '../../routes/app_routes.dart';

class UserDetailPage extends StatefulWidget {
  const UserDetailPage({super.key});

  @override
  State<UserDetailPage> createState() => _UserDetailPageState();
}

class _UserDetailPageState extends State<UserDetailPage> {
  final AdminService _adminService = AdminService();
  final String _userId = Get.parameters['id'] ?? '';
  Map<String, dynamic>? _user;
  List<Map<String, dynamic>> _shops = [];
  List<Map<String, dynamic>> _cars = [];
  Map<String, dynamic>? _kyc;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  String? _getCarImage(Map<String, dynamic> car) {
    if (car['imageUrl'] != null && car['imageUrl'].toString().isNotEmpty) return car['imageUrl'];
    if (car['imageUrls'] is List && (car['imageUrls'] as List).isNotEmpty) return (car['imageUrls'] as List).first.toString();
    if (car['imagePaths'] is List && (car['imagePaths'] as List).isNotEmpty) return (car['imagePaths'] as List).first.toString();
    return null;
  }

  String _getShopName(Map<String, dynamic> car) {
    if (car['shopName']?.toString().isNotEmpty == true) return car['shopName'];
    if (car['sellerName']?.toString().isNotEmpty == true) return car['sellerName'];
    if (_shops.isNotEmpty && _shops.first['shopName']?.toString().isNotEmpty == true) return _shops.first['shopName'];
    return _user?['name'] ?? _user?['displayName'] ?? 'Unknown Shop';
  }

  String? _getDocumentValue(String type) {
    if (_kyc == null) return null;
    final urlVal = _kyc!['${type}Url'] ?? _kyc!['${type}URL'] ?? _kyc!['${type}ImageUrl'];
    if (urlVal != null && urlVal.toString().isNotEmpty) return urlVal.toString();
    final pathVal = _kyc!['${type}Path'];
    if (pathVal != null && pathVal.toString().isNotEmpty) return pathVal.toString();
    return null;
  }


  Future<void> _loadUserData() async {
    setState(() => _isLoading = true);
    try {
      final user = await _adminService.getUser(_userId);
      final shops = await _adminService.getUserShops(_userId);
      final cars = await _adminService.getUserCars(_userId);
      final kyc = await _adminService.getKycDocument(_userId);
      setState(() {
        _user = user;
        _shops = shops;
        _cars = cars;
        _kyc = kyc;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      Get.snackbar('Error', 'Failed to load user data: $e',
          backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  Future<void> _deleteUser() async {
    final confirm = await Get.dialog<bool>(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.red),
            SizedBox(width: 12),
            Text('Delete User'),
          ],
        ),
        content: const Text(
          'Are you sure you want to delete this user? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirm == true) {
      try {
        Get.dialog(
          const Center(child: CircularProgressIndicator()),
          barrierDismissible: false,
        );
        await _adminService.deleteUser(_userId);
        Get.back();
        Get.snackbar('Success', 'User deleted successfully',
            backgroundColor: Colors.green, colorText: Colors.white);
        Get.back();
      } catch (e) {
        Get.back();
        Get.snackbar('Error', 'Failed to delete user: $e',
            backgroundColor: Colors.red, colorText: Colors.white);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AdminLayout(
      currentRoute: AppRoutes.users,
      title: 'User Details',
      actions: [
        IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF6366F1).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.message_rounded,
                color: Color(0xFF6366F1), size: 20),
          ),
          tooltip: 'Send Message',
          onPressed: () {
            Get.toNamed(
              AppRoutes.sendMessage,
              parameters: {
                'userId': _userId,
                'userName': _user?['name'] ?? 'User',
              },
            );
          },
        ),
        IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.delete_rounded, color: Colors.red, size: 20),
          ),
          tooltip: 'Delete User',
          onPressed: _deleteUser,
        ),
        const SizedBox(width: 8),
      ],
      child: Container(
        color: Colors.grey.shade50,
        child: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _user == null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.person_off_rounded,
                          size: 64, color: Colors.grey.shade400),
                      const SizedBox(height: 16),
                      Text('User not found',
                          style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey.shade600,
                              fontWeight: FontWeight.w500)),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadUserData,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildUserProfileCard(),
                        const SizedBox(height: 24),
                        _buildStatsRow(),
                        const SizedBox(height: 24),
                        _buildKycSection(),
                        const SizedBox(height: 24),
                        _buildShopsSection(),
                        const SizedBox(height: 24),
                        _buildCarsSection(),
                      ],
                    ),
                  ),
                ),
      ),
    );
  }

  Widget _buildUserProfileCard() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white,
              const Color(0xFF6366F1).withOpacity(0.05),
            ],
          ),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFF6366F1),
                      width: 3,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF6366F1).withOpacity(0.3),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: CircleAvatar(
                    radius: 50,
                    backgroundColor: const Color(0xFF6366F1).withOpacity(0.1),
                    child: Builder(
                      builder: (context) {
                        final String? url = _user!['avatarUrl']?.toString().isNotEmpty == true 
                            ? _user!['avatarUrl'] 
                            : _user!['photoUrl']?.toString().isNotEmpty == true 
                                ? _user!['photoUrl'] 
                                : _user!['photoURL']?.toString().isNotEmpty == true
                                    ? _user!['photoURL']
                                    : _user!['profileImageUrl']?.toString().isNotEmpty == true 
                                        ? _user!['profileImageUrl'] 
                                        : null;
                        
                        if (url != null && url.isNotEmpty) {
                          return ClipOval(
                            child: Image.network(
                              url,
                              fit: BoxFit.cover,
                              width: 100,
                              height: 100,
                              errorBuilder: (context, error, stackTrace) =>
                                  const Icon(Icons.person_rounded,
                                      size: 50, color: Color(0xFF6366F1)),
                            ),
                          );
                        }
                        return const Icon(Icons.person_rounded, size: 50, color: Color(0xFF6366F1));
                      },
                    ),
                  ),
                ),
                if (_kyc?['isVerified'] == true)
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.verified_rounded,
                          color: Colors.white, size: 20),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              _user!['name'] ?? 'Unknown',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 16,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: [
                if (_user!['email'] != null)
                  _buildInfoChip(
                    Icons.email_rounded,
                    _user!['email'],
                    Colors.blue,
                  ),
                if (_user!['phone'] != null)
                  _buildInfoChip(
                    Icons.phone_rounded,
                    _user!['phone'],
                    Colors.green,
                  ),
                if (_user!['gender'] != null)
                  _buildInfoChip(
                    Icons.person_outline_rounded,
                    _user!['gender'],
                    Colors.purple,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
            Text(
              text,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: color,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStatsRow() {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'Shops',
            _shops.length.toString(),
            Icons.store_rounded,
            Colors.blue,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'Cars',
            _cars.length.toString(),
            Icons.directions_car_rounded,
            Colors.orange,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'KYC',
            _kyc?['isVerified'] == true ? 'Verified' : 'Pending',
            _kyc?['isVerified'] == true
                ? Icons.verified_rounded
                : Icons.pending_rounded,
            _kyc?['isVerified'] == true ? Colors.green : Colors.orange,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKycSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.purple.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.verified_user_rounded,
                  color: Colors.purple, size: 20),
            ),
            const SizedBox(width: 12),
            const Text(
              'KYC Verification',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (_kyc == null)
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: Colors.grey.shade200),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Center(
                child: Column(
                  children: [
                    Icon(Icons.description_outlined,
                        size: 48, color: Colors.grey.shade400),
                    const SizedBox(height: 12),
                    Text('No KYC documents found',
                        style: TextStyle(
                            fontSize: 16, color: Colors.grey.shade600)),
                  ],
                ),
              ),
            ),
          )
        else
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: Colors.grey.shade200),
            ),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: _kyc!['isVerified'] == true
                    ? Colors.green.withOpacity(0.05)
                    : Colors.orange.withOpacity(0.05),
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: (_kyc!['isVerified'] == true
                                  ? Colors.green
                                  : Colors.orange)
                              .withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          _kyc!['isVerified'] == true
                              ? Icons.verified_rounded
                              : Icons.pending_rounded,
                          color: _kyc!['isVerified'] == true
                              ? Colors.green
                              : Colors.orange,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _kyc!['isVerified'] == true
                                  ? 'Verified'
                                  : 'Pending Verification',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: _kyc!['isVerified'] == true
                                    ? Colors.green.shade800
                                    : Colors.orange.shade800,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _kyc!['isVerified'] == true
                                  ? 'All documents verified'
                                  : 'Awaiting admin verification',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        if (_getDocumentValue('pan') != null)
                          _buildDocumentBadge('PAN', Colors.blue, _getDocumentValue('pan')!),
                        if (_getDocumentValue('aadhaar') != null)
                          _buildDocumentBadge('Aadhaar', Colors.green, _getDocumentValue('aadhaar')!),
                        if (_getDocumentValue('addressProof') != null)
                          _buildDocumentBadge('Address', Colors.purple, _getDocumentValue('addressProof')!),
                      ],
                    ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildDocumentBadge(String label, Color color, String url) {
    return InkWell(
      onTap: () => _showDocumentDialog(label, url),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check_circle_rounded, size: 14, color: color),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDocumentDialog(String title, String imagePathOrUrl) async {
    String? resolvedUrl;
    Get.dialog(const Center(child: CircularProgressIndicator()), barrierDismissible: false);

    try {
      if (imagePathOrUrl.startsWith('http')) {
        resolvedUrl = imagePathOrUrl;
      } else if (imagePathOrUrl.startsWith('gs://')) {
        resolvedUrl = await FirebaseStorage.instance.refFromURL(imagePathOrUrl).getDownloadURL();
      } else {
        resolvedUrl = await FirebaseStorage.instance.ref(imagePathOrUrl).getDownloadURL();
      }
    } catch (e) {
      debugPrint('Error resolving document URL: $e');
    }

    if (Get.isDialogOpen == true) Get.back();

    if (resolvedUrl == null) {
      Get.snackbar('Error', 'Could not load the document.', backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('$title Document', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  IconButton(icon: const Icon(Icons.close), onPressed: () => Get.back()),
                ],
              ),
            ),
            Flexible(
              child: WebDocumentViewer(url: resolvedUrl),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _showCarDetails(Map<String, dynamic> car) {
    final excludedKeys = ['id', 'userid', 'shopid', 'createdat', 'updatedat', 'timestamp', 'sellername', 'shopname', 'isavailable'];
    
    final specs = car.entries.where((e) {
      final key = e.key.toLowerCase();
      if (excludedKeys.contains(key)) return false;
      if (key.contains('image') || key.contains('url') || key.contains('path')) return false;
      if (key.contains('time') || key.contains('date')) return false;
      if (e.value == null || e.value.toString().trim().isEmpty) return false;
      return true;
    }).toList();

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          width: 500,
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      '${car['make'] ?? ''} ${car['model'] ?? ''} - ${_getShopName(car)}'.trim().toUpperCase(),
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                    ),
                  ),
                  IconButton(icon: const Icon(Icons.close_rounded, color: Colors.grey), onPressed: () => Get.back(), padding: EdgeInsets.zero, constraints: const BoxConstraints()),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  if (car['year'] != null)
                    Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), decoration: BoxDecoration(color: Colors.blue.withOpacity(0.1), borderRadius: BorderRadius.circular(8)), child: Text('${car['year']}', style: TextStyle(color: Colors.blue.shade700, fontWeight: FontWeight.bold))),
                  const SizedBox(width: 8),
                  if (car['price'] != null)
                    Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), decoration: BoxDecoration(color: Colors.green.withOpacity(0.1), borderRadius: BorderRadius.circular(8)), child: Text('₹${car['price']}', style: TextStyle(color: Colors.green.shade700, fontWeight: FontWeight.bold))),
                ],
              ),
              const SizedBox(height: 24),
              const Text('Vehicle Specifications', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF64748B))),
              const SizedBox(height: 16),
              Flexible(
                child: SingleChildScrollView(
                  child: Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: specs.map((e) {
                      String formattedKey = e.key.replaceAll(RegExp(r'(?<=[a-z])(?=[A-Z])'), ' ');
                      formattedKey = formattedKey[0].toUpperCase() + formattedKey.substring(1);
                      return Container(
                        width: 200,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade200)),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(formattedKey, style: TextStyle(fontSize: 12, color: Colors.grey.shade500, fontWeight: FontWeight.w600)),
                            const SizedBox(height: 4),
                            Text('${e.value}', style: const TextStyle(fontSize: 14, color: Color(0xFF334155), fontWeight: FontWeight.w500)),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String? _getShopImage(Map<String, dynamic> shop) {
    if (shop['logoUrl'] != null && shop['logoUrl'].toString().isNotEmpty) return shop['logoUrl'];
    if (shop['imageUrl'] != null && shop['imageUrl'].toString().isNotEmpty) return shop['imageUrl'];
    if (shop['shopImageUrl'] != null && shop['shopImageUrl'].toString().isNotEmpty) return shop['shopImageUrl'];
    if (shop['image'] != null && shop['image'].toString().isNotEmpty) return shop['image'];
    return null;
  }

  Widget _buildShopsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.store_rounded, color: Colors.blue, size: 20),
            ),
            const SizedBox(width: 12),
            Text(
              'Shops (${_shops.length})',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (_shops.isEmpty)
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: Colors.grey.shade200),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Center(
                child: Column(
                  children: [
                    Icon(Icons.store_outlined,
                        size: 48, color: Colors.grey.shade400),
                    const SizedBox(height: 12),
                    Text('No shops found',
                        style: TextStyle(
                            fontSize: 16, color: Colors.grey.shade600)),
                  ],
                ),
              ),
            ),
          )
        else
          ..._shops.map((shop) {
            return Card(
              elevation: 0,
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: Colors.grey.shade200),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.blue.withOpacity(0.2)),
                          ),
                          child: _getShopImage(shop) != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: WebImageViewer(
                                    url: _getShopImage(shop)!,
                                  ),
                                )
                              : const Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.broken_image_rounded, color: Colors.blue, size: 28),
                                    SizedBox(height: 4),
                                    Text('No Image', style: TextStyle(fontSize: 10, color: Colors.blue)),
                                  ],
                                ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                shop['shopName'] ?? 'Unnamed Shop',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1E293B),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(Icons.calendar_today_rounded, size: 14, color: Colors.grey.shade500),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Joined: ${shop['createdAt'] != null ? shop['createdAt'].toString().split(' ')[0] : 'Unknown'}',
                                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    const Divider(),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 16,
                      runSpacing: 16,
                      children: [
                        SizedBox(
                          width: 200,
                          child: _buildInfoRow(Icons.person_rounded, 'Owner', shop['ownerName'] ?? 'N/A', Colors.purple),
                        ),
                        SizedBox(
                          width: 200,
                          child: _buildInfoRow(Icons.phone_rounded, 'Phone', shop['phone'] ?? 'N/A', Colors.green),
                        ),
                        SizedBox(
                          width: 200,
                          child: _buildInfoRow(Icons.email_rounded, 'Email', shop['email'] ?? 'N/A', Colors.blue),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildInfoRow(Icons.location_on_rounded, 'Address', shop['address'] ?? 'N/A', Colors.red),
                    const SizedBox(height: 8),
                    _buildInfoRow(
                        Icons.pin_drop_rounded,
                        'Location',
                        '${shop['city'] ?? ''}, ${shop['state'] ?? ''} - ${shop['pincode'] ?? ''}',
                        Colors.orange),
                    if (shop['description'] != null && shop['description'].toString().isNotEmpty) ...[
                      const SizedBox(height: 12),
                      const Divider(),
                      const SizedBox(height: 12),
                      const Text('Description', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                      const SizedBox(height: 4),
                      Text(shop['description'], style: const TextStyle(fontSize: 14)),
                    ]
                  ],
                ),
              ),
            );
          }),
      ],
    );
  }

  Widget _buildCarsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.directions_car_rounded,
                  color: Colors.orange, size: 20),
            ),
            const SizedBox(width: 12),
            Text(
              'Cars (${_cars.length})',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (_cars.isEmpty)
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: Colors.grey.shade200),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Center(
                child: Column(
                  children: [
                    Icon(Icons.directions_car_outlined,
                        size: 48, color: Colors.grey.shade400),
                    const SizedBox(height: 12),
                    Text('No cars found',
                        style: TextStyle(
                            fontSize: 16, color: Colors.grey.shade600)),
                  ],
                ),
              ),
            ),
          )
        else
          ..._cars.map((car) => Card(
                elevation: 0,
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: Colors.grey.shade200),
                ),
                child: InkWell(
                  onTap: () => _showCarDetails(car),
                  borderRadius: BorderRadius.circular(16),
                  child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: Colors.grey.shade200,
                        ),
                        child: _getCarImage(car) != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.network(
                                  _getCarImage(car)!,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      const Icon(Icons.directions_car_rounded,
                                          size: 40, color: Colors.grey),
                                ),
                              )
                            : const Icon(Icons.directions_car_rounded,
                                size: 40, color: Colors.grey),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${car['make'] ?? ''} ${car['model'] ?? ''} - ${_getShopName(car)}',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1E293B),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                _buildCarInfoChip(
                                    Icons.calendar_today_rounded,
                                    '${car['year'] ?? 'N/A'}',
                                    Colors.blue),
                                const SizedBox(width: 8),
                                _buildCarInfoChip(
                                    Icons.currency_rupee_rounded,
                                    '${car['price'] ?? '0'}',
                                    Colors.green),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: (car['isAvailable'] == true
                                        ? Colors.green
                                        : Colors.red)
                                    .withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: (car['isAvailable'] == true
                                          ? Colors.green
                                          : Colors.red)
                                      .withOpacity(0.3),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    car['isAvailable'] == true
                                        ? Icons.check_circle_rounded
                                        : Icons.cancel_rounded,
                                    size: 14,
                                    color: car['isAvailable'] == true
                                        ? Colors.green
                                        : Colors.red,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    car['isAvailable'] == true
                                        ? 'Available'
                                        : 'Sold',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: car['isAvailable'] == true
                                          ? Colors.green.shade800
                                          : Colors.red.shade800,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ))),
      ],
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value, Color color) {
    return Row(
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w500,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1E293B),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCarInfoChip(IconData icon, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class WebDocumentViewer extends StatelessWidget {
  final String url;

  WebDocumentViewer({super.key, required this.url}) {
    final viewId = 'doc-view-${url.hashCode}';
    
    // Register the factory only once per URL
    ui_web.platformViewRegistry.registerViewFactory(
      viewId,
      (int id) {
        if (url.toLowerCase().contains('.pdf')) {
          return html.IFrameElement()
            ..src = url
            ..style.border = 'none'
            ..style.width = '100%'
            ..style.height = '100%';
        } else {
          return html.ImageElement()
            ..src = url
            ..style.width = '100%'
            ..style.height = '100%'
            ..style.objectFit = 'contain';
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return HtmlElementView(viewType: 'doc-view-${url.hashCode}');
  }
}

final Set<String> _registeredImageViews = {};

class WebImageViewer extends StatelessWidget {
  final String url;

  WebImageViewer({super.key, required this.url}) {
    final viewId = 'img-view-${url.hashCode}';
    if (!_registeredImageViews.contains(viewId)) {
      ui_web.platformViewRegistry.registerViewFactory(
        viewId,
        (int id) {
          return html.ImageElement()
            ..src = url
            ..style.width = '100%'
            ..style.height = '100%'
            ..style.objectFit = 'cover'
            ..style.border = 'none';
        },
      );
      _registeredImageViews.add(viewId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return HtmlElementView(viewType: 'img-view-${url.hashCode}');
  }
}
