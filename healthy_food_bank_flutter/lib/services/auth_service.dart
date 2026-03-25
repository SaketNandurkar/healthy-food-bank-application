import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';
import '../models/user.dart';
import 'api_client.dart';

class AuthService {
  final ApiClient _api = ApiClient();

  Future<LoginResponse> login(LoginRequest request) async {
    final response = await _api.post(ApiConfig.authenticate, body: request.toJson());
    if (!response.success) throw Exception(response.error);

    final data = response.data;
    final token = data['token'] ?? '';
    final userData = data['user'] ?? data;
    final user = User.fromJson(userData is Map<String, dynamic> ? userData : data);

    await _api.setToken(token);
    if (user.id != null) await _api.setUserId(user.id!);

    // Persist user data (store only the user object, not the full response)
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('currentUser', jsonEncode(userData is Map<String, dynamic> ? userData : data));

    return LoginResponse(token: token, user: user);
  }

  Future<String> register(User user, {String? vendorCode}) async {
    String url = ApiConfig.register;
    if (vendorCode != null && vendorCode.isNotEmpty) {
      url = '${ApiConfig.register}?vendorCode=$vendorCode';
    }
    final response = await _api.post(url, body: user.toJson());
    if (!response.success) throw Exception(response.error);
    return response.data is String ? response.data : 'Registration successful';
  }

  Future<bool> validateVendorCode(String code) async {
    final response = await _api.get('${ApiConfig.validateVendorCode}/$code');
    return response.success;
  }

  Future<User> updateProfile(int userId, Map<String, dynamic> data) async {
    final response = await _api.put(ApiConfig.updateProfile(userId), body: data);
    if (!response.success) throw Exception(response.error);
    return User.fromJson(response.data);
  }

  Future<void> changePassword(int userId, String currentPassword, String newPassword) async {
    final response = await _api.put(
      ApiConfig.changePassword(userId),
      body: {'currentPassword': currentPassword, 'newPassword': newPassword},
    );
    if (!response.success) throw Exception(response.error);
  }

  Future<User?> getStoredUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString('currentUser');
    if (userJson == null) return null;

    await _api.loadStoredAuth();
    if (_api.token == null) return null;

    try {
      return User.fromJson(jsonDecode(userJson));
    } catch (_) {
      return null;
    }
  }

  Future<void> logout() async {
    await _api.clearAuth();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('currentUser');
    await prefs.remove('cart');
  }
}
