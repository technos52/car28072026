import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../core/services/admin_service.dart';
import '../../../core/widgets/admin_layout.dart';
import '../../routes/app_routes.dart';

class UsersPage extends StatefulWidget {
  const UsersPage({super.key});

  @override
  State<UsersPage> createState() => _UsersPageState();
}

class _UsersPageState extends State<UsersPage> {
  final AdminService _adminService = AdminService();
  List<Map<String, dynamic>> _users = [];
  bool _isLoading = true;
  String _searchQuery = '';
  String _filterTab = 'all'; // 'all', 'completed', 'pending'

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    setState(() => _isLoading = true);
    final users = await _adminService.getAllUsers();
    setState(() {
      _users = users;
      _isLoading = false;
    });
  }

  int get _completedCount =>
      _users.where((u) => u['isProfileComplete'] == true).length;
  int get _pendingCount =>
      _users.where((u) => u['isProfileComplete'] != true).length;

  List<Map<String, dynamic>> get _filteredUsers {
    var list = _users;

    if (_filterTab == 'completed') {
      list = list.where((u) => u['isProfileComplete'] == true).toList();
    } else if (_filterTab == 'pending') {
      list = list.where((u) => u['isProfileComplete'] != true).toList();
    }

    if (_searchQuery.isEmpty) return list;
    return list.where((user) {
      final name = (user['name'] ?? '').toString().toLowerCase();
      final email = (user['email'] ?? '').toString().toLowerCase();
      final phone = (user['phone'] ?? '').toString().toLowerCase();
      final shopName = (user['shopName'] ?? '').toString().toLowerCase();
      final query = _searchQuery.toLowerCase();
      return name.contains(query) ||
          email.contains(query) ||
          phone.contains(query) ||
          shopName.contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return AdminLayout(
      currentRoute: AppRoutes.users,
      title: 'Users Management',
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh_rounded),
          tooltip: 'Refresh',
          onPressed: _loadUsers,
        ),
      ],
      child: Column(
        children: [
          // Filter Tabs (All / Completed / Pending)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            color: Colors.white,
            child: Row(
              children: [
                _buildFilterTab(
                  label: 'All Users',
                  count: _users.length,
                  value: 'all',
                  color: const Color(0xFF6366F1),
                ),
                const SizedBox(width: 12),
                _buildFilterTab(
                  label: 'Completed Profiles',
                  count: _completedCount,
                  value: 'completed',
                  color: Colors.green,
                ),
                const SizedBox(width: 12),
                _buildFilterTab(
                  label: 'Pending Profiles',
                  count: _pendingCount,
                  value: 'pending',
                  color: Colors.orange,
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFE2E8F0)),

          // Search Field
          Container(
            margin: const EdgeInsets.all(20),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search by name, email, phone, or dealer name',
                prefixIcon: const Icon(Icons.search_rounded, size: 22),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: Colors.grey.shade200, width: 1.5),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: Colors.grey.shade200, width: 1.5),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: Color(0xFF6366F1), width: 2.5),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
              ),
              onChanged: (value) {
                setState(() => _searchQuery = value);
              },
            ),
          ),

          // Users List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredUsers.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.people_outline_rounded,
                              size: 64,
                              color: Colors.grey.shade400,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _searchQuery.isEmpty
                                  ? 'No users found in this filter'
                                  : 'No users match your search',
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemCount: _filteredUsers.length,
                        itemBuilder: (context, index) {
                          final user = _filteredUsers[index];
                          final bool isComplete = user['isProfileComplete'] == true;
                          final String userName = user['name']?.toString().isNotEmpty == true
                              ? user['name']
                              : user['displayName']?.toString().isNotEmpty == true
                                  ? user['displayName']
                                  : 'User ID: ${(user['id'] as String).substring(0, 8)}...';

                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isComplete
                                    ? Colors.grey.shade100
                                    : Colors.orange.withOpacity(0.3),
                                width: isComplete ? 1 : 1.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.04),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () {
                                  Get.toNamed(
                                    AppRoutes.userDetail.replaceAll(':id', user['id']),
                                  );
                                },
                                borderRadius: BorderRadius.circular(16),
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Row(
                                    children: [
                                      // User Avatar
                                      Container(
                                        width: 56,
                                        height: 56,
                                        decoration: BoxDecoration(
                                          color: (isComplete ? const Color(0xFF6366F1) : Colors.orange)
                                              .withOpacity(0.1),
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: (isComplete ? const Color(0xFF6366F1) : Colors.orange)
                                                .withOpacity(0.3),
                                            width: 2,
                                          ),
                                        ),
                                        child: Builder(
                                          builder: (context) {
                                            final String? url = user['avatarUrl']?.toString().isNotEmpty == true
                                                ? user['avatarUrl']
                                                : user['photoUrl']?.toString().isNotEmpty == true
                                                    ? user['photoUrl']
                                                    : user['photoURL']?.toString().isNotEmpty == true
                                                        ? user['photoURL']
                                                        : user['profileImageUrl']?.toString().isNotEmpty == true
                                                            ? user['profileImageUrl']
                                                            : null;

                                            if (url != null && url.isNotEmpty) {
                                              return ClipOval(
                                                child: Image.network(
                                                  url,
                                                  fit: BoxFit.cover,
                                                  errorBuilder: (context, error, stackTrace) =>
                                                      Icon(
                                                    Icons.person_rounded,
                                                    color: isComplete ? const Color(0xFF6366F1) : Colors.orange,
                                                    size: 28,
                                                  ),
                                                ),
                                              );
                                            }
                                            return Icon(
                                              Icons.person_rounded,
                                              color: isComplete ? const Color(0xFF6366F1) : Colors.orange,
                                              size: 28,
                                            );
                                          },
                                        ),
                                      ),
                                      const SizedBox(width: 16),

                                      // User Details / Status
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    userName,
                                                    style: const TextStyle(
                                                      fontWeight: FontWeight.w700,
                                                      fontSize: 16,
                                                      color: Color(0xFF1E293B),
                                                      letterSpacing: -0.2,
                                                    ),
                                                  ),
                                                ),
                                                // Status Badge
                                                Container(
                                                  padding: const EdgeInsets.symmetric(
                                                      horizontal: 10, vertical: 4),
                                                  decoration: BoxDecoration(
                                                    color: isComplete
                                                        ? Colors.green.withOpacity(0.1)
                                                        : Colors.orange.withOpacity(0.1),
                                                    borderRadius: BorderRadius.circular(20),
                                                    border: Border.all(
                                                      color: isComplete
                                                          ? Colors.green.withOpacity(0.3)
                                                          : Colors.orange.withOpacity(0.3),
                                                    ),
                                                  ),
                                                  child: Row(
                                                    mainAxisSize: MainAxisSize.min,
                                                    children: [
                                                      Icon(
                                                        isComplete
                                                            ? Icons.check_circle_rounded
                                                            : Icons.pending_actions_rounded,
                                                        size: 13,
                                                        color: isComplete ? Colors.green : Colors.orange,
                                                      ),
                                                      const SizedBox(width: 4),
                                                      Text(
                                                        isComplete
                                                            ? 'Profile Complete'
                                                            : 'Profile creation pending by user',
                                                        style: TextStyle(
                                                          fontSize: 12,
                                                          fontWeight: FontWeight.w600,
                                                          color: isComplete
                                                              ? Colors.green.shade800
                                                              : Colors.orange.shade800,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 6),

                                            if (user['shopName'] != null &&
                                                user['shopName'].toString().isNotEmpty) ...[
                                              Row(
                                                children: [
                                                  Icon(
                                                    Icons.storefront_rounded,
                                                    size: 14,
                                                    color: Colors.indigo.shade400,
                                                  ),
                                                  const SizedBox(width: 6),
                                                  Text(
                                                    user['shopName'],
                                                    style: TextStyle(
                                                      color: Colors.indigo.shade700,
                                                      fontSize: 13,
                                                      fontWeight: FontWeight.w600,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 4),
                                            ],

                                            if (user['email'] != null &&
                                                user['email'].toString().isNotEmpty)
                                              Row(
                                                children: [
                                                  Icon(
                                                    Icons.email_outlined,
                                                    size: 14,
                                                    color: Colors.grey.shade500,
                                                  ),
                                                  const SizedBox(width: 6),
                                                  Expanded(
                                                    child: Text(
                                                      user['email'],
                                                      style: TextStyle(
                                                        color: Colors.grey.shade600,
                                                        fontSize: 13,
                                                        fontWeight: FontWeight.w500,
                                                      ),
                                                      overflow: TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                ],
                                              ),

                                            if (user['phone'] != null &&
                                                user['phone'].toString().isNotEmpty) ...[
                                              const SizedBox(height: 4),
                                              Row(
                                                children: [
                                                  Icon(
                                                    Icons.phone_outlined,
                                                    size: 14,
                                                    color: Colors.grey.shade500,
                                                  ),
                                                  const SizedBox(width: 6),
                                                  Text(
                                                    user['phone'],
                                                    style: TextStyle(
                                                      color: Colors.grey.shade600,
                                                      fontSize: 13,
                                                      fontWeight: FontWeight.w500,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF6366F1).withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: const Icon(
                                          Icons.chevron_right_rounded,
                                          color: Color(0xFF6366F1),
                                          size: 20,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterTab({
    required String label,
    required int count,
    required String value,
    required Color color,
  }) {
    final bool isSelected = _filterTab == value;
    return InkWell(
      onTap: () => setState(() => _filterTab = value),
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? color : color.withOpacity(0.06),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : color.withOpacity(0.2),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Text(
              label,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                fontSize: 13,
                color: isSelected ? Colors.white : color.withOpacity(0.9),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: isSelected
                    ? Colors.white.withOpacity(0.25)
                    : color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '$count',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  color: isSelected ? Colors.white : color,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

