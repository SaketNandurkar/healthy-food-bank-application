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
}
