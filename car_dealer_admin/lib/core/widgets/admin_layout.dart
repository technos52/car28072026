import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/services/auth_service.dart';
import '../../app/routes/app_routes.dart';

class AdminLayout extends StatelessWidget {
  final Widget child;
  final String currentRoute;
  final String? title;
  final List<Widget>? actions;

  const AdminLayout({
    super.key,
    required this.child,
    required this.currentRoute,
    this.title,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    final authService = Get.find<AuthService>();
    final isDesktop = MediaQuery.of(context).size.width >= 1024;

    if (isDesktop) {
      return Scaffold(
        body: Row(
          children: [
            _buildSidePanel(context, authService),
            Expanded(
              child: Column(
                children: [
                  _buildAppBar(context, authService),
                  Expanded(child: child),
                ],
              ),
            ),
          ],
        ),
      );
    } else {
      return Scaffold(
        appBar: _buildAppBar(context, authService),
        drawer: _buildDrawer(context, authService),
        body: child,
      );
    }
  }

  Widget _buildSidePanel(BuildContext context, AuthService authService) {
    return Container(
      width: 280,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          right: BorderSide(
            color: Colors.grey.shade100,
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(2, 0),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFF6366F1),
                  const Color(0xFF8B5CF6),
                  const Color(0xFFA855F7),
                ],
                stops: const [0.0, 0.5, 1.0],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.25),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.admin_panel_settings_rounded,
                    size: 36,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Admin Panel',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Car Dealer Management',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.95),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.2,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: [
                _SidePanelTile(
                  icon: Icons.dashboard_rounded,
                  title: 'Dashboard',
                  isSelected: currentRoute == AppRoutes.dashboard,
                  onTap: () {
                    if (currentRoute != AppRoutes.dashboard) {
                      Get.offNamed(AppRoutes.dashboard);
                    }
                  },
                ),
                _SidePanelTile(
                  icon: Icons.people_rounded,
                  title: 'Users',
                  isSelected: currentRoute == AppRoutes.users,
                  onTap: () {
                    if (currentRoute != AppRoutes.users) {
                      Get.toNamed(AppRoutes.users);
                    }
                  },
                ),
                _SidePanelTile(
                  icon: Icons.directions_car_rounded,
                  title: 'Cars',
                  isSelected: currentRoute == AppRoutes.cars,
                  onTap: () {
                    if (currentRoute != AppRoutes.cars) {
                      Get.toNamed(AppRoutes.cars);
                    }
                  },
                ),
                _SidePanelTile(
                  icon: Icons.verified_user_rounded,
                  title: 'KYC Verification',
                  isSelected: currentRoute == AppRoutes.kyc,
                  onTap: () {
                    if (currentRoute != AppRoutes.kyc) {
                      Get.toNamed(AppRoutes.kyc);
                    }
                  },
                ),
                _SidePanelTile(
                  icon: Icons.admin_panel_settings_rounded,
                  title: 'Manage Admins',
                  isSelected: currentRoute == AppRoutes.admins,
                  onTap: () {
                    if (currentRoute != AppRoutes.admins) {
                      Get.toNamed(AppRoutes.admins);
                    }
                  },
                ),
                _SidePanelTile(
                  icon: Icons.image_rounded,
                  title: 'Carousel Images',
                  isSelected: currentRoute == AppRoutes.carouselImages,
                  onTap: () {
                    if (currentRoute != AppRoutes.carouselImages) {
                      Get.toNamed(AppRoutes.carouselImages);
                    }
                  },
                ),
                _SidePanelTile(
                  icon: Icons.notifications_rounded,
                  title: 'Car Enquiries',
                  isSelected: currentRoute == AppRoutes.notifications,
                  onTap: () {
                    if (currentRoute != AppRoutes.notifications) {
                      Get.toNamed(AppRoutes.notifications);
                    }
                  },
                ),
                const Divider(height: 32),
                _SidePanelTile(
                  icon: Icons.logout_rounded,
                  title: 'Logout',
                  isDestructive: true,
                  onTap: () async {
                    await authService.signOut();
                    Get.offAllNamed(AppRoutes.login);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawer(BuildContext context, AuthService authService) {
    return Drawer(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFF6366F1),
                  const Color(0xFF8B5CF6),
                ],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.admin_panel_settings_rounded,
                    size: 32,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Admin Panel',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Car Dealer Management',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: [
                _SidePanelTile(
                  icon: Icons.dashboard_rounded,
                  title: 'Dashboard',
                  isSelected: currentRoute == AppRoutes.dashboard,
                  onTap: () {
                    Navigator.pop(context);
                    if (currentRoute != AppRoutes.dashboard) {
                      Get.offNamed(AppRoutes.dashboard);
                    }
                  },
                ),
                _SidePanelTile(
                  icon: Icons.people_rounded,
                  title: 'Users',
                  isSelected: currentRoute == AppRoutes.users,
                  onTap: () {
                    Navigator.pop(context);
                    if (currentRoute != AppRoutes.users) {
                      Get.toNamed(AppRoutes.users);
                    }
                  },
                ),
                _SidePanelTile(
                  icon: Icons.directions_car_rounded,
                  title: 'Cars',
                  isSelected: currentRoute == AppRoutes.cars,
                  onTap: () {
                    Navigator.pop(context);
                    if (currentRoute != AppRoutes.cars) {
                      Get.toNamed(AppRoutes.cars);
                    }
                  },
                ),
                _SidePanelTile(
                  icon: Icons.verified_user_rounded,
                  title: 'KYC Verification',
                  isSelected: currentRoute == AppRoutes.kyc,
                  onTap: () {
                    Navigator.pop(context);
                    if (currentRoute != AppRoutes.kyc) {
                      Get.toNamed(AppRoutes.kyc);
                    }
                  },
                ),
                _SidePanelTile(
                  icon: Icons.admin_panel_settings_rounded,
                  title: 'Manage Admins',
                  isSelected: currentRoute == AppRoutes.admins,
                  onTap: () {
                    Navigator.pop(context);
                    if (currentRoute != AppRoutes.admins) {
                      Get.toNamed(AppRoutes.admins);
                    }
                  },
                ),
                _SidePanelTile(
                  icon: Icons.image_rounded,
                  title: 'Carousel Images',
                  isSelected: currentRoute == AppRoutes.carouselImages,
                  onTap: () {
                    Navigator.pop(context);
                    if (currentRoute != AppRoutes.carouselImages) {
                      Get.toNamed(AppRoutes.carouselImages);
                    }
                  },
                ),
                _SidePanelTile(
                  icon: Icons.notifications_rounded,
                  title: 'Car Enquiries',
                  isSelected: currentRoute == AppRoutes.notifications,
                  onTap: () {
                    Navigator.pop(context);
                    if (currentRoute != AppRoutes.notifications) {
                      Get.toNamed(AppRoutes.notifications);
                    }
                  },
                ),
                const Divider(height: 32),
                _SidePanelTile(
                  icon: Icons.logout_rounded,
                  title: 'Logout',
                  isDestructive: true,
                  onTap: () async {
                    Navigator.pop(context);
                    await authService.signOut();
                    Get.offAllNamed(AppRoutes.login);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, AuthService authService) {
    return AppBar(
      title: title != null
          ? Text(title!)
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Dashboard'),
                const SizedBox(height: 2),
                Text(
                  'Welcome back, Admin',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: const Color(0xFF64748B),
                        fontWeight: FontWeight.w500,
                      ),
                ),
              ],
            ),
      actions: [
        ...?actions,
        Container(
          margin: const EdgeInsets.only(right: 8),
          child: Material(
            color: const Color(0xFF6366F1).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            child: InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: () {
                Get.toNamed(AppRoutes.sendMessage);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.send_rounded, color: Color(0xFF6366F1), size: 20),
                    const SizedBox(width: 6),
                    const Text(
                      'Send to All',
                      style: TextStyle(
                        color: Color(0xFF6366F1),
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.only(right: 8),
          child: PopupMenuButton(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF6366F1).withOpacity(0.1),
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0xFF6366F1).withOpacity(0.2),
                  width: 1.5,
                ),
              ),
              child: const Icon(
                Icons.person_rounded,
                color: Color(0xFF6366F1),
                size: 20,
              ),
            ),
            itemBuilder: (context) => [
              PopupMenuItem(
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.logout_rounded,
                        size: 18,
                        color: Colors.red,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Logout',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                onTap: () async {
                  await authService.signOut();
                  Get.offAllNamed(AppRoutes.login);
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SidePanelTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final bool isSelected;
  final bool isDestructive;

  const _SidePanelTile({
    required this.icon,
    required this.title,
    required this.onTap,
    this.isSelected = false,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: isSelected
            ? const Color(0xFF6366F1).withOpacity(0.12)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        border: isSelected
            ? Border.all(
                color: const Color(0xFF6366F1).withOpacity(0.2),
                width: 1,
              )
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isDestructive
                        ? Colors.red.withOpacity(0.1)
                        : isSelected
                            ? const Color(0xFF6366F1).withOpacity(0.15)
                            : const Color(0xFF64748B).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    icon,
                    size: 22,
                    color: isDestructive
                        ? Colors.red.shade600
                        : isSelected
                            ? const Color(0xFF6366F1)
                            : const Color(0xFF64748B),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      color: isDestructive
                          ? Colors.red.shade600
                          : isSelected
                              ? const Color(0xFF6366F1)
                              : const Color(0xFF1E293B),
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      fontSize: 15,
                      letterSpacing: 0.1,
                    ),
                  ),
                ),
                if (isSelected)
                  Container(
                    width: 4,
                    height: 24,
                    decoration: BoxDecoration(
                      color: const Color(0xFF6366F1),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

