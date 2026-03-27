import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/admin_service.dart';
import 'admin_service_provider.dart';

class VendorCodesState {
  final List<VendorCode> codes;
  final List<VendorCode> filteredCodes;
  final bool isLoading;
  final bool isActioning;
  final String? error;
  final String? statusFilter; // 'All', 'Active', 'Used', 'Inactive'
  final String searchQuery;

  VendorCodesState({
    this.codes = const [],
    this.filteredCodes = const [],
    this.isLoading = false,
    this.isActioning = false,
    this.error,
    this.statusFilter = 'All',
    this.searchQuery = '',
  });

  VendorCodesState copyWith({
    List<VendorCode>? codes,
    List<VendorCode>? filteredCodes,
    bool? isLoading,
    bool? isActioning,
    String? error,
    String? statusFilter,
    String? searchQuery,
  }) {
    return VendorCodesState(
      codes: codes ?? this.codes,
      filteredCodes: filteredCodes ?? this.filteredCodes,
      isLoading: isLoading ?? this.isLoading,
      isActioning: isActioning ?? this.isActioning,
      error: error,
      statusFilter: statusFilter ?? this.statusFilter,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

class VendorCodesNotifier extends StateNotifier<VendorCodesState> {
  final AdminService _adminService;

  VendorCodesNotifier(this._adminService) : super(VendorCodesState());

  Future<void> loadCodes({String? statusFilter}) async {
    state = state.copyWith(
        isLoading: true, error: null, statusFilter: statusFilter ?? 'All');

    try {
      String? apiFilter;
      if (statusFilter == 'Used') {
        apiFilter = 'used';
      } else if (statusFilter == 'Inactive') {
        apiFilter = 'unused';
      }

      final codes = await _adminService.getVendorCodes(filter: apiFilter);
      state = state.copyWith(
        codes: codes,
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
    loadCodes(statusFilter: filter);
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
    _applyFilters();
  }

  void _applyFilters() {
    var filtered = state.codes;

    // Apply status filter
    if (state.statusFilter != null && state.statusFilter != 'All') {
      if (state.statusFilter == 'Active') {
        filtered = filtered.where((code) => code.isActive && !code.isUsed).toList();
      } else if (state.statusFilter == 'Used') {
        filtered = filtered.where((code) => code.isUsed).toList();
      } else if (state.statusFilter == 'Inactive') {
        filtered = filtered.where((code) => !code.isActive).toList();
      }
    }

    // Apply search filter
    if (state.searchQuery.isNotEmpty) {
      final query = state.searchQuery.toLowerCase();
      filtered = filtered.where((code) {
        final codeStr = code.code.toLowerCase();
        final usedBy = code.usedBy?.toLowerCase() ?? '';
        return codeStr.contains(query) || usedBy.contains(query);
      }).toList();
    }

    state = state.copyWith(filteredCodes: filtered);
  }

  Future<void> createCode({String? customCode}) async {
    state = state.copyWith(isActioning: true, error: null);

    try {
      print('Creating vendor code with customCode: $customCode');
      final newCode =
          await _adminService.createVendorCode(customCode: customCode);

      print('Vendor code created successfully: ${newCode.code}');
      print('Current codes count: ${state.codes.length}');

      // Add to list
      final updatedCodes = [...state.codes, newCode];
      print('Updated codes count: ${updatedCodes.length}');

      state = state.copyWith(
        codes: updatedCodes,
        isActioning: false,
      );
      _applyFilters();

      print('After filter - filtered codes count: ${state.filteredCodes.length}');
    } catch (e) {
      print('Error creating vendor code: $e');
      state = state.copyWith(
        isActioning: false,
        error: e.toString(),
      );
      rethrow; // Re-throw so the screen can show the error
    }
  }

  Future<void> updateCode(int codeId, Map<String, dynamic> updates) async {
    state = state.copyWith(isActioning: true, error: null);

    try {
      final updatedCode = await _adminService.updateVendorCode(codeId, updates);

      // Update in list
      final updatedCodes = state.codes.map((code) {
        return code.id == codeId ? updatedCode : code;
      }).toList();

      state = state.copyWith(
        codes: updatedCodes,
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

  Future<void> deleteCode(int codeId) async {
    state = state.copyWith(isActioning: true, error: null);

    try {
      await _adminService.deleteVendorCode(codeId);

      // Remove from list
      final updatedCodes = state.codes.where((code) => code.id != codeId).toList();

      state = state.copyWith(
        codes: updatedCodes,
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
    await loadCodes(statusFilter: state.statusFilter);
  }
}

final vendorCodesProvider =
    StateNotifierProvider<VendorCodesNotifier, VendorCodesState>((ref) {
  final adminService = ref.watch(adminServiceProvider);
  final notifier = VendorCodesNotifier(adminService);
  // Auto-load codes on initialization
  Future.microtask(() => notifier.loadCodes());
  return notifier;
});
