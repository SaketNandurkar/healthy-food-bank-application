import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;
  ApiClient._internal();

  final _storage = const FlutterSecureStorage();
  String? _token;
  int? _userId;

  String? get token => _token;
  int? get userId => _userId;

  Future<void> setToken(String token) async {
    _token = token;
    await _storage.write(key: 'jwt_token', value: token);
  }

  Future<void> setUserId(int userId) async {
    _userId = userId;
    await _storage.write(key: 'user_id', value: userId.toString());
  }

  Future<void> loadStoredAuth() async {
    _token = await _storage.read(key: 'jwt_token');
    final userIdStr = await _storage.read(key: 'user_id');
    if (userIdStr != null) _userId = int.tryParse(userIdStr);
  }

  Future<void> clearAuth() async {
    _token = null;
    _userId = null;
    await _storage.deleteAll();
  }

  Map<String, String> get _headers {
    final headers = <String, String>{
      'Content-Type': 'application/json',
    };
    if (_token != null) {
      headers['Authorization'] = 'Bearer $_token';
    }
    if (_userId != null) {
      headers['X-User-Id'] = _userId.toString();
      headers['X-Customer-Id'] = _userId.toString();
    }
    return headers;
  }

  Future<ApiResponse> get(String url) async {
    try {
      final response = await http.get(
        Uri.parse(url),
        headers: _headers,
      ).timeout(const Duration(seconds: 15));
      return _handleResponse(response);
    } catch (e) {
      return ApiResponse(success: false, error: _parseError(e));
    }
  }

  Future<ApiResponse> post(String url, {Map<String, dynamic>? body}) async {
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: _headers,
        body: body != null ? jsonEncode(body) : null,
      ).timeout(const Duration(seconds: 15));
      return _handleResponse(response);
    } catch (e) {
      return ApiResponse(success: false, error: _parseError(e));
    }
  }

  Future<ApiResponse> put(String url, {Map<String, dynamic>? body}) async {
    try {
      final response = await http.put(
        Uri.parse(url),
        headers: _headers,
        body: body != null ? jsonEncode(body) : null,
      ).timeout(const Duration(seconds: 15));
      return _handleResponse(response);
    } catch (e) {
      return ApiResponse(success: false, error: _parseError(e));
    }
  }

  Future<ApiResponse> delete(String url) async {
    try {
      final response = await http.delete(
        Uri.parse(url),
        headers: _headers,
      ).timeout(const Duration(seconds: 15));
      return _handleResponse(response);
    } catch (e) {
      return ApiResponse(success: false, error: _parseError(e));
    }
  }

  ApiResponse _handleResponse(http.Response response) {
    final statusCode = response.statusCode;
    dynamic data;
    try {
      data = jsonDecode(response.body);
    } catch (_) {
      data = response.body;
    }

    if (statusCode >= 200 && statusCode < 300) {
      return ApiResponse(success: true, data: data, statusCode: statusCode);
    }

    String error;
    if (data is Map) {
      error = data['message'] ?? data['error'] ?? 'Request failed';
    } else {
      error = 'Request failed with status $statusCode';
    }

    if (statusCode == 401) error = 'Session expired. Please login again.';
    if (statusCode == 403) error = 'Access denied.';
    if (statusCode == 404) error = 'Resource not found.';

    return ApiResponse(success: false, data: data, error: error, statusCode: statusCode);
  }

  String _parseError(dynamic error) {
    if (error.toString().contains('SocketException') ||
        error.toString().contains('Connection refused')) {
      return 'Cannot connect to server. Please check your connection.';
    }
    if (error.toString().contains('TimeoutException')) {
      return 'Request timed out. Please try again.';
    }
    return 'Something went wrong. Please try again.';
  }
}

class ApiResponse {
  final bool success;
  final dynamic data;
  final String? error;
  final int? statusCode;

  ApiResponse({required this.success, this.data, this.error, this.statusCode});
}
