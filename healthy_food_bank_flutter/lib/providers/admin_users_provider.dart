import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user.dart';
import '../services/admin_service.dart';
import 'admin_service_provider.dart';

class UsersState {
  final List<User> users;
  final List<User> filteredUsers;
  final bool isLoading;
  final bool isActioning;
  final String? error;
  final String? roleFilter;
  final String searchQuery;

  UsersState({
    this.users = const [],
    this.filteredUsers = const [],
    this.isLoading = false,
    this.isActioning = false,
    this.error,
    this.roleFilter,
    this.searchQuery = '',
  });

  UsersState copyWith({
    List<User>? users,
    List<User>? filteredUsers,
    bool? isLoading,
    bool? isActioning,
    String? error,
    String? roleFilter,
    String? searchQuery,
  }) {
    return UsersState(
      users: users ?? this.users,
      filteredUsers: filteredUsers ?? this.filteredUsers,
      isLoading: isLoading ?? this.isLoading,
      isActioning: isActioning ?? this.isActioning,
      error: error,
      roleFilter: roleFilter ?? this.roleFilter,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

class UsersNotifier extends StateNotifier<UsersState> {
  final AdminService _adminService;

  UsersNotifier(this._adminService) : super(UsersState());

  Future<void> loadUsers({String? roleFilter}) async {
    state = state.copyWith(isLoading: true, error: null, roleFilter: roleFilter);

    try {
      final users = await _adminService.getAllUsers(roleFilter: roleFilter);
      state = state.copyWith(
        users: users,
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

  void setRoleFilter(String? filter) {
    state = state.copyWith(roleFilter: filter);
    loadUsers(roleFilter: filter);
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
    _applyFilters();
  }

  void _applyFilters() {
    var filtered = state.users;

    // Apply search filter
    if (state.searchQuery.isNotEmpty) {
      final query = state.searchQuery.toLowerCase();
      filtered = filtered.where((user) {
        final name = '${user.firstName} ${user.lastName}'.toLowerCase();
        final email = user.email?.toLowerCase() ?? '';
        final username = user.userName?.toLowerCase() ?? '';
        return name.contains(query) ||
            email.contains(query) ||
            username.contains(query);
      }).toList();
    }

    state = state.copyWith(filteredUsers: filtered);
  }

  Future<void> activateUser(int userId) async {
    state = state.copyWith(isActioning: true, error: null);

    try {
      final updatedUser = await _adminService.activateUser(userId);

      // Update user in list
      final updatedUsers = state.users.map((user) {
        return user.id == userId ? updatedUser : user;
      }).toList();

      state = state.copyWith(
        users: updatedUsers,
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

  Future<void> deactivateUser(int userId) async {
    state = state.copyWith(isActioning: true, error: null);

    try {
      final updatedUser = await _adminService.deactivateUser(userId);

      // Update user in list
      final updatedUsers = state.users.map((user) {
        return user.id == userId ? updatedUser : user;
      }).toList();

      state = state.copyWith(
        users: updatedUsers,
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
    await loadUsers(roleFilter: state.roleFilter);
  }
}

final usersProvider = StateNotifierProvider<UsersNotifier, UsersState>((ref) {
  final adminService = ref.watch(adminServiceProvider);
  final notifier = UsersNotifier(adminService);
  // Auto-load users on initialization
  Future.microtask(() => notifier.loadUsers());
  return notifier;
});
