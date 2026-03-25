import '../config/api_config.dart';
import '../models/order.dart';
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

  Future<void> updateOrderStatus(int orderId, String status) async {
    final response = await _api.put(
      ApiConfig.updateOrderStatus(orderId),
      body: {'orderStatus': status},
    );
    if (!response.success) throw Exception(response.error);
  }
}
