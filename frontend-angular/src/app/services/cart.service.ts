import { Injectable } from '@angular/core';
import { BehaviorSubject, Observable } from 'rxjs';
import { Cart, CartItem, Order, OrderItem } from '../models/cart.model';
import { Product } from '../models/product.model';

@Injectable({
  providedIn: 'root'
})
export class CartService {
  private cart: Cart = {
    items: [],
    totalQuantity: 0,
    totalAmount: 0
  };

  private cartSubject: BehaviorSubject<Cart> = new BehaviorSubject<Cart>(this.cart);
  public cart$: Observable<Cart> = this.cartSubject.asObservable();

  constructor() {
    this.loadCartFromStorage();
  }

  addToCart(product: Product, quantity: number = 1): void {
    const existingItemIndex = this.cart.items.findIndex(
      item => item.product.id === product.id
    );

    if (existingItemIndex > -1) {
      this.cart.items[existingItemIndex].quantity += quantity;
      this.cart.items[existingItemIndex].totalPrice = 
        this.cart.items[existingItemIndex].quantity * product.price;
    } else {
      const cartItem: CartItem = {
        product: product,
        quantity: quantity,
        totalPrice: product.price * quantity
      };
      this.cart.items.push(cartItem);
    }

    this.updateCartTotals();
    this.saveCartToStorage();
    this.cartSubject.next(this.cart);
  }

  removeFromCart(productId: number): void {
    this.cart.items = this.cart.items.filter(item => item.product.id !== productId);
    this.updateCartTotals();
    this.saveCartToStorage();
    this.cartSubject.next(this.cart);
  }

  updateQuantity(productId: number, quantity: number): void {
    if (quantity <= 0) {
      this.removeFromCart(productId);
      return;
    }

    const itemIndex = this.cart.items.findIndex(item => item.product.id === productId);
    if (itemIndex > -1) {
      this.cart.items[itemIndex].quantity = quantity;
      this.cart.items[itemIndex].totalPrice = 
        this.cart.items[itemIndex].product.price * quantity;
      
      this.updateCartTotals();
      this.saveCartToStorage();
      this.cartSubject.next(this.cart);
    }
  }

  clearCart(): void {
    this.cart = {
      items: [],
      totalQuantity: 0,
      totalAmount: 0
    };
    this.saveCartToStorage();
    this.cartSubject.next(this.cart);
  }

  getCartItems(): CartItem[] {
    return this.cart.items;
  }

  getCartTotal(): number {
    return this.cart.totalAmount;
  }

  getCartItemCount(): number {
    return this.cart.totalQuantity;
  }

  isProductInCart(productId: number): boolean {
    return this.cart.items.some(item => item.product.id === productId);
  }

  getProductQuantityInCart(productId: number): number {
    const item = this.cart.items.find(item => item.product.id === productId);
    return item ? item.quantity : 0;
  }

  createOrder(customerId: number, customerName: string, deliveryAddress: string, contactNumber: string): Order {
    const orderItems: OrderItem[] = this.cart.items.map(cartItem => ({
      productId: cartItem.product.id,
      productName: cartItem.product.name,
      vendorId: cartItem.product.vendorId,
      quantity: cartItem.quantity,
      unitPrice: cartItem.product.price,
      totalPrice: cartItem.totalPrice
    }));

    return {
      customerId: customerId,
      customerName: customerName,
      items: orderItems,
      totalAmount: this.cart.totalAmount,
      orderStatus: 'PENDING' as any,
      deliveryAddress: deliveryAddress,
      contactNumber: contactNumber
    };
  }

  private updateCartTotals(): void {
    this.cart.totalQuantity = this.cart.items.reduce((total, item) => total + item.quantity, 0);
    this.cart.totalAmount = this.cart.items.reduce((total, item) => total + item.totalPrice, 0);
  }

  private saveCartToStorage(): void {
    localStorage.setItem('cart', JSON.stringify(this.cart));
  }

  private loadCartFromStorage(): void {
    const savedCart = localStorage.getItem('cart');
    if (savedCart) {
      try {
        this.cart = JSON.parse(savedCart);
        this.cartSubject.next(this.cart);
      } catch (error) {
        console.error('Error loading cart from storage:', error);
        this.clearCart();
      }
    }
  }
}