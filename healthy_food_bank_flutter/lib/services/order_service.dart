import '../config/api_config.dart';
import '../models/order.dart';
import '../models/product_demand_summary.dart';
import 'api_client.dart';

class OrderService {
  final ApiClient _api = ApiClient();

  Future<Order> createOrder(Map<String, dynamic> data) async {
    final response = await _api.post(ApiConfig.orders, body: data);
    if (!response.success) throw Exception(response.error);
    return Order.fromJson(response.data);
  }

  Future<List<Order>> getCustomerOrders(int customerId) async {
    final response = await _api.get(ApiConfig.customerOrders(customerId));
    if (!response.success) throw Exception(response.error);
    return (response.data as List).map((e) => Order.fromJson(e)).toList();
  }

  Future<List<Order>> getVendorOrders(String vendorId) async {
    final response = await _api.get(ApiConfig.vendorOrders(vendorId));
    if (!response.success) throw Exception(response.error);
    return (response.data as List).map((e) => Order.fromJson(e)).toList();
  }

  /// Get aggregated product demand summary for vendor
  /// Shows total quantity needed per product for inventory planning
  Future<VendorOrderSummaryResponse> getVendorOrderSummary(
      String vendorId) async {
    final response = await _api.get(ApiConfig.vendorOrderSummary(vendorId));
    if (!response.success) throw Exception(response.error);
    return VendorOrderSummaryResponse.fromJson(response.data);
  }

  Future<List<Order>> getVendorIssuedOrders(String vendorId) async {
    final response = await _api.get(ApiConfig.vendorIssuedOrders(vendorId));
    if (!response.success) throw Exception(response.error);
    return (response.data as List).map((e) => Order.fromJson(e)).toList();
  }

  Future<List<Order>> getVendorScheduledOrders(String vendorId) async {
    final response = await _api.get(ApiConfig.vendorScheduledOrders(vendorId));
    if (!response.success) throw Exception(response.error);
    return (response.data as List).map((e) => Order.fromJson(e)).toList();
  }

  Future<List<Order>> getVendorReadyOrders(String vendorId) async {
    final response = await _api.get(ApiConfig.vendorReadyOrders(vendorId));
    if (!response.success) throw Exception(response.error);
    return (response.data as List).map((e) => Order.fromJson(e)).toList();
  }

  Future<List<Order>> getVendorCancelledOrders(String vendorId) async {
    final response = await _api.get(ApiConfig.vendorCancelledOrders(vendorId));
    if (!response.success) throw Exception(response.error);
    return (response.data as List).map((e) => Order.fromJson(e)).toList();
  }

  Future<void> acceptOrder(int orderId) async {
    final response = await _api.post(ApiConfig.acceptOrder(orderId));
    if (!response.success) throw Exception(response.error);
  }

  Future<void> rejectOrder(int orderId) async {
    final response = await _api.post(ApiConfig.rejectOrder(orderId));
    if (!response.success) throw Exception(response.error);
  }

  /// Update order status with validation (Vendor only)
  /// Valid transitions: ISSUED→SCHEDULED, SCHEDULED→READY, READY→DELIVERED
  Future<void> updateOrderStatus(int orderId, String status) async {
    final response = await _api.put(
      ApiConfig.updateOrderStatus(orderId),
      body: {'status': status}, // Changed from 'orderStatus' to 'status'
    );
    if (!response.success) throw Exception(response.error);
  }

  /// Check if orders are currently allowed based on business rules
  /// Returns timing information including delivery slot data
  Future<Map<String, dynamic>> checkOrderTiming() async {
    final response = await _api.get(ApiConfig.checkOrderTiming);
    if (!response.success) throw Exception(response.error);
    return response.data as Map<String, dynamic>;
  }

  /// Get the current active delivery slot
  /// Returns slot info with orderAllowed status and time until cutoff
  Future<Map<String, dynamic>> getActiveDeliverySlot() async {
    final response = await _api.get(ApiConfig.activeDeliverySlot);
    if (!response.success) throw Exception(response.error);
    return response.data as Map<String, dynamic>;
  }
}
