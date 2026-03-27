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

  const VendorOrdersState({
    this.issuedOrders = const [],
    this.scheduledOrders = const [],
    this.allOrders = const [],
    this.isLoading = false,
    this.isActioning = false,
    this.error,
  });

  int get newOrderCount => issuedOrders.length;

  List<Order> get historyOrders => allOrders.where((o) => !o.isActive).toList();

  double get totalRevenue => allOrders
      .where((o) =>
          o.status == OrderStatus.DELIVERED ||
          o.status == OrderStatus.SCHEDULED)
      .fold(0.0, (sum, o) => sum + o.orderPrice);

  VendorOrdersState copyWith({
    List<Order>? issuedOrders,
    List<Order>? scheduledOrders,
    List<Order>? allOrders,
    bool? isLoading,
    bool? isActioning,
    String? error,
  }) {
    return VendorOrdersState(
      issuedOrders: issuedOrders ?? this.issuedOrders,
      scheduledOrders: scheduledOrders ?? this.scheduledOrders,
      allOrders: allOrders ?? this.allOrders,
      isLoading: isLoading ?? this.isLoading,
      isActioning: isActioning ?? this.isActioning,
      error: error,
    );
  }
}

class VendorOrdersNotifier extends StateNotifier<VendorOrdersState> {
  final OrderService _service;

  VendorOrdersNotifier(this._service) : super(const VendorOrdersState());

  Future<void> loadAllOrders(String vendorId) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final results = await Future.wait([
        _service.getVendorIssuedOrders(vendorId),
        _service.getVendorScheduledOrders(vendorId),
        _service.getVendorOrders(vendorId),
      ]);
      state = VendorOrdersState(
        issuedOrders: results[0],
        scheduledOrders: results[1],
        allOrders: results[2],
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
}
