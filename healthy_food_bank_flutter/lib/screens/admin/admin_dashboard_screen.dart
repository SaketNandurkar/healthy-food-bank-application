import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../config/theme.dart';
import '../../utils/premium_decorations.dart';
import '../../utils/premium_animations.dart';
import '../../providers/admin_dashboard_provider.dart';
import '../../providers/admin_navigation_provider.dart';

class AdminDashboardScreen extends ConsumerStatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  ConsumerState<AdminDashboardScreen> createState() =>
      _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends ConsumerState<AdminDashboardScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dashboardState = ref.watch(dashboardProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            PremiumHeader(
              title: 'Admin Dashboard',
              subtitle: 'System Overview',
              gradient: PremiumGradients.header(),
            ),
            Expanded(
              child: dashboardState.isLoading && dashboardState.stats == null
                  ? const Center(child: CircularProgressIndicator())
                  : dashboardState.error != null
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.error_outline,
                                  size: 48, color: AppColors.error),
                              const SizedBox(height: 16),
                              Text(
                                'Error loading dashboard',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                dashboardState.error!,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: () =>
                                    ref.read(dashboardProvider.notifier).refresh(),
                                child: const Text('Retry'),
                              ),
                            ],
                          ),
                        )
                      : RefreshIndicator(
                          onRefresh: _refresh,
                          color: AppColors.primary,
                          child: ListView(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  children: [
                    // Stats Grid
                    StaggeredListItem(
                      index: 0,
                      animation: _animationController,
                      child: _buildStatsGrid(),
                    ),
                    const SizedBox(height: AppSpacing.lg),

                    // Recent Activity Section
                    StaggeredListItem(
                      index: 1,
                      animation: _animationController,
                      child: _buildSectionHeader('Recent Activity'),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    StaggeredListItem(
                      index: 2,
                      animation: _animationController,
                      child: _buildRecentActivity(),
                    ),
                    const SizedBox(height: AppSpacing.lg),

                    // Quick Actions Section
                    StaggeredListItem(
                      index: 3,
                      animation: _animationController,
                      child: _buildSectionHeader('Quick Actions'),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    StaggeredListItem(
                      index: 4,
                      animation: _animationController,
                      child: _buildQuickActions(),
                    ),
                  ],
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsGrid() {
    final dashboardState = ref.watch(dashboardProvider);
    final stats = dashboardState.stats;

    if (stats == null) {
      return const SizedBox.shrink();
    }

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: AppSpacing.sm,
      crossAxisSpacing: AppSpacing.sm,
      childAspectRatio: 1.4,
      children: [
        _buildStatCard(
          icon: Icons.people_rounded,
          label: 'Total Users',
          value: '${stats.totalUsers}',
          color: AppColors.primary,
          gradient: PremiumGradients.primary(),
        ),
        _buildStatCard(
          icon: Icons.shopping_bag_rounded,
          label: 'Customers',
          value: '${stats.customers}',
          color: AppColors.info,
          gradient: PremiumGradients.info(),
        ),
        _buildStatCard(
          icon: Icons.store_rounded,
          label: 'Vendors',
          value: '${stats.vendors}',
          color: AppColors.success,
          gradient: PremiumGradients.success(),
        ),
        _buildStatCard(
          icon: Icons.check_circle_rounded,
          label: 'Active Users',
          value: '${stats.activeUsers}',
          color: AppColors.warning,
          gradient: PremiumGradients.warning(),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    required Gradient gradient,
  }) {
    return PressableScale(
      onTap: () {},
      child: Container(
        decoration: premiumCardDecoration().copyWith(gradient: gradient),
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.3),
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: Icon(icon, color: Colors.white, size: 24),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.9),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 20,
          decoration: BoxDecoration(
            gradient: PremiumGradients.primary(),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildRecentActivity() {
    final activities = [
      {'user': 'John Doe', 'action': 'registered as vendor', 'time': '5 min ago'},
      {'user': 'Admin', 'action': 'created new pickup point', 'time': '15 min ago'},
      {'user': 'Jane Smith', 'action': 'placed an order', 'time': '23 min ago'},
      {'user': 'Admin', 'action': 'approved vendor code', 'time': '1 hour ago'},
    ];

    return Container(
      decoration: premiumCardDecoration(),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: activities.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final activity = activities[index];
          return ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.xs,
            ),
            leading: CircleAvatar(
              backgroundColor: AppColors.primary.withOpacity(0.1),
              child: Text(
                activity['user']![0],
                style: const TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            title: RichText(
              text: TextSpan(
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textPrimary,
                ),
                children: [
                  TextSpan(
                    text: activity['user'],
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  TextSpan(text: ' ${activity['action']}'),
                ],
              ),
            ),
            trailing: Text(
              activity['time']!,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textHint,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildQuickActions() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 3,
      mainAxisSpacing: AppSpacing.sm,
      crossAxisSpacing: AppSpacing.sm,
      childAspectRatio: 1.0,
      children: [
        _buildActionButton(
          icon: Icons.person_add_rounded,
          label: 'Add User',
          onTap: _navigateToUsers,
        ),
        _buildActionButton(
          icon: Icons.qr_code_rounded,
          label: 'New Code',
          onTap: _navigateToVendorCodes,
        ),
        _buildActionButton(
          icon: Icons.location_on_rounded,
          label: 'Add Pickup',
          onTap: _navigateToPickupPoints,
        ),
        _buildActionButton(
          icon: Icons.people_rounded,
          label: 'View Users',
          onTap: _navigateToUsers,
        ),
        _buildActionButton(
          icon: Icons.analytics_rounded,
          label: 'Reports',
          onTap: _showReportsComingSoon,
        ),
        _buildActionButton(
          icon: Icons.settings_rounded,
          label: 'Settings',
          onTap: _navigateToProfile,
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return PressableScale(
      onTap: onTap,
      child: Container(
        decoration: premiumCardDecoration(),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: PremiumGradients.primary(),
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Icon(icon, color: Colors.white, size: 28),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _refresh() async {
    await ref.read(dashboardProvider.notifier).refresh();
  }

  // Navigation methods for Quick Actions
  void _navigateToUsers() {
    // Navigate to Users tab (index 1)
    ref.read(adminNavigationProvider.notifier).state = 1;
  }

  void _navigateToVendorCodes() {
    // Navigate to Vendor Codes tab (index 2)
    ref.read(adminNavigationProvider.notifier).state = 2;
  }

  void _navigateToPickupPoints() {
    // Navigate to Pickup Points tab (index 3)
    ref.read(adminNavigationProvider.notifier).state = 3;
  }

  void _navigateToProfile() {
    // Navigate to Profile tab (index 4)
    ref.read(adminNavigationProvider.notifier).state = 4;
  }

  void _showReportsComingSoon() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Reports feature coming soon!'),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.info,
      ),
    );
  }
}
