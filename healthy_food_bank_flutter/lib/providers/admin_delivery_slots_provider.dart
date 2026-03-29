import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/delivery_slot.dart';
import '../services/admin_service.dart';
import 'admin_service_provider.dart';

class DeliverySlotsState {
  final List<DeliverySlot> deliverySlots;
  final List<DeliverySlot> filteredSlots;
  final bool isLoading;
  final bool isActioning;
  final String? error;
  final String? statusFilter; // 'All', 'Active', 'Inactive'
  final String searchQuery;

  DeliverySlotsState({
    this.deliverySlots = const [],
    this.filteredSlots = const [],
    this.isLoading = false,
    this.isActioning = false,
    this.error,
    this.statusFilter = 'All',
    this.searchQuery = '',
  });

  DeliverySlotsState copyWith({
    List<DeliverySlot>? deliverySlots,
    List<DeliverySlot>? filteredSlots,
    bool? isLoading,
    bool? isActioning,
    String? error,
    String? statusFilter,
    String? searchQuery,
  }) {
    return DeliverySlotsState(
      deliverySlots: deliverySlots ?? this.deliverySlots,
      filteredSlots: filteredSlots ?? this.filteredSlots,
      isLoading: isLoading ?? this.isLoading,
      isActioning: isActioning ?? this.isActioning,
      error: error,
      statusFilter: statusFilter ?? this.statusFilter,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

class DeliverySlotsNotifier extends StateNotifier<DeliverySlotsState> {
  final AdminService _adminService;

  DeliverySlotsNotifier(this._adminService) : super(DeliverySlotsState());

  Future<void> loadSlots() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final slots = await _adminService.getDeliverySlots();
      state = state.copyWith(
        deliverySlots: slots,
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
    var filtered = state.deliverySlots;

    // Apply status filter
    if (state.statusFilter != null && state.statusFilter != 'All') {
      if (state.statusFilter == 'Active') {
        filtered = filtered.where((slot) => slot.active).toList();
      } else if (state.statusFilter == 'Inactive') {
        filtered = filtered.where((slot) => !slot.active).toList();
      }
    }

    // Apply search filter (search by date string)
    if (state.searchQuery.isNotEmpty) {
      final query = state.searchQuery.toLowerCase();
      filtered = filtered.where((slot) {
        final dateStr = '${slot.deliveryDate.year}-${slot.deliveryDate.month.toString().padLeft(2, '0')}-${slot.deliveryDate.day.toString().padLeft(2, '0')}';
        return dateStr.contains(query);
      }).toList();
    }

    state = state.copyWith(filteredSlots: filtered);
  }

  Future<void> createSlot(DeliverySlot slot) async {
    state = state.copyWith(isActioning: true, error: null);

    try {
      final newSlot = await _adminService.createDeliverySlot(slot);
      final updatedSlots = [...state.deliverySlots, newSlot];
      state = state.copyWith(
        deliverySlots: updatedSlots,
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

  Future<void> updateSlot(int id, DeliverySlot slot) async {
    state = state.copyWith(isActioning: true, error: null);

    try {
      final updatedSlot = await _adminService.updateDeliverySlot(id, slot);
      final updatedSlots = state.deliverySlots.map((s) {
        return s.id == id ? updatedSlot : s;
      }).toList();

      state = state.copyWith(
        deliverySlots: updatedSlots,
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

  Future<void> toggleSlot(int id) async {
    state = state.copyWith(isActioning: true, error: null);

    try {
      final toggledSlot = await _adminService.toggleDeliverySlot(id);
      final updatedSlots = state.deliverySlots.map((s) {
        return s.id == id ? toggledSlot : s;
      }).toList();

      state = state.copyWith(
        deliverySlots: updatedSlots,
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

  Future<void> deleteSlot(int id) async {
    state = state.copyWith(isActioning: true, error: null);

    try {
      await _adminService.deleteDeliverySlot(id);
      final updatedSlots =
          state.deliverySlots.where((s) => s.id != id).toList();

      state = state.copyWith(
        deliverySlots: updatedSlots,
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
    await loadSlots();
  }
}

final deliverySlotsProvider =
    StateNotifierProvider<DeliverySlotsNotifier, DeliverySlotsState>((ref) {
  final adminService = ref.watch(adminServiceProvider);
  final notifier = DeliverySlotsNotifier(adminService);
  Future.microtask(() => notifier.loadSlots());
  return notifier;
});
