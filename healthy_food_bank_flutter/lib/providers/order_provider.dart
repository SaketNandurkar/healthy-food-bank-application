import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/order.dart';
import '../services/order_service.dart';

final orderServiceProvider = Provider((ref) => OrderService());

final customerOrdersProvider =
    StateNotifierProvider<CustomerOrdersNotifier, OrderListState>((ref) {
  return CustomerOrdersNotifier(ref.read(orderServiceProvider));
});

class OrderListState {
  final List<Order> orders;
  final bool isLoading;
  final String? error;
  final Map<int, OrderStatus> statusChanges; // Track status changes for notifications

  const OrderListState({
    this.orders = const [],
    this.isLoading = false,
    this.error,
    this.statusChanges = const {},
  });

  List<Order> get activeOrders => orders.where((o) => o.isActive).toList();
  List<Order> get historyOrders => orders.where((o) => !o.isActive).toList();

  /// Get human-readable status change message
  String? getStatusChangeMessage(int orderId) {
    final newStatus = statusChanges[orderId];
    if (newStatus == null) return null;

    switch (newStatus) {
      case OrderStatus.SCHEDULED:
        return '✅ Order Confirmed - Your order has been accepted by the vendor';
      case OrderStatus.READY:
        return '📦 Ready for Pickup - Your order is ready for collection';
      case OrderStatus.DELIVERED:
        return '🎉 Order Delivered - Thank you for your order!';
      case OrderStatus.CANCELLED_BY_VENDOR:
        return '❌ Order Cancelled - The vendor has cancelled your order';
      default:
        return null;
    }
  }

  OrderListState copyWith({
    List<Order>? orders,
    bool? isLoading,
    String? error,
    Map<int, OrderStatus>? statusChanges,
  }) {
    return OrderListState(
      orders: orders ?? this.orders,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      statusChanges: statusChanges ?? this.statusChanges,
    );
  }
}

class CustomerOrdersNotifier extends StateNotifier<OrderListState> {
  final OrderService _service;

  CustomerOrdersNotifier(this._service) : super(const OrderListState());

  Future<void> loadOrders(int customerId) async {
    final previousOrders = state.orders;
    state = state.copyWith(isLoading: true, error: null);
    try {
      final orders = await _service.getCustomerOrders(customerId);

      // Detect status changes for notifications
      final statusChanges = <int, OrderStatus>{};
      if (previousOrders.isNotEmpty) {
        final previousOrderMap = {
          for (var order in previousOrders) if (order.id != null) order.id!: order
        };

        for (var order in orders) {
          if (order.id == null) continue;
          final previousOrder = previousOrderMap[order.id];

          // Status changed and it's a meaningful transition
          if (previousOrder != null && previousOrder.status != order.status) {
            // Only notify for customer-relevant status changes
            if (order.status == OrderStatus.SCHEDULED ||
                order.status == OrderStatus.READY ||
                order.status == OrderStatus.DELIVERED ||
                order.status == OrderStatus.CANCELLED_BY_VENDOR) {
              statusChanges[order.id!] = order.status;
            }
          }
        }
      }

      state = OrderListState(orders: orders, statusChanges: statusChanges);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString().replaceFirst('Exception: ', ''),
      );
    }
  }

  /// Clear status change notification for a specific order
  void clearStatusChange(int orderId) {
    final updatedChanges = Map<int, OrderStatus>.from(state.statusChanges);
    updatedChanges.remove(orderId);
    state = state.copyWith(statusChanges: updatedChanges);
  }

  Future<bool> placeOrder(Map<String, dynamic> data) async {
    try {
      await _service.createOrder(data);
      return true;
    } catch (e) {
      state = state.copyWith(
        error: e.toString().replaceFirst('Exception: ', ''),
      );
      return false;
    }
  }
}
