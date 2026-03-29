import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/order.dart';
import '../services/order_service.dart';
import 'order_provider.dart';

final vendorOrdersProvider =
    StateNotifierProvider<VendorOrdersNotifier, VendorOrdersState>((ref) {
  return VendorOrdersNotifier(ref.read(orderServiceProvider));
});

class VendorOrdersState {
  final List<Order> issuedOrders;
  final List<Order> scheduledOrders;
  final List<Order> allOrders;
  final bool isLoading;
  final bool isActioning;
  final String? error;
  final DateTime? lastSeenTimestamp; // Track when we last checked for updates
  final Set<int> newOrderIds; // Track which orders are "new" (within last 2 min)
  final Set<int> recentlyUpdatedIds; // Track which orders were recently status-updated

  const VendorOrdersState({
    this.issuedOrders = const [],
    this.scheduledOrders = const [],
    this.allOrders = const [],
    this.isLoading = false,
    this.isActioning = false,
    this.error,
    this.lastSeenTimestamp,
    this.newOrderIds = const {},
    this.recentlyUpdatedIds = const {},
  });

  int get newOrderCount => issuedOrders.length;

  List<Order> get historyOrders => allOrders.where((o) => !o.isActive).toList();

  double get totalRevenue => allOrders
      .where((o) =>
          o.status == OrderStatus.DELIVERED ||
          o.status == OrderStatus.SCHEDULED)
      .fold(0.0, (sum, o) => sum + o.orderPrice);

  /// Check if an order is "new" (placed within last 2 minutes)
  bool isOrderNew(Order order) {
    if (!newOrderIds.contains(order.id)) return false;
    if (order.orderPlacedDate == null) return false;

    final now = DateTime.now();
    final diff = now.difference(order.orderPlacedDate!);
    return diff.inMinutes < 2; // Show NEW badge for 2 minutes
  }

  /// Check if an order was recently updated (status changed within last 2 minutes)
  bool isOrderRecentlyUpdated(Order order) {
    if (!recentlyUpdatedIds.contains(order.id)) return false;
    if (order.statusUpdatedAt == null) return false;

    final now = DateTime.now();
    final diff = now.difference(order.statusUpdatedAt!);
    return diff.inMinutes < 2; // Show update indicator for 2 minutes
  }

  VendorOrdersState copyWith({
    List<Order>? issuedOrders,
    List<Order>? scheduledOrders,
    List<Order>? allOrders,
    bool? isLoading,
    bool? isActioning,
    String? error,
    DateTime? lastSeenTimestamp,
    Set<int>? newOrderIds,
    Set<int>? recentlyUpdatedIds,
  }) {
    return VendorOrdersState(
      issuedOrders: issuedOrders ?? this.issuedOrders,
      scheduledOrders: scheduledOrders ?? this.scheduledOrders,
      allOrders: allOrders ?? this.allOrders,
      isLoading: isLoading ?? this.isLoading,
      isActioning: isActioning ?? this.isActioning,
      error: error,
      lastSeenTimestamp: lastSeenTimestamp ?? this.lastSeenTimestamp,
      newOrderIds: newOrderIds ?? this.newOrderIds,
      recentlyUpdatedIds: recentlyUpdatedIds ?? this.recentlyUpdatedIds,
    );
  }
}

class VendorOrdersNotifier extends StateNotifier<VendorOrdersState> {
  final OrderService _service;

  VendorOrdersNotifier(this._service) : super(const VendorOrdersState());

  Future<void> loadAllOrders(String vendorId) async {
    final previousOrders = state.allOrders;
    final previousTimestamp = state.lastSeenTimestamp;
    final now = DateTime.now();

    state = state.copyWith(isLoading: true, error: null);
    try {
      final results = await Future.wait([
        _service.getVendorIssuedOrders(vendorId),
        _service.getVendorScheduledOrders(vendorId),
        _service.getVendorReadyOrders(vendorId),
        _service.getVendorOrders(vendorId),
      ]);

      // Combine SCHEDULED and READY orders for the "Scheduled" tab
      final scheduledAndReady = [...results[1], ...results[2]];
      final allOrders = results[3];

      // Detect new and updated orders
      final newIds = <int>{};
      final updatedIds = <int>{};

      // Only detect changes if we have a previous timestamp (skip first load)
      if (previousTimestamp != null) {
        // Build map of previous orders for quick lookup
        final previousOrderMap = {
          for (var order in previousOrders) if (order.id != null) order.id!: order
        };

        for (var order in allOrders) {
          if (order.id == null) continue;

          final previousOrder = previousOrderMap[order.id];

          if (previousOrder == null) {
            // Completely new order (not in previous fetch)
            newIds.add(order.id!);
          } else if (previousOrder.status != order.status) {
            // Status changed - mark as recently updated
            updatedIds.add(order.id!);
          }
        }
      }

      state = VendorOrdersState(
        issuedOrders: results[0],
        scheduledOrders: scheduledAndReady,
        allOrders: allOrders,
        lastSeenTimestamp: now,
        newOrderIds: newIds,
        recentlyUpdatedIds: updatedIds,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString().replaceFirst('Exception: ', ''),
      );
    }
  }

  Future<bool> acceptOrder(int orderId, String vendorId) async {
    state = state.copyWith(isActioning: true, error: null);
    try {
      await _service.acceptOrder(orderId);
      await loadAllOrders(vendorId);
      return true;
    } catch (e) {
      state = state.copyWith(
        isActioning: false,
        error: e.toString().replaceFirst('Exception: ', ''),
      );
      return false;
    }
  }

  Future<bool> rejectOrder(int orderId, String vendorId) async {
    state = state.copyWith(isActioning: true, error: null);
    try {
      await _service.rejectOrder(orderId);
      await loadAllOrders(vendorId);
      return true;
    } catch (e) {
      state = state.copyWith(
        isActioning: false,
        error: e.toString().replaceFirst('Exception: ', ''),
      );
      return false;
    }
  }

  /// Update order status with validation (ISSUED→SCHEDULED→READY→DELIVERED)
  Future<bool> updateOrderStatus(
      int orderId, String newStatus, String vendorId) async {
    state = state.copyWith(isActioning: true, error: null);
    try {
      await _service.updateOrderStatus(orderId, newStatus);
      await loadAllOrders(vendorId);
      return true;
    } catch (e) {
      state = state.copyWith(
        isActioning: false,
        error: e.toString().replaceFirst('Exception: ', ''),
      );
      return false;
    }
  }
}
