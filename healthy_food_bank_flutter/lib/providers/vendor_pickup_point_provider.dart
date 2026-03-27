import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/pickup_point.dart';
import '../services/vendor_pickup_point_service.dart';

final vendorPickupPointServiceProvider = Provider((ref) => VendorPickupPointService());

final vendorPickupPointsProvider =
    StateNotifierProvider<VendorPickupPointsNotifier, VendorPickupPointsState>((ref) {
  return VendorPickupPointsNotifier(ref.read(vendorPickupPointServiceProvider));
});

class VendorPickupPointsState {
  final List<PickupPoint> pickupPoints;
  final List<PickupPoint> activePickupPoints;
  final bool isLoading;
  final String? error;

  const VendorPickupPointsState({
    this.pickupPoints = const [],
    this.activePickupPoints = const [],
    this.isLoading = false,
    this.error,
  });

  VendorPickupPointsState copyWith({
    List<PickupPoint>? pickupPoints,
    List<PickupPoint>? activePickupPoints,
    bool? isLoading,
    String? error,
  }) {
    return VendorPickupPointsState(
      pickupPoints: pickupPoints ?? this.pickupPoints,
      activePickupPoints: activePickupPoints ?? this.activePickupPoints,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  int get activeCount => activePickupPoints.length;
}

class VendorPickupPointsNotifier extends StateNotifier<VendorPickupPointsState> {
  final VendorPickupPointService _service;

  VendorPickupPointsNotifier(this._service) : super(const VendorPickupPointsState());

  Future<void> loadPickupPoints(String vendorId) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final points = await _service.getVendorPickupPoints(vendorId);

      // Separate active and inactive points
      final active = points.where((p) => p.active).toList();

      state = VendorPickupPointsState(
        pickupPoints: points,
        activePickupPoints: active,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString().replaceFirst('Exception: ', ''),
      );
    }
  }

  /// Lightweight load — only fetches active pickup points (for dashboard).
  Future<void> loadActiveOnly(String vendorId) async {
    try {
      final active = await _service.getActiveVendorPickupPoints(vendorId);
      state = state.copyWith(activePickupPoints: active);
    } catch (_) {}
  }

  Future<bool> addPickupPoint(String vendorId, Map<String, dynamic> data) async {
    try {
      await _service.addVendorPickupPoint(vendorId, data);
      await loadPickupPoints(vendorId);
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString().replaceFirst('Exception: ', ''));
      return false;
    }
  }

  Future<bool> togglePickupPoint(String vendorId, int pickupPointId) async {
    try {
      await _service.toggleVendorPickupPoint(vendorId, pickupPointId);
      await loadPickupPoints(vendorId);
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString().replaceFirst('Exception: ', ''));
      return false;
    }
  }

  Future<bool> removePickupPoint(String vendorId, int pickupPointId) async {
    try {
      await _service.deleteVendorPickupPoint(vendorId, pickupPointId);
      await loadPickupPoints(vendorId);
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString().replaceFirst('Exception: ', ''));
      return false;
    }
  }
}
