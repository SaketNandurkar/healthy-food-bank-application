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

  const OrderListState({
    this.orders = const [],
    this.isLoading = false,
    this.error,
  });

  List<Order> get activeOrders => orders.where((o) => o.isActive).toList();
  List<Order> get historyOrders => orders.where((o) => !o.isActive).toList();

  OrderListState copyWith({
    List<Order>? orders,
    bool? isLoading,
    String? error,
  }) {
    return OrderListState(
      orders: orders ?? this.orders,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class CustomerOrdersNotifier extends StateNotifier<OrderListState> {
  final OrderService _service;

  CustomerOrdersNotifier(this._service) : super(const OrderListState());

  Future<void> loadOrders(int customerId) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final orders = await _service.getCustomerOrders(customerId);
      state = OrderListState(orders: orders);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString().replaceFirst('Exception: ', ''),
      );
    }
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
