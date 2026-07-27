import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/services/admin_service.dart';
import '../../../core/widgets/admin_layout.dart';
import '../../routes/app_routes.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final AdminService _adminService = AdminService();
  Map<String, dynamic> _stats = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    setState(() => _isLoading = true);
    final stats = await _adminService.getDashboardStats();
    setState(() {
      _stats = stats;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AdminLayout(
      currentRoute: AppRoutes.dashboard,
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh_rounded),
          tooltip: 'Refresh',
          onPressed: _loadStats,
        ),
      ],
      child: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadStats,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                const Color(0xFF6366F1).withOpacity(0.15),
                                const Color(0xFF8B5CF6).withOpacity(0.15),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.analytics_rounded,
                            color: Color(0xFF6366F1),
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Text(
                          'Statistics Overview',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFF1E293B),
                                letterSpacing: -0.5,
                              ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 28),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final crossAxisCount = constraints.maxWidth > 1200 ? 4 : constraints.maxWidth > 800 ? 3 : 2;
                        return GridView.count(
                          crossAxisCount: crossAxisCount,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: 2.1,
                          children: [
                        _StatCard(
                          title: 'Total Users',
                          value: '${_stats['totalUsers'] ?? 0}',
                          icon: Icons.people_rounded,
                          gradient: const [Color(0xFF3B82F6), Color(0xFF2563EB)],
                          onTap: () => Get.toNamed(AppRoutes.users),
                        ),
                        _StatCard(
                          title: 'Total Cars',
                          value: '${_stats['totalCars'] ?? 0}',
                          icon: Icons.directions_car_rounded,
                          gradient: const [Color(0xFF10B981), Color(0xFF059669)],
                          onTap: () => Get.toNamed(AppRoutes.cars),
                        ),
                        _StatCard(
                          title: 'Available Cars',
                          value: '${_stats['availableCars'] ?? 0}',
                          icon: Icons.check_circle_rounded,
                          gradient: const [Color(0xFF14B8A6), Color(0xFF0D9488)],
                          onTap: () => Get.toNamed(AppRoutes.cars),
                        ),
                        _StatCard(
                          title: 'Sold Cars',
                          value: '${_stats['soldCars'] ?? 0}',
                          icon: Icons.sell_rounded,
                          gradient: const [Color(0xFFF59E0B), Color(0xFFD97706)],
                          onTap: () => Get.toNamed(AppRoutes.cars),
                        ),
                        _StatCard(
                          title: 'Pending KYC',
                          value: '${_stats['pendingKyc'] ?? 0}',
                          icon: Icons.pending_rounded,
                          gradient: const [Color(0xFFEF4444), Color(0xFFDC2626)],
                          onTap: () => Get.toNamed(AppRoutes.kyc),
                        ),
                        _StatCard(
                          title: 'Verified KYC',
                          value: '${_stats['verifiedKyc'] ?? 0}',
                          icon: Icons.verified_rounded,
                          gradient: const [Color(0xFF8B5CF6), Color(0xFF7C3AED)],
                          onTap: () => Get.toNamed(AppRoutes.kyc),
                        ),
                        _StatCard(
                          title: 'Car Enquiries',
                          value: '${_stats['unreadEnquiries'] ?? 0}',
                          icon: Icons.notifications_rounded,
                          gradient: const [Color(0xFFEC4899), Color(0xFFDB2777)],
                          onTap: () => Get.toNamed(AppRoutes.notifications),
                          badge: _stats['unreadEnquiries'] != null && (_stats['unreadEnquiries'] as int) > 0,
                        ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
    );
  }

}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final List<Color> gradient;
  final VoidCallback? onTap;
  final bool badge;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.gradient,
    this.onTap,
    this.badge = false,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: gradient,
            ),
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: gradient[0].withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
                spreadRadius: 0,
              ),
            ],
          ),
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(18),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            value,
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.white.withOpacity(0.95),
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.25),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Icon(icon, size: 24, color: Colors.white),
                    ),
                    if (onTap != null) ...[
                      const SizedBox(width: 10),
                      Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 18,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
              if (badge)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

