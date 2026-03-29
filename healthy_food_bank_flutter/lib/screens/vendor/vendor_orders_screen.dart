import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../config/theme.dart';
import '../../models/order.dart';
import '../../models/product_demand_summary.dart';
import '../../providers/auth_provider.dart';
import '../../providers/vendor_order_provider.dart';
import '../../services/order_service.dart';
import '../../utils/helpers.dart';
import '../../utils/premium_animations.dart';
import '../../utils/premium_decorations.dart';
import '../../widgets/status_badge.dart';
import '../../widgets/empty_state.dart';

class VendorOrdersScreen extends ConsumerStatefulWidget {
  const VendorOrdersScreen({super.key});

  @override
  ConsumerState<VendorOrdersScreen> createState() =>
      _VendorOrdersScreenState();
}

class _VendorOrdersScreenState extends ConsumerState<VendorOrdersScreen>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  late TabController _tabController;
  late AnimationController _entranceCtrl;
  Timer? _autoRefreshTimer;
  final OrderService _orderService = OrderService();

  static const _autoRefreshDuration = Duration(seconds: 15);

  // Order summary state
  VendorOrderSummaryResponse? _orderSummary;
  bool _loadingSummary = false;
  bool _summaryExpanded = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _tabController = TabController(length: 3, vsync: this);
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
    if (user?.vendorId != null) {
      ref.read(vendorOrdersProvider.notifier).loadAllOrders(user!.vendorId!);
      _loadOrderSummary(user.vendorId!);
    }
  }

  Future<void> _loadOrderSummary(String vendorId) async {
    setState(() => _loadingSummary = true);
    try {
      final summary = await _orderService.getVendorOrderSummary(vendorId);
      if (mounted) {
        setState(() {
          _orderSummary = summary;
          _loadingSummary = false;
        });
      }
    } catch (e) {
      print('Error loading order summary: $e');
      if (mounted) {
        setState(() => _loadingSummary = false);
      }
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
    final orderState = ref.watch(vendorOrdersProvider);

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
                    'Orders',
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
                Tab(text: 'New (${orderState.issuedOrders.length})'),
                Tab(text: 'Scheduled (${orderState.scheduledOrders.length})'),
                Tab(text: 'History (${orderState.historyOrders.length})'),
              ],
            ),
          ),

          // ---- Total Demand Section ----
          _buildTotalDemandSection(),

          // ---- Content area ----
          Expanded(
            child: orderState.isLoading
                ? _buildShimmerList()
                : TabBarView(
                    controller: _tabController,
                    children: [
                      _buildOrderList(
                        orderState.issuedOrders,
                        emptyIcon: Icons.notifications_active_outlined,
                        emptyTitle: 'No new orders',
                        emptySubtitle: 'New customer orders will appear here',
                        showActions: true,
                      ),
                      _buildOrderList(
                        orderState.scheduledOrders,
                        emptyIcon: Icons.schedule_outlined,
                        emptyTitle: 'No scheduled orders',
                        emptySubtitle: 'Accepted orders will appear here',
                        showActions: true,
                      ),
                      _buildOrderList(
                        orderState.historyOrders,
                        emptyIcon: Icons.history,
                        emptyTitle: 'No order history',
                        emptySubtitle: 'Completed orders will show here',
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerList() {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 4,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, __) => const ShimmerOrderCard(),
    );
  }

  // ---- Total Demand Section ----
  Widget _buildTotalDemandSection() {
    if (_orderSummary == null || _orderSummary!.products.isEmpty) {
      return const SizedBox.shrink();
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        elevation: 0,
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.borderLight),
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.blue.shade50,
                Colors.purple.shade50,
              ],
            ),
          ),
          child: Column(
            children: [
              // Header
              InkWell(
                onTap: () {
                  setState(() => _summaryExpanded = !_summaryExpanded);
                  HapticFeedback.selectionClick();
                },
                borderRadius: BorderRadius.circular(16),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.inventory_2_rounded,
                          color: AppColors.primary,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '📦 Total Demand',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textPrimary,
                                letterSpacing: -0.3,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${_orderSummary!.totalProducts} products • ${_orderSummary!.totalOrders} units',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        _summaryExpanded
                            ? Icons.keyboard_arrow_up_rounded
                            : Icons.keyboard_arrow_down_rounded,
                        color: AppColors.textSecondary,
                        size: 24,
                      ),
                    ],
                  ),
                ),
              ),

              // Expandable content
              AnimatedCrossFade(
                firstChild: const SizedBox.shrink(),
                secondChild: Column(
                  children: [
                    const Divider(height: 1),
                    Container(
                      constraints: const BoxConstraints(maxHeight: 250),
                      child: ListView.separated(
                        padding: const EdgeInsets.all(16),
                        shrinkWrap: true,
                        itemCount: _orderSummary!.products.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final product = _orderSummary!.products[index];
                          return _buildProductDemandItem(product);
                        },
                      ),
                    ),
                  ],
                ),
                crossFadeState: _summaryExpanded
                    ? CrossFadeState.showSecond
                    : CrossFadeState.showFirst,
                duration: const Duration(milliseconds: 300),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProductDemandItem(ProductDemandSummary product) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Product icon
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.surfaceAlt,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.eco,
              color: AppColors.primary,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),

          // Product name
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.productName,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.2,
                  ),
                ),
                if (product.unit != null && product.unit!.isNotEmpty)
                  Text(
                    'Unit: ${product.unit}',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textMuted,
                    ),
                  ),
              ],
            ),
          ),

          // Quantity badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.shopping_basket_rounded,
                  color: Colors.white,
                  size: 16,
                ),
                const SizedBox(width: 6),
                Text(
                  '${product.totalQuantity}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderList(
    List<Order> orders, {
    required IconData emptyIcon,
    required String emptyTitle,
    required String emptySubtitle,
    bool showActions = false,
  }) {
    if (orders.isEmpty) {
      return EmptyState(
        icon: emptyIcon,
        title: emptyTitle,
        subtitle: emptySubtitle,
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
            child: _buildOrderCard(orders[index], showActions: showActions),
          );
        },
      ),
    );
  }

  Widget _buildOrderCard(Order order, {bool showActions = false}) {
    final borderColor = _getStatusBorderColor(order.status);
    final orderState = ref.watch(vendorOrdersProvider);
    final isNew = orderState.isOrderNew(order);
    final isUpdated = orderState.isOrderRecentlyUpdated(order);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isNew
              ? AppColors.primary.withOpacity(0.5)
              : (isUpdated
                  ? AppColors.info.withOpacity(0.5)
                  : AppColors.borderLight),
          width: isNew || isUpdated ? 2 : 1,
        ),
        boxShadow: isNew || isUpdated
            ? [
                BoxShadow(
                  color: (isNew ? AppColors.primary : AppColors.info)
                      .withOpacity(0.15),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ]
            : PremiumShadows.subtle(),
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
                // -- Top row: status badge + NEW/UPDATED indicator + date --
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        children: [
                          StatusBadge.order(order.status),
                          if (isNew)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    AppColors.primary,
                                    AppColors.primary.withOpacity(0.8),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(6),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.primary.withOpacity(0.3),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: const Text(
                                '🆕 NEW',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          if (isUpdated && !isNew)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.info,
                                borderRadius: BorderRadius.circular(6),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.info.withOpacity(0.3),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: const Text(
                                '🔄 UPDATED',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
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
                        'Qty: ${order.orderQuantity}${order.orderUnit != null ? ' ${order.orderUnit}' : ''}',
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

                // -- Customer info --
                if (order.customerName != null) ...[
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: AppColors.info.withOpacity(0.08),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.person_outline,
                          size: 12,
                          color: AppColors.info,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          order.customerName!,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (order.customerPhone != null) ...[
                        const SizedBox(width: 8),
                        Text(
                          order.customerPhone!,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],

                // -- Pickup point --
                if (order.customerPickupPoint != null) ...[
                  const SizedBox(height: 6),
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

                // -- Action buttons based on status --
                if (showActions) ..._buildActionButtons(order),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Build action buttons based on order status
  List<Widget> _buildActionButtons(Order order) {
    final orderState = ref.watch(vendorOrdersProvider);
    final isLoading = orderState.isActioning;

    switch (order.status) {
      case OrderStatus.ISSUED:
        // New orders: Show Reject + Confirm buttons
        return [
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: isLoading ? null : () => _showRejectDialog(order),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.error,
                    side: const BorderSide(color: AppColors.error),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                  child: const Text(
                    'Reject',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: isLoading ? null : () => _handleConfirm(order),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                  child: isLoading
                      ? const SizedBox(
                          height: 16,
                          width: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text(
                          'Confirm',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ];

      case OrderStatus.SCHEDULED:
        // Scheduled orders: Show Mark Ready button
        return [
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: isLoading ? null : () => _handleMarkReady(order),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.info,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              icon: isLoading
                  ? const SizedBox(
                      height: 16,
                      width: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Icon(Icons.check_circle_outline, size: 18),
              label: const Text(
                'Mark Ready',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ];

      case OrderStatus.READY:
        // Ready orders: Show Mark Delivered button
        return [
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: isLoading ? null : () => _handleMarkDelivered(order),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.success,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              icon: isLoading
                  ? const SizedBox(
                      height: 16,
                      width: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Icon(Icons.local_shipping_outlined, size: 18),
              label: const Text(
                'Mark Delivered',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ];

      default:
        // No action buttons for other statuses
        return [];
    }
  }

  /// Handle confirming a new order (ISSUED → SCHEDULED)
  Future<void> _handleConfirm(Order order) async {
    HapticFeedback.mediumImpact();
    final user = ref.read(authStateProvider).user;
    if (user?.vendorId == null || order.id == null) return;

    final success = await ref
        .read(vendorOrdersProvider.notifier)
        .updateOrderStatus(order.id!, 'SCHEDULED', user!.vendorId!);

    if (mounted) {
      final orderState = ref.read(vendorOrdersProvider);
      final errorMessage = orderState.error ?? 'Failed to confirm order';

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(
                success ? Icons.check_circle : Icons.error,
                color: Colors.white,
                size: 18,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  success
                      ? '✅ Order #${order.id} confirmed'
                      : errorMessage,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          backgroundColor: success ? AppColors.success : AppColors.error,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  /// Handle marking order as ready (SCHEDULED → READY)
  Future<void> _handleMarkReady(Order order) async {
    HapticFeedback.mediumImpact();
    final user = ref.read(authStateProvider).user;
    if (user?.vendorId == null || order.id == null) return;

    final success = await ref
        .read(vendorOrdersProvider.notifier)
        .updateOrderStatus(order.id!, 'READY', user!.vendorId!);

    if (mounted) {
      final orderState = ref.read(vendorOrdersProvider);
      final errorMessage = orderState.error ?? 'Failed to update order';

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(
                success ? Icons.check_circle : Icons.error,
                color: Colors.white,
                size: 18,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  success
                      ? '📦 Order #${order.id} is ready for pickup'
                      : errorMessage,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          backgroundColor: success ? AppColors.success : AppColors.error,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  /// Handle marking order as delivered (READY → DELIVERED)
  Future<void> _handleMarkDelivered(Order order) async {
    HapticFeedback.mediumImpact();
    final user = ref.read(authStateProvider).user;
    if (user?.vendorId == null || order.id == null) return;

    final success = await ref
        .read(vendorOrdersProvider.notifier)
        .updateOrderStatus(order.id!, 'DELIVERED', user!.vendorId!);

    if (mounted) {
      final orderState = ref.read(vendorOrdersProvider);
      final errorMessage = orderState.error ?? 'Failed to update order';

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(
                success ? Icons.check_circle : Icons.error,
                color: Colors.white,
                size: 18,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  success
                      ? '🎉 Order #${order.id} delivered successfully'
                      : errorMessage,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          backgroundColor: success ? AppColors.success : AppColors.error,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  Future<void> _handleAccept(Order order) async {
    HapticFeedback.mediumImpact();
    final user = ref.read(authStateProvider).user;
    if (user?.vendorId == null || order.id == null) return;

    final success = await ref
        .read(vendorOrdersProvider.notifier)
        .acceptOrder(order.id!, user!.vendorId!);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(
                success ? Icons.check_circle : Icons.error,
                color: Colors.white,
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(success
                  ? 'Order #${order.id} accepted'
                  : 'Failed to accept order'),
            ],
          ),
          backgroundColor: success ? AppColors.success : AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _showRejectDialog(Order order) {
    HapticFeedback.mediumImpact();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.error.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.cancel_outlined,
                color: AppColors.error,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'Reject Order',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        content: const Text(
          'Are you sure you want to reject this order? The stock will be restored automatically.',
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 14,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              'Cancel',
              style: TextStyle(
                color: AppColors.textMuted,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          PressableScale(
            onTap: () async {
              Navigator.pop(ctx);
              final user = ref.read(authStateProvider).user;
              if (user?.vendorId == null || order.id == null) return;

              final success = await ref
                  .read(vendorOrdersProvider.notifier)
                  .rejectOrder(order.id!, user!.vendorId!);

              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Row(
                      children: [
                        Icon(
                          success ? Icons.check_circle : Icons.error,
                          color: Colors.white,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Text(success
                            ? 'Order #${order.id} rejected'
                            : 'Failed to reject order'),
                      ],
                    ),
                    backgroundColor:
                        success ? AppColors.success : AppColors.error,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.error,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text(
                'Reject',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

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
        return const Color(0xFFF59E0B);
    }
  }
}

// Shimmer loading card
class ShimmerOrderCard extends StatefulWidget {
  const ShimmerOrderCard({super.key});

  @override
  State<ShimmerOrderCard> createState() => _ShimmerOrderCardState();
}

class _ShimmerOrderCardState extends State<ShimmerOrderCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _shimmerController;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _shimmerController,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.borderLight),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Container(
              decoration: const BoxDecoration(
                border: Border(
                  left: BorderSide(color: AppColors.borderLight, width: 4),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _shimmerBox(80, 24),
                        _shimmerBox(70, 20),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _shimmerBox(double.infinity, 20),
                    const SizedBox(height: 6),
                    _shimmerBox(100, 16),
                    const SizedBox(height: 10),
                    _shimmerBox(double.infinity, 40),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _shimmerBox(double width, double height) {
    final shimmerGradient = LinearGradient(
      colors: [
        AppColors.surfaceAlt,
        AppColors.background,
        AppColors.surfaceAlt,
      ],
      stops: [
        _shimmerController.value - 0.3,
        _shimmerController.value,
        _shimmerController.value + 0.3,
      ],
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
    );

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        gradient: shimmerGradient,
        borderRadius: BorderRadius.circular(6),
      ),
    );
  }
}
