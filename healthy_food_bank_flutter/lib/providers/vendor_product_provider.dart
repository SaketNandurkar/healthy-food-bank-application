import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/product.dart';
import '../services/product_service.dart';
import 'product_provider.dart';

final vendorProductsProvider =
    StateNotifierProvider<VendorProductsNotifier, VendorProductsState>((ref) {
  return VendorProductsNotifier(ref.read(productServiceProvider));
});

class VendorProductsState {
  final List<Product> products;
  final List<Product> filteredProducts;
  final bool isLoading;
  final String? error;
  final String searchQuery;
  final String? selectedCategory;

  const VendorProductsState({
    this.products = const [],
    this.filteredProducts = const [],
    this.isLoading = false,
    this.error,
    this.searchQuery = '',
    this.selectedCategory,
  });

  int get totalProducts => products.length;
  int get inStockCount => products.where((p) => p.isInStock).length;
  int get lowStockCount => products.where((p) => p.isLowStock).length;
  int get outOfStockCount => products.where((p) => p.isOutOfStock).length;
  List<Product> get lowStockProducts =>
      products.where((p) => p.isLowStock || p.isOutOfStock).toList();

  VendorProductsState copyWith({
    List<Product>? products,
    List<Product>? filteredProducts,
    bool? isLoading,
    String? error,
    String? searchQuery,
    String? selectedCategory,
  }) {
    return VendorProductsState(
      products: products ?? this.products,
      filteredProducts: filteredProducts ?? this.filteredProducts,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedCategory: selectedCategory,
    );
  }
}

class VendorProductsNotifier extends StateNotifier<VendorProductsState> {
  final ProductService _service;

  VendorProductsNotifier(this._service) : super(const VendorProductsState());

  Future<void> loadProducts(int userId) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final products = await _service.getProductsByUser(userId);
      state = state.copyWith(products: products, isLoading: false);
      _applyFilters();
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString().replaceFirst('Exception: ', ''),
      );
    }
  }

  Future<bool> createProduct(Map<String, dynamic> data, int userId) async {
    try {
      await _service.createProduct(data);
      await loadProducts(userId);
      return true;
    } catch (e) {
      state = state.copyWith(
        error: e.toString().replaceFirst('Exception: ', ''),
      );
      return false;
    }
  }

  Future<bool> updateProduct(int id, Map<String, dynamic> data, int userId) async {
    try {
      await _service.updateProduct(id, data);
      await loadProducts(userId);
      return true;
    } catch (e) {
      state = state.copyWith(
        error: e.toString().replaceFirst('Exception: ', ''),
      );
      return false;
    }
  }

  Future<bool> deleteProduct(int id, int userId) async {
    try {
      await _service.deleteProduct(id);
      await loadProducts(userId);
      return true;
    } catch (e) {
      state = state.copyWith(
        error: e.toString().replaceFirst('Exception: ', ''),
      );
      return false;
    }
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
    _applyFilters();
  }

  void setCategory(String? category) {
    state = state.copyWith(selectedCategory: category);
    _applyFilters();
  }

  void _applyFilters() {
    var filtered = List<Product>.from(state.products);

    if (state.searchQuery.isNotEmpty) {
      final query = state.searchQuery.toLowerCase();
      filtered = filtered.where((p) {
        return p.name.toLowerCase().contains(query) ||
            (p.description?.toLowerCase().contains(query) ?? false);
      }).toList();
    }

    if (state.selectedCategory != null && state.selectedCategory!.isNotEmpty) {
      filtered = filtered
          .where((p) => p.category?.toUpperCase() == state.selectedCategory!.toUpperCase())
          .toList();
    }

    filtered.sort((a, b) => a.name.compareTo(b.name));

    state = state.copyWith(filteredProducts: filtered);
  }
}
