import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../config/theme.dart';
import '../../utils/premium_decorations.dart';
import '../../utils/premium_animations.dart';
import '../../providers/admin_analytics_provider.dart';

class AdminAnalyticsScreen extends ConsumerStatefulWidget {
  const AdminAnalyticsScreen({super.key});

  @override
  ConsumerState<AdminAnalyticsScreen> createState() =>
      _AdminAnalyticsScreenState();
}

class _AdminAnalyticsScreenState extends ConsumerState<AdminAnalyticsScreen>
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
    final analyticsState = ref.watch(analyticsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            PremiumHeader(
              title: 'Business Analytics',
              subtitle: 'Real-time Business Insights',
              gradient: PremiumGradients.header(),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
            Expanded(
              child: analyticsState.isLoading && analyticsState.overview == null
                  ? const Center(child: CircularProgressIndicator())
                  : analyticsState.error != null
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.error_outline,
                                  size: 48, color: AppColors.error),
                              const SizedBox(height: 16),
                              const Text(
                                'Error loading analytics',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                analyticsState.error!,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: () =>
                                    ref.read(analyticsProvider.notifier).refresh(),
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
                              // Overview Cards
                              StaggeredListItem(
                                index: 0,
                                animation: _animationController,
                                child: _buildOverviewCards(),
                              ),
                              const SizedBox(height: AppSpacing.lg),

                              // Orders by Pickup Point
                              StaggeredListItem(
                                index: 1,
                                animation: _animationController,
                                child: _buildSectionHeader('Orders by Pickup Point'),
                              ),
                              const SizedBox(height: AppSpacing.sm),
                              StaggeredListItem(
                                index: 2,
                                animation: _animationController,
                                child: _buildOrdersByPickupPoint(),
                              ),
                              const SizedBox(height: AppSpacing.lg),

                              // Top Products & Top Vendors Row
                              StaggeredListItem(
                                index: 3,
                                animation: _animationController,
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          _buildSectionHeader('Top Products'),
                                          const SizedBox(height: AppSpacing.sm),
                                          _buildTopProducts(),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: AppSpacing.md),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          _buildSectionHeader('Top Vendors'),
                                          const SizedBox(height: AppSpacing.sm),
                                          _buildTopVendors(),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
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

  Widget _buildOverviewCards() {
    final overview = ref.watch(analyticsProvider).overview;

    if (overview == null) {
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
        _buildMetricCard(
          icon: Icons.people_rounded,
          label: 'Total Users',
          value: '${overview.totalUsers}',
          gradient: PremiumGradients.primary(),
        ),
        _buildMetricCard(
          icon: Icons.store_rounded,
          label: 'Total Vendors',
          value: '${overview.totalVendors}',
          gradient: PremiumGradients.success(),
        ),
        _buildMetricCard(
          icon: Icons.shopping_cart_rounded,
          label: 'Total Orders',
          value: '${overview.totalOrders}',
          gradient: PremiumGradients.info(),
        ),
        _buildMetricCard(
          icon: Icons.attach_money_rounded,
          label: 'Total Revenue',
          value: '\$${overview.totalRevenue.toStringAsFixed(0)}',
          gradient: PremiumGradients.warning(),
        ),
      ],
    );
  }

  Widget _buildMetricCard({
    required IconData icon,
    required String label,
    required String value,
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
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildOrdersByPickupPoint() {
    final ordersByPickupPoint = ref.watch(analyticsProvider).ordersByPickupPoint;

    if (ordersByPickupPoint.isEmpty) {
      return Container(
        decoration: premiumCardDecoration(),
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: const Center(
          child: Text(
            'No pickup point data available',
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ),
      );
    }

    return Container(
      decoration: premiumCardDecoration(),
      child: Column(
        children: ordersByPickupPoint.take(5).map((item) {
          return Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: AppColors.border, width: 0.5),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: PremiumGradients.primary(),
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  child: const Icon(
                    Icons.location_on_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    item.pickupPointName,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    gradient: PremiumGradients.info(),
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                  ),
                  child: Text(
                    '${item.totalOrders}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTopProducts() {
    final topProducts = ref.watch(analyticsProvider).topProducts;

    if (topProducts.isEmpty) {
      return Container(
        decoration: premiumCardDecoration(),
        padding: const EdgeInsets.all(AppSpacing.md),
        child: const Center(
          child: Text(
            'No data',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
          ),
        ),
      );
    }

    return Container(
      decoration: premiumCardDecoration(),
      child: Column(
        children: topProducts.take(5).map((product) {
          return Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: AppSpacing.xs,
            ),
            child: Row(
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    gradient: PremiumGradients.success(),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: AppSpacing.xs),
                Expanded(
                  child: Text(
                    product.productName,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textPrimary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  '${product.totalQuantity}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTopVendors() {
    final topVendors = ref.watch(analyticsProvider).topVendors;

    if (topVendors.isEmpty) {
      return Container(
        decoration: premiumCardDecoration(),
        padding: const EdgeInsets.all(AppSpacing.md),
        child: const Center(
          child: Text(
            'No data',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
          ),
        ),
      );
    }

    return Container(
      decoration: premiumCardDecoration(),
      child: Column(
        children: topVendors.take(5).map((vendor) {
          return Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: AppSpacing.xs,
            ),
            child: Row(
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    gradient: PremiumGradients.warning(),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: AppSpacing.xs),
                Expanded(
                  child: Text(
                    vendor.vendorName,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textPrimary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  '${vendor.totalOrders}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Future<void> _refresh() async {
    await ref.read(analyticsProvider.notifier).refresh();
  }
}
