import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/admin_service.dart';
import 'admin_service_provider.dart';

class DashboardState {
  final UserStats? stats;
  final bool isLoading;
  final String? error;
  final DateTime? lastRefreshTime;

  DashboardState({
    this.stats,
    this.isLoading = false,
    this.error,
    this.lastRefreshTime,
  });

  DashboardState copyWith({
    UserStats? stats,
    bool? isLoading,
    String? error,
    DateTime? lastRefreshTime,
  }) {
    return DashboardState(
      stats: stats ?? this.stats,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      lastRefreshTime: lastRefreshTime ?? this.lastRefreshTime,
    );
  }
}

class DashboardNotifier extends StateNotifier<DashboardState> {
  final AdminService _adminService;

  DashboardNotifier(this._adminService) : super(DashboardState());

  Future<void> loadStats() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final stats = await _adminService.getUserStats();
      state = state.copyWith(
        stats: stats,
        isLoading: false,
        lastRefreshTime: DateTime.now(),
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> refresh() async {
    await loadStats();
  }
}

final dashboardProvider =
    StateNotifierProvider<DashboardNotifier, DashboardState>((ref) {
  final adminService = ref.watch(adminServiceProvider);
  final notifier = DashboardNotifier(adminService);
  // Auto-load stats on initialization
  Future.microtask(() => notifier.loadStats());
  return notifier;
});
