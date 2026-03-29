import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/admin_analytics_overview.dart';
import '../models/orders_by_pickup_point.dart';
import '../models/top_product.dart';
import '../models/top_vendor.dart';
import '../services/analytics_service.dart';

class AnalyticsState {
  final AdminAnalyticsOverview? overview;
  final List<OrdersByPickupPoint> ordersByPickupPoint;
  final List<TopProduct> topProducts;
  final List<TopVendor> topVendors;
  final bool isLoading;
  final String? error;

  AnalyticsState({
    this.overview,
    this.ordersByPickupPoint = const [],
    this.topProducts = const [],
    this.topVendors = const [],
    this.isLoading = false,
    this.error,
  });

  AnalyticsState copyWith({
    AdminAnalyticsOverview? overview,
    List<OrdersByPickupPoint>? ordersByPickupPoint,
    List<TopProduct>? topProducts,
    List<TopVendor>? topVendors,
    bool? isLoading,
    String? error,
  }) {
    return AnalyticsState(
      overview: overview ?? this.overview,
      ordersByPickupPoint: ordersByPickupPoint ?? this.ordersByPickupPoint,
      topProducts: topProducts ?? this.topProducts,
      topVendors: topVendors ?? this.topVendors,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class AnalyticsNotifier extends StateNotifier<AnalyticsState> {
  final AnalyticsService _analyticsService;

  AnalyticsNotifier(this._analyticsService) : super(AnalyticsState());

  /// Load all analytics data
  Future<void> loadAllAnalytics() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      // Fetch all analytics in parallel for better performance
      final results = await Future.wait([
        _analyticsService.getOverview(),
        _analyticsService.getOrdersByPickupPoint(),
        _analyticsService.getTopProducts(),
        _analyticsService.getTopVendors(),
      ]);

      state = state.copyWith(
        overview: results[0] as AdminAnalyticsOverview?,
        ordersByPickupPoint: results[1] as List<OrdersByPickupPoint>,
        topProducts: results[2] as List<TopProduct>,
        topVendors: results[3] as List<TopVendor>,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Load only overview data
  Future<void> loadOverview() async {
    try {
      final overview = await _analyticsService.getOverview();
      state = state.copyWith(overview: overview);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  /// Load only orders by pickup point
  Future<void> loadOrdersByPickupPoint() async {
    try {
      final data = await _analyticsService.getOrdersByPickupPoint();
      state = state.copyWith(ordersByPickupPoint: data);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  /// Load only top products
  Future<void> loadTopProducts() async {
    try {
      final data = await _analyticsService.getTopProducts();
      state = state.copyWith(topProducts: data);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  /// Load only top vendors
  Future<void> loadTopVendors() async {
    try {
      final data = await _analyticsService.getTopVendors();
      state = state.copyWith(topVendors: data);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  /// Refresh all analytics data
  Future<void> refresh() async {
    await loadAllAnalytics();
  }
}

final analyticsServiceProvider = Provider<AnalyticsService>((ref) {
  return AnalyticsService();
});

final analyticsProvider = StateNotifierProvider<AnalyticsNotifier, AnalyticsState>((ref) {
  final analyticsService = ref.watch(analyticsServiceProvider);
  final notifier = AnalyticsNotifier(analyticsService);
  // Auto-load analytics on initialization
  Future.microtask(() => notifier.loadAllAnalytics());
  return notifier;
});
