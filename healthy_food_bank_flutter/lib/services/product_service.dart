import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import '../config/api_config.dart';
import '../models/product.dart';
import 'api_client.dart';

class ProductService {
  final ApiClient _api = ApiClient();

  Future<List<Product>> getAllProducts() async {
    final response = await _api.get(ApiConfig.products);
    if (!response.success) throw Exception(response.error);
    return (response.data as List).map((e) => Product.fromJson(e)).toList();
  }

  Future<List<Product>> getProductsByPickupPoint(int pickupPointId) async {
    final response = await _api.get(ApiConfig.productsByPickupPoint(pickupPointId));
    if (!response.success) throw Exception(response.error);
    return (response.data as List).map((e) => Product.fromJson(e)).toList();
  }

  Future<List<Product>> getProductsByVendor(String vendorId) async {
    final response = await _api.get(ApiConfig.productsByVendor(vendorId));
    if (!response.success) throw Exception(response.error);
    return (response.data as List).map((e) => Product.fromJson(e)).toList();
  }

  Future<List<Product>> getProductsByUser(int userId) async {
    final response = await _api.get(ApiConfig.productsByUser(userId));
    if (!response.success) throw Exception(response.error);
    return (response.data as List).map((e) => Product.fromJson(e)).toList();
  }

  Future<Product> getProductById(int id) async {
    final response = await _api.get(ApiConfig.productById(id));
    if (!response.success) throw Exception(response.error);
    return Product.fromJson(response.data);
  }

  Future<Product> createProduct(Map<String, dynamic> data) async {
    final response = await _api.post(ApiConfig.products, body: data);
    if (!response.success) throw Exception(response.error);
    return Product.fromJson(response.data);
  }

  Future<Product> updateProduct(int id, Map<String, dynamic> data) async {
    final response = await _api.put(ApiConfig.productById(id), body: data);
    if (!response.success) throw Exception(response.error);
    return Product.fromJson(response.data);
  }

  Future<void> deleteProduct(int id) async {
    final response = await _api.delete(ApiConfig.productById(id));
    if (!response.success) throw Exception(response.error);
  }

  Future<String?> uploadProductImage(XFile imageFile) async {
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse(ApiConfig.uploadProductImage),
      );

      if (_api.token != null) {
        request.headers['Authorization'] = 'Bearer ${_api.token}';
      }

      final bytes = await imageFile.readAsBytes();
      final ext = imageFile.name.split('.').last.toLowerCase();
      final mimeSubtype = switch (ext) {
        'jpg' || 'jpeg' => 'jpeg',
        'png' => 'png',
        'webp' => 'webp',
        'gif' => 'gif',
        _ => 'jpeg',
      };
      request.files.add(http.MultipartFile.fromBytes(
        'file',
        bytes,
        filename: imageFile.name,
        contentType: MediaType('image', mimeSubtype),
      ));

      final streamedResponse = await request.send().timeout(
        const Duration(seconds: 30),
      );
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = jsonDecode(response.body);
        return data['imageUrl'] as String?;
      } else {
        throw Exception('Upload failed with status ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Image upload failed: $e');
    }
  }
}
