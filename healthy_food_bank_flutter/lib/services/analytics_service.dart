import 'dart:convert';
import '../config/api_config.dart';
import '../models/admin_analytics_overview.dart';
import '../models/orders_by_pickup_point.dart';
import '../models/top_product.dart';
import '../models/top_vendor.dart';
import 'api_client.dart';

class AnalyticsService {
  final ApiClient _apiClient = ApiClient();

  /// Get analytics overview (total users, vendors, orders, revenue)
  Future<AdminAnalyticsOverview?> getOverview() async {
    try {
      final response = await _apiClient.get(ApiConfig.analyticsOverview);
      if (response.success && response.data != null) {
        return AdminAnalyticsOverview.fromJson(response.data);
      }
      return null;
    } catch (e) {
      print('Error fetching analytics overview: $e');
      return null;
    }
  }

  /// Get orders grouped by pickup point
  Future<List<OrdersByPickupPoint>> getOrdersByPickupPoint() async {
    try {
      final response = await _apiClient.get(ApiConfig.analyticsOrdersByPickupPoint);
      if (response.success && response.data != null) {
        final List<dynamic> data = response.data as List<dynamic>;
        return data.map((json) => OrdersByPickupPoint.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('Error fetching orders by pickup point: $e');
      return [];
    }
  }

  /// Get top products by quantity
  Future<List<TopProduct>> getTopProducts() async {
    try {
      final response = await _apiClient.get(ApiConfig.analyticsTopProducts);
      if (response.success && response.data != null) {
        final List<dynamic> data = response.data as List<dynamic>;
        return data.map((json) => TopProduct.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('Error fetching top products: $e');
      return [];
    }
  }

  /// Get top vendors by order count
  Future<List<TopVendor>> getTopVendors() async {
    try {
      final response = await _apiClient.get(ApiConfig.analyticsTopVendors);
      if (response.success && response.data != null) {
        final List<dynamic> data = response.data as List<dynamic>;
        return data.map((json) => TopVendor.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('Error fetching top vendors: $e');
      return [];
    }
  }
}
