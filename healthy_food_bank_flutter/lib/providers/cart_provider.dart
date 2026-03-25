import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/cart_item.dart';
import '../models/product.dart';

final cartProvider = StateNotifierProvider<CartNotifier, Cart>((ref) {
  return CartNotifier();
});

class CartNotifier extends StateNotifier<Cart> {
  CartNotifier() : super(Cart()) {
    _loadCart();
  }

  Future<void> _loadCart() async {
    // Cart will be rebuilt from products when user logs in
    // We store just product IDs and quantities
  }

  void addToCart(Product product, {int quantity = 1}) {
    final items = List<CartItem>.from(state.items);
    final existingIndex = items.indexWhere((item) => item.product.id == product.id);

    if (existingIndex >= 0) {
      items[existingIndex].quantity += quantity;
    } else {
      items.add(CartItem(product: product, quantity: quantity));
    }

    state = Cart(items: items);
    _saveCart();
  }

  void removeFromCart(int productId) {
    final items = state.items.where((item) => item.product.id != productId).toList();
    state = Cart(items: items);
    _saveCart();
  }

  void updateQuantity(int productId, int quantity) {
    if (quantity <= 0) {
      removeFromCart(productId);
      return;
    }

    final items = List<CartItem>.from(state.items);
    final index = items.indexWhere((item) => item.product.id == productId);
    if (index >= 0) {
      // Don't exceed stock
      final maxStock = items[index].product.stockQuantity;
      items[index].quantity = quantity > maxStock ? maxStock : quantity;
      state = Cart(items: items);
      _saveCart();
    }
  }

  void incrementQuantity(int productId) {
    final item = state.findByProductId(productId);
    if (item != null && item.quantity < item.product.stockQuantity) {
      updateQuantity(productId, item.quantity + 1);
    }
  }

  void decrementQuantity(int productId) {
    final item = state.findByProductId(productId);
    if (item != null) {
      updateQuantity(productId, item.quantity - 1);
    }
  }

  void clearCart() {
    state = Cart();
    _saveCart();
  }

  Future<void> _saveCart() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cartData = state.items.map((item) => {
        'productId': item.product.id,
        'quantity': item.quantity,
      }).toList();
      await prefs.setString('cart', jsonEncode(cartData));
    } catch (_) {}
  }
}
