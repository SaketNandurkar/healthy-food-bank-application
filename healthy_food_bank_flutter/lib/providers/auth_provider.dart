import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user.dart';
import '../services/auth_service.dart';

final authServiceProvider = Provider((ref) => AuthService());

final authStateProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref.read(authServiceProvider));
});

class AuthState {
  final User? user;
  final bool isLoading;
  final String? error;
  final bool isAuthenticated;

  const AuthState({
    this.user,
    this.isLoading = false,
    this.error,
    this.isAuthenticated = false,
  });

  AuthState copyWith({
    User? user,
    bool? isLoading,
    String? error,
    bool? isAuthenticated,
  }) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthService _authService;

  AuthNotifier(this._authService) : super(const AuthState());

  Future<bool> login(String username, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await _authService.login(
        LoginRequest(username: username, password: password),
      );
      state = AuthState(
        user: response.user,
        isAuthenticated: true,
        isLoading: false,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString().replaceFirst('Exception: ', ''),
      );
      return false;
    }
  }

  Future<String?> register(User user, {String? vendorCode}) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final message = await _authService.register(user, vendorCode: vendorCode);
      state = state.copyWith(isLoading: false);
      return message;
    } catch (e) {
      final error = e.toString().replaceFirst('Exception: ', '');
      state = state.copyWith(isLoading: false, error: error);
      return null;
    }
  }

  Future<bool> checkAuth() async {
    final user = await _authService.getStoredUser();
    if (user != null) {
      state = AuthState(user: user, isAuthenticated: true);
      return true;
    }
    return false;
  }

  Future<void> updateUser(User user) async {
    state = state.copyWith(user: user);
  }

  Future<void> logout() async {
    await _authService.logout();
    state = const AuthState();
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}
