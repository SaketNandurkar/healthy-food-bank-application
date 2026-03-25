import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/pickup_point.dart';
import '../services/pickup_point_service.dart';

final pickupPointServiceProvider = Provider((ref) => PickupPointService());

final customerPickupPointsProvider =
    StateNotifierProvider<CustomerPickupPointsNotifier, CustomerPickupPointsState>((ref) {
  return CustomerPickupPointsNotifier(ref.read(pickupPointServiceProvider));
});

class CustomerPickupPointsState {
  final List<PickupPoint> pickupPoints;
  final PickupPoint? activePickupPoint;
  final bool isLoading;
  final String? error;

  const CustomerPickupPointsState({
    this.pickupPoints = const [],
    this.activePickupPoint,
    this.isLoading = false,
    this.error,
  });

  CustomerPickupPointsState copyWith({
    List<PickupPoint>? pickupPoints,
    PickupPoint? activePickupPoint,
    bool clearActive = false,
    bool? isLoading,
    String? error,
  }) {
    return CustomerPickupPointsState(
      pickupPoints: pickupPoints ?? this.pickupPoints,
      activePickupPoint: clearActive ? null : (activePickupPoint ?? this.activePickupPoint),
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class CustomerPickupPointsNotifier extends StateNotifier<CustomerPickupPointsState> {
  final PickupPointService _service;

  CustomerPickupPointsNotifier(this._service) : super(const CustomerPickupPointsState());

  Future<void> loadPickupPoints(int customerId) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final points = await _service.getCustomerPickupPoints(customerId);

      // Determine active from enriched data (active flag set by service join)
      PickupPoint? active;
      for (final p in points) {
        if (p.active) {
          active = p;
          break;
        }
      }

      state = CustomerPickupPointsState(
        pickupPoints: points,
        activePickupPoint: active,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString().replaceFirst('Exception: ', ''),
      );
    }
  }

  /// Lightweight load — only fetches the active pickup point (for dashboard).
  Future<void> loadActiveOnly(int customerId) async {
    try {
      final active = await _service.getCustomerActivePickupPoint(customerId);
      if (active != null) {
        state = state.copyWith(activePickupPoint: active);
      }
    } catch (_) {}
  }

  Future<bool> setActive(int customerId, int pickupPointId) async {
    try {
      await _service.setActivePickupPoint(customerId, pickupPointId);
      await loadPickupPoints(customerId);
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString().replaceFirst('Exception: ', ''));
      return false;
    }
  }

  Future<bool> addPickupPoint(int customerId, Map<String, dynamic> data) async {
    try {
      await _service.addCustomerPickupPoint(customerId, data);
      await loadPickupPoints(customerId);
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString().replaceFirst('Exception: ', ''));
      return false;
    }
  }

  Future<bool> removePickupPoint(int customerId, int pickupPointId) async {
    try {
      await _service.deleteCustomerPickupPoint(customerId, pickupPointId);
      await loadPickupPoints(customerId);
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString().replaceFirst('Exception: ', ''));
      return false;
    }
  }
}
