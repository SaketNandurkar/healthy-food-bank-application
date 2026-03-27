import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/pickup_point.dart';
import '../services/admin_service.dart';
import 'admin_service_provider.dart';

class PickupPointsState {
  final List<PickupPoint> pickupPoints;
  final List<PickupPoint> filteredPickupPoints;
  final bool isLoading;
  final bool isActioning;
  final String? error;
  final String? statusFilter; // 'All', 'Active', 'Inactive'
  final String searchQuery;

  PickupPointsState({
    this.pickupPoints = const [],
    this.filteredPickupPoints = const [],
    this.isLoading = false,
    this.isActioning = false,
    this.error,
    this.statusFilter = 'All',
    this.searchQuery = '',
  });

  PickupPointsState copyWith({
    List<PickupPoint>? pickupPoints,
    List<PickupPoint>? filteredPickupPoints,
    bool? isLoading,
    bool? isActioning,
    String? error,
    String? statusFilter,
    String? searchQuery,
  }) {
    return PickupPointsState(
      pickupPoints: pickupPoints ?? this.pickupPoints,
      filteredPickupPoints: filteredPickupPoints ?? this.filteredPickupPoints,
      isLoading: isLoading ?? this.isLoading,
      isActioning: isActioning ?? this.isActioning,
      error: error,
      statusFilter: statusFilter ?? this.statusFilter,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

class PickupPointsNotifier extends StateNotifier<PickupPointsState> {
  final AdminService _adminService;

  PickupPointsNotifier(this._adminService) : super(PickupPointsState());

  Future<void> loadPickupPoints() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final pickupPoints = await _adminService.getAllPickupPoints();
      state = state.copyWith(
        pickupPoints: pickupPoints,
        isLoading: false,
      );
      _applyFilters();
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  void setStatusFilter(String filter) {
    state = state.copyWith(statusFilter: filter);
    _applyFilters();
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
    _applyFilters();
  }

  void _applyFilters() {
    var filtered = state.pickupPoints;

    // Apply status filter
    if (state.statusFilter != null && state.statusFilter != 'All') {
      if (state.statusFilter == 'Active') {
        filtered = filtered.where((point) => point.active).toList();
      } else if (state.statusFilter == 'Inactive') {
        filtered = filtered.where((point) => !point.active).toList();
      }
    }

    // Apply search filter
    if (state.searchQuery.isNotEmpty) {
      final query = state.searchQuery.toLowerCase();
      filtered = filtered.where((point) {
        final name = point.name.toLowerCase();
        final address = point.address.toLowerCase();
        return name.contains(query) || address.contains(query);
      }).toList();
    }

    state = state.copyWith(filteredPickupPoints: filtered);
  }

  Future<void> createPickupPoint(PickupPoint pickupPoint) async {
    state = state.copyWith(isActioning: true, error: null);

    try {
      final newPoint = await _adminService.createPickupPoint(pickupPoint);

      // Add to list
      final updatedPoints = [...state.pickupPoints, newPoint];

      state = state.copyWith(
        pickupPoints: updatedPoints,
        isActioning: false,
      );
      _applyFilters();
    } catch (e) {
      state = state.copyWith(
        isActioning: false,
        error: e.toString(),
      );
    }
  }

  Future<void> updatePickupPoint(int id, PickupPoint pickupPoint) async {
    state = state.copyWith(isActioning: true, error: null);

    try {
      final updatedPoint =
          await _adminService.updatePickupPoint(id, pickupPoint);

      // Update in list
      final updatedPoints = state.pickupPoints.map((point) {
        return point.id == id ? updatedPoint : point;
      }).toList();

      state = state.copyWith(
        pickupPoints: updatedPoints,
        isActioning: false,
      );
      _applyFilters();
    } catch (e) {
      state = state.copyWith(
        isActioning: false,
        error: e.toString(),
      );
    }
  }

  Future<void> deletePickupPoint(int id) async {
    state = state.copyWith(isActioning: true, error: null);

    try {
      await _adminService.deletePickupPoint(id);

      // Remove from list
      final updatedPoints =
          state.pickupPoints.where((point) => point.id != id).toList();

      state = state.copyWith(
        pickupPoints: updatedPoints,
        isActioning: false,
      );
      _applyFilters();
    } catch (e) {
      state = state.copyWith(
        isActioning: false,
        error: e.toString(),
      );
    }
  }

  Future<void> activatePickupPoint(int id) async {
    state = state.copyWith(isActioning: true, error: null);

    try {
      final updatedPoint = await _adminService.activatePickupPoint(id);

      // Update in list
      final updatedPoints = state.pickupPoints.map((point) {
        return point.id == id ? updatedPoint : point;
      }).toList();

      state = state.copyWith(
        pickupPoints: updatedPoints,
        isActioning: false,
      );
      _applyFilters();
    } catch (e) {
      state = state.copyWith(
        isActioning: false,
        error: e.toString(),
      );
    }
  }

  Future<void> deactivatePickupPoint(int id) async {
    state = state.copyWith(isActioning: true, error: null);

    try {
      final updatedPoint = await _adminService.deactivatePickupPoint(id);

      // Update in list
      final updatedPoints = state.pickupPoints.map((point) {
        return point.id == id ? updatedPoint : point;
      }).toList();

      state = state.copyWith(
        pickupPoints: updatedPoints,
        isActioning: false,
      );
      _applyFilters();
    } catch (e) {
      state = state.copyWith(
        isActioning: false,
        error: e.toString(),
      );
    }
  }

  Future<void> refresh() async {
    await loadPickupPoints();
  }
}

final pickupPointsProvider =
    StateNotifierProvider<PickupPointsNotifier, PickupPointsState>((ref) {
  final adminService = ref.watch(adminServiceProvider);
  final notifier = PickupPointsNotifier(adminService);
  // Auto-load pickup points on initialization
  Future.microtask(() => notifier.loadPickupPoints());
  return notifier;
});
