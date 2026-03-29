import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../config/theme.dart';
import '../../models/order.dart';
import '../../providers/auth_provider.dart';
import '../../providers/order_provider.dart';
import '../../utils/helpers.dart';
import '../../utils/premium_animations.dart';
import '../../utils/premium_decorations.dart';
import '../../widgets/status_badge.dart';

class OrderTrackingDetailScreen extends ConsumerStatefulWidget {
  final Order order;

  const OrderTrackingDetailScreen({
    super.key,
    required this.order,
  });

  @override
  ConsumerState<OrderTrackingDetailScreen> createState() =>
      _OrderTrackingDetailScreenState();
}

class _OrderTrackingDetailScreenState
    extends ConsumerState<OrderTrackingDetailScreen>
    with TickerProviderStateMixin {
  late AnimationController _entranceCtrl;
  Timer? _pollingTimer;
  Order? _latestOrder;

  @override
  void initState() {
    super.initState();
    _latestOrder = widget.order;
    _entranceCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..forward();

    // Start polling every 15 seconds
    _startPolling();
  }

  void _startPolling() {
    _pollingTimer = Timer.periodic(const Duration(seconds: 15), (timer) {
      _refreshOrder();
    });
  }

  Future<void> _refreshOrder() async {
    final user = ref.read(authStateProvider).user;
    if (user?.id != null) {
      await ref.read(customerOrdersProvider.notifier).loadOrders(user!.id!);
      final orderState = ref.read(customerOrdersProvider);

      // Find updated order
      final allOrders = [
        ...orderState.activeOrders,
        ...orderState.historyOrders,
      ];
      final updatedOrder = allOrders.firstWhere(
        (o) => o.id == widget.order.id,
        orElse: () => widget.order,
      );

      if (mounted) {
        setState(() {
          _latestOrder = updatedOrder;
        });
      }
    }
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    _entranceCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final order = _latestOrder!;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // ---- Green header ----
          PremiumHeader(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
            child: SafeArea(
              bottom: false,
              child: Row(
                children: [
                  PressableScale(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.arrow_back_rounded,
                        color: Colors.white,
                        size: 22,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Order Tracking',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ),
                  // Auto-refresh indicator
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            color: Colors.greenAccent,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Text(
                          'Live',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ---- Content ----
          Expanded(
            child: RefreshIndicator(
              onRefresh: _refreshOrder,
              color: AppColors.primary,
              backgroundColor: Colors.white,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Order Info Card
                    _buildOrderInfoCard(order),
                    const SizedBox(height: 20),

                    // Status Timeline
                    _buildStatusTimeline(order),

                    const SizedBox(height: 20),

                    // Order Details
                    _buildOrderDetails(order),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderInfoCard(Order order) {
    return StaggeredListItem(
      index: 0,
      animation: _entranceCtrl,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: premiumCardDecoration(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    order.orderName,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                      letterSpacing: -0.5,
                    ),
                  ),
                ),
                StatusBadge.order(order.status),
              ],
            ),
            if (order.id != null) ...[
              const SizedBox(height: 4),
              Text(
                'Order #${order.id}',
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textMuted,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surfaceAlt,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.borderLight),
              ),
              child: Row(
                children: [
                  _buildInfoColumn(
                    'Quantity',
                    '${order.orderQuantity} ${order.orderUnit ?? ''}',
                    Icons.inventory_2_outlined,
                  ),
                  Container(
                    width: 1,
                    height: 32,
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    color: AppColors.border,
                  ),
                  _buildInfoColumn(
                    'Total',
                    AppHelpers.formatCurrency(order.orderPrice),
                    Icons.payments_outlined,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoColumn(String label, String value, IconData icon) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: AppColors.textMuted),
              const SizedBox(width: 4),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textMuted,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusTimeline(Order order) {
    return StaggeredListItem(
      index: 1,
      animation: _entranceCtrl,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: premiumCardDecoration(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Order Progress',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 20),
            _buildTimelineItem(
              'Order Placed',
              'Your order has been received',
              order.orderPlacedDate,
              isCompleted: order.orderPlacedDate != null,
              isFirst: true,
            ),
            _buildTimelineItem(
              'Order Scheduled',
              'Vendor confirmed your order',
              order.scheduledDate,
              isCompleted: order.scheduledDate != null,
            ),
            _buildTimelineItem(
              'Ready for Pickup',
              'Order is ready at pickup point',
              order.readyDate,
              isCompleted: order.readyDate != null,
            ),
            _buildTimelineItem(
              'Delivered',
              'Order completed successfully',
              order.deliveredDate ?? order.orderDeliveredDate,
              isCompleted: order.deliveredDate != null ||
                  order.orderDeliveredDate != null,
              isLast: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimelineItem(
    String title,
    String subtitle,
    DateTime? timestamp, {
    required bool isCompleted,
    bool isFirst = false,
    bool isLast = false,
  }) {
    final bool isCurrent = isCompleted &&
        (isLast ||
            (title == 'Order Placed' && timestamp != null) ||
            (title == 'Order Scheduled' && timestamp != null) ||
            (title == 'Ready for Pickup' && timestamp != null));

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: isCompleted
                    ? AppColors.success
                    : AppColors.surfaceAlt,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isCompleted
                      ? AppColors.success
                      : AppColors.border,
                  width: 2,
                ),
              ),
              child: Center(
                child: isCompleted
                    ? const Icon(
                        Icons.check_rounded,
                        color: Colors.white,
                        size: 16,
                      )
                    : Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: AppColors.border,
                          shape: BoxShape.circle,
                        ),
                      ),
              ),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 60,
                margin: const EdgeInsets.symmetric(vertical: 2),
                color: isCompleted
                    ? AppColors.success
                    : AppColors.borderLight,
              ),
          ],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: isCompleted
                      ? AppColors.textPrimary
                      : AppColors.textMuted,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 13,
                  color: isCompleted
                      ? AppColors.textSecondary
                      : AppColors.textHint,
                ),
              ),
              if (timestamp != null) ...[
                const SizedBox(height: 4),
                Text(
                  AppHelpers.formatDate(timestamp),
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textMuted,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
              if (!isLast) const SizedBox(height: 16),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildOrderDetails(Order order) {
    return StaggeredListItem(
      index: 2,
      animation: _entranceCtrl,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: premiumCardDecoration(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Order Details',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 16),
            _buildDetailRow(
              'Product',
              order.productName ?? order.orderName,
              Icons.shopping_bag_outlined,
            ),
            if (order.customerPickupPoint != null) ...[
              const Divider(height: 24),
              _buildDetailRow(
                'Pickup Point',
                order.customerPickupPoint!,
                Icons.location_on_outlined,
              ),
            ],
            if (order.customerName != null) ...[
              const Divider(height: 24),
              _buildDetailRow(
                'Customer',
                order.customerName!,
                Icons.person_outline,
              ),
            ],
            if (order.customerPhone != null) ...[
              const Divider(height: 24),
              _buildDetailRow(
                'Phone',
                order.customerPhone!,
                Icons.phone_outlined,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, IconData icon) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.08),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: 18,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textMuted,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
