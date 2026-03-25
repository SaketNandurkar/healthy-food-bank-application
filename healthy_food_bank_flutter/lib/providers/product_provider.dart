import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/product.dart';
import '../services/product_service.dart';

final productServiceProvider = Provider((ref) => ProductService());

final productListProvider = StateNotifierProvider<ProductListNotifier, ProductListState>((ref) {
  return ProductListNotifier(ref.read(productServiceProvider));
});

class ProductListState {
  final List<Product> products;
  final List<Product> filteredProducts;
  final bool isLoading;
  final String? error;
  final String searchQuery;
  final String? selectedCategory;
  final String sortBy;
  final bool sortAscending;

  const ProductListState({
    this.products = const [],
    this.filteredProducts = const [],
    this.isLoading = false,
    this.error,
    this.searchQuery = '',
    this.selectedCategory,
    this.sortBy = 'name',
    this.sortAscending = true,
  });

  ProductListState copyWith({
    List<Product>? products,
    List<Product>? filteredProducts,
    bool? isLoading,
    String? error,
    String? searchQuery,
    String? selectedCategory,
    String? sortBy,
    bool? sortAscending,
  }) {
    return ProductListState(
      products: products ?? this.products,
      filteredProducts: filteredProducts ?? this.filteredProducts,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedCategory: selectedCategory,
      sortBy: sortBy ?? this.sortBy,
      sortAscending: sortAscending ?? this.sortAscending,
    );
  }
}

class ProductListNotifier extends StateNotifier<ProductListState> {
  final ProductService _service;

  ProductListNotifier(this._service) : super(const ProductListState());

  Future<void> loadProducts({int? pickupPointId}) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      List<Product> products;
      if (pickupPointId != null) {
        products = await _service.getProductsByPickupPoint(pickupPointId);
      } else {
        products = await _service.getAllProducts();
      }
      state = state.copyWith(products: products, isLoading: false);
      _applyFilters();
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString().replaceFirst('Exception: ', ''),
      );
    }
  }

  Future<void> loadVendorProducts(String vendorId) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final products = await _service.getProductsByVendor(vendorId);
      state = state.copyWith(products: products, isLoading: false);
      _applyFilters();
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString().replaceFirst('Exception: ', ''),
      );
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

  void setSortBy(String sortBy) {
    state = state.copyWith(sortBy: sortBy);
    _applyFilters();
  }

  void toggleSortOrder() {
    state = state.copyWith(sortAscending: !state.sortAscending);
    _applyFilters();
  }

  void _applyFilters() {
    var filtered = List<Product>.from(state.products);

    // Search
    if (state.searchQuery.isNotEmpty) {
      final query = state.searchQuery.toLowerCase();
      filtered = filtered.where((p) {
        return p.name.toLowerCase().contains(query) ||
            (p.description?.toLowerCase().contains(query) ?? false) ||
            (p.vendorName?.toLowerCase().contains(query) ?? false);
      }).toList();
    }

    // Category filter
    if (state.selectedCategory != null && state.selectedCategory!.isNotEmpty) {
      filtered = filtered
          .where((p) => p.category?.toUpperCase() == state.selectedCategory!.toUpperCase())
          .toList();
    }

    // Sort
    filtered.sort((a, b) {
      int result;
      switch (state.sortBy) {
        case 'price':
          result = a.price.compareTo(b.price);
          break;
        case 'vendor':
          result = (a.vendorName ?? '').compareTo(b.vendorName ?? '');
          break;
        default:
          result = a.name.compareTo(b.name);
      }
      return state.sortAscending ? result : -result;
    });

    state = state.copyWith(filteredProducts: filtered);
  }
}
