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
import '../../widgets/empty_state.dart';
import 'order_tracking_detail_screen.dart';

class CustomerOrdersScreen extends ConsumerStatefulWidget {
  const CustomerOrdersScreen({super.key});

  @override
  ConsumerState<CustomerOrdersScreen> createState() =>
      _CustomerOrdersScreenState();
}

class _CustomerOrdersScreenState extends ConsumerState<CustomerOrdersScreen>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  late TabController _tabController;
  late AnimationController _entranceCtrl;
  Timer? _autoRefreshTimer;

  static const _autoRefreshDuration = Duration(seconds: 30); // Poll every 30 seconds

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _tabController = TabController(length: 2, vsync: this);
    _entranceCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..forward();

    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        HapticFeedback.selectionClick();
        _entranceCtrl.reset();
        _entranceCtrl.forward();
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadOrders();
      _startAutoRefresh();
    });
  }

  void _loadOrders() {
    final user = ref.read(authStateProvider).user;
    if (user?.id != null) {
      ref.read(customerOrdersProvider.notifier).loadOrders(user!.id!);
    }
  }

  void _startAutoRefresh() {
    _autoRefreshTimer?.cancel();
    _autoRefreshTimer = Timer.periodic(_autoRefreshDuration, (_) {
      if (mounted) {
        _loadOrders();
      }
    });
  }

  void _stopAutoRefresh() {
    _autoRefreshTimer?.cancel();
    _autoRefreshTimer = null;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      // Refresh when app comes to foreground
      _loadOrders();
      _startAutoRefresh();
    } else if (state == AppLifecycleState.paused) {
      // Pause auto-refresh when app goes to background
      _stopAutoRefresh();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _stopAutoRefresh();
    _tabController.dispose();
    _entranceCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final orderState = ref.watch(customerOrdersProvider);

    // Show status change notifications
    ref.listen<OrderListState>(customerOrdersProvider, (previous, current) {
      if (current.statusChanges.isNotEmpty && mounted) {
        // Show notifications for each status change
        for (var entry in current.statusChanges.entries) {
          final orderId = entry.key;
          final message = current.getStatusChangeMessage(orderId);
          if (message != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    const Icon(
                      Icons.notifications_active,
                      color: Colors.white,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        message,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                backgroundColor: AppColors.primary,
                behavior: SnackBarBehavior.floating,
                duration: const Duration(seconds: 5),
                action: SnackBarAction(
                  label: 'View',
                  textColor: Colors.white,
                  onPressed: () {
                    // Find the order and navigate to detail screen
                    final order = current.orders.firstWhere(
                      (o) => o.id == orderId,
                      orElse: () => current.orders.first,
                    );
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            OrderTrackingDetailScreen(order: order),
                      ),
                    );
                  },
                ),
              ),
            );
            // Clear the notification after showing it
            Future.delayed(const Duration(milliseconds: 100), () {
              ref.read(customerOrdersProvider.notifier).clearStatusChange(orderId);
            });
          }
        }
      }
    });

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
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.receipt_long_rounded,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'My Orders',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ---- Pill-style tab bar ----
          Container(
            margin: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.borderLight),
              boxShadow: PremiumShadows.subtle(),
            ),
            child: TabBar(
              controller: _tabController,
              labelColor: Colors.white,
              unselectedLabelColor: AppColors.textMuted,
              indicatorSize: TabBarIndicatorSize.tab,
              dividerColor: Colors.transparent,
              indicator: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(12),
              ),
              labelStyle: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.2,
              ),
              unselectedLabelStyle: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
              splashFactory: NoSplash.splashFactory,
              overlayColor: WidgetStateProperty.all(Colors.transparent),
              tabs: [
                Tab(
                  text: 'Active (${orderState.activeOrders.length})',
                ),
                Tab(
                  text: 'History (${orderState.historyOrders.length})',
                ),
              ],
            ),
          ),

          // ---- Content area ----
          Expanded(
            child: orderState.isLoading
                ? _buildShimmerList()
                : TabBarView(
                    controller: _tabController,
                    children: [
                      _buildOrderList(orderState.activeOrders,
                          isActive: true),
                      _buildOrderList(orderState.historyOrders,
                          isActive: false),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  // ---- Shimmer loading skeleton ----
  Widget _buildShimmerList() {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 4,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, __) => const ShimmerOrderCard(),
    );
  }

  // ---- Order list (active or history) ----
  Widget _buildOrderList(List<Order> orders, {required bool isActive}) {
    if (orders.isEmpty) {
      return EmptyState(
        icon: isActive ? Icons.receipt_long_outlined : Icons.history,
        title: isActive ? 'No active orders' : 'No order history',
        subtitle: isActive
            ? 'Your active orders will appear here'
            : 'Completed orders will show here',
        actionLabel: isActive ? 'Start Shopping' : null,
      );
    }

    return RefreshIndicator(
      onRefresh: () async => _loadOrders(),
      color: AppColors.primary,
      backgroundColor: Colors.white,
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: orders.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          return StaggeredListItem(
            index: index,
            animation: _entranceCtrl,
            child: PressableScale(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        OrderTrackingDetailScreen(order: orders[index]),
                  ),
                ).then((_) => _loadOrders()); // Refresh after returning
              },
              child: _buildOrderCard(orders[index]),
            ),
          );
        },
      ),
    );
  }

  // ---- Individual order card ----
  Widget _buildOrderCard(Order order) {
    final borderColor = _getStatusBorderColor(order.status);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: PremiumShadows.subtle(),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            border: Border(
              left: BorderSide(color: borderColor, width: 4),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // -- Top row: status badge + date --
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    StatusBadge.order(order.status),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceAlt,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        AppHelpers.formatDate(order.orderPlacedDate),
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textHint,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // -- Order name --
                Text(
                  order.orderName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.2,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),

                // -- Order ID --
                if (order.id != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    'Order #${order.id}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],

                const SizedBox(height: 10),

                // -- Quantity / Price row --
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceAlt,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.borderLight),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.inventory_2_outlined,
                        size: 14,
                        color: AppColors.textMuted,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Qty: ${order.orderQuantity}',
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Container(
                        width: 1,
                        height: 14,
                        color: AppColors.border,
                      ),
                      const SizedBox(width: 16),
                      Text(
                        AppHelpers.formatCurrency(order.orderPrice),
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),

                // -- Pickup point --
                if (order.customerPickupPoint != null) ...[
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.08),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.location_on_outlined,
                          size: 12,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          order.customerPickupPoint!,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textMuted,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ---- Status-based left border color ----
  Color _getStatusBorderColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.DELIVERED:
      case OrderStatus.SCHEDULED:
        return AppColors.success;
      case OrderStatus.PROCESSING:
        return AppColors.info;
      case OrderStatus.CANCELLED:
      case OrderStatus.CANCELLED_BY_VENDOR:
        return AppColors.error;
      default:
        return const Color(0xFFF59E0B); // warning amber
    }
  }
}
