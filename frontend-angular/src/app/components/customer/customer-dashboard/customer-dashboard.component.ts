import { Component, OnInit, OnDestroy } from '@angular/core';
import { FormBuilder, FormGroup, Validators } from '@angular/forms';
import { Router } from '@angular/router';
import { AuthService } from '../../../services/auth.service';
import { ProductService } from '../../../services/product.service';
import { CartService } from '../../../services/cart.service';
import { OrderService } from '../../../services/order.service';
import { WebSocketService } from '../../../services/websocket.service';
import { CustomerPickupPointService } from '../../../services/customer-pickup-point.service';
import { PickupPointService } from '../../../services/pickup-point.service';
import { Product, ProductCategory } from '../../../models/product.model';
import { User } from '../../../models/user.model';
import { Cart, CartItem, Order } from '../../../models/cart.model';
import { Order as BackendOrder } from '../../../models/order.model';
import { Subscription, forkJoin } from 'rxjs';

@Component({
  selector: 'app-customer-dashboard',
  templateUrl: './customer-dashboard.component.html',
  styleUrls: ['./customer-dashboard.component.css']
})
export class CustomerDashboardComponent implements OnInit, OnDestroy {
  currentUser: User | null = null;
  products: Product[] = [];
  filteredProducts: Product[] = [];
  categories = Object.values(ProductCategory);
  loading = false;
  error = '';
  success = '';

  // Search and filter
  searchTerm = '';
  selectedCategory = '';
  sortBy = 'name';
  sortOrder = 'asc';

  // Cart
  cart: Cart = { items: [], totalQuantity: 0, totalAmount: 0 };
  showCart = false;

  // User menu
  showUserMenu = false;

  // Checkout
  showCheckout = false;
  checkoutForm!: FormGroup;
  orderProcessing = false;

  // Pickup point
  activePickupPoint: any = null;
  activePickupPointDetails: any = null;
  noActivePickupPoint = false;

  // WebSocket subscription
  private productUpdateSubscription: Subscription = new Subscription();

  constructor(
    private authService: AuthService,
    private productService: ProductService,
    public cartService: CartService,
    private orderService: OrderService,
    private formBuilder: FormBuilder,
    private webSocketService: WebSocketService,
    private customerPickupPointService: CustomerPickupPointService,
    private pickupPointService: PickupPointService,
    private router: Router
  ) {}

  ngOnInit(): void {
    this.currentUser = this.authService.currentUserValue;
    this.initializeCheckoutForm();
    this.loadProducts();
    this.subscribeToCart();
    this.connectWebSocket();
  }

  private initializeCheckoutForm(): void {
    this.checkoutForm = this.formBuilder.group({
      deliveryAddress: ['', [Validators.required, Validators.minLength(10)]],
      contactNumber: ['', [Validators.required, Validators.pattern('^[0-9]{10}$')]]
    });
  }

  private subscribeToCart(): void {
    this.cartService.cart$.subscribe(cart => {
      this.cart = cart;
    });
  }

  loadProducts(): void {
    if (!this.currentUser?.id) {
      this.error = 'User not found. Please login again.';
      return;
    }

    this.loading = true;
    this.noActivePickupPoint = false;

    // First, get the active pickup point
    this.customerPickupPointService.getActivePickupPoint(this.currentUser.id).subscribe({
      next: (activePoint) => {
        this.activePickupPoint = activePoint;
        if (activePoint && activePoint.pickupPointId) {
          // Load pickup point details
          this.loadPickupPointDetails(activePoint.pickupPointId);
          // Load products filtered by this pickup point
          this.loadProductsByPickupPoint(activePoint.pickupPointId);
        } else {
          this.loading = false;
          this.noActivePickupPoint = true;
          this.products = [];
          this.filteredProducts = [];
        }
      },
      error: (error) => {
        console.error('Error loading active pickup point:', error);
        // If no active pickup point, show message
        this.noActivePickupPoint = true;
        this.loading = false;
        this.products = [];
        this.filteredProducts = [];
      }
    });
  }

  private loadPickupPointDetails(pickupPointId: number): void {
    this.pickupPointService.getPickupPointById(pickupPointId).subscribe({
      next: (details) => {
        this.activePickupPointDetails = details;
      },
      error: (error) => {
        console.error('Error loading pickup point details:', error);
      }
    });
  }

  private loadProductsByPickupPoint(pickupPointId: number): void {
    this.productService.getProductsByPickupPoint(pickupPointId).subscribe({
      next: (products) => {
        this.products = products.filter(product => product.active !== false);
        this.filteredProducts = [...this.products];
        this.applyFiltersAndSort();
        this.loading = false;
      },
      error: (error) => {
        this.error = 'Error loading products: ' + error;
        this.loading = false;
      }
    });
  }

  navigateToPickupPoints(): void {
    this.router.navigate(['/customer/my-pickup-points']);
  }

  toggleUserMenu(): void {
    this.showUserMenu = !this.showUserMenu;
  }

  navigateToOrderHistory(): void {
    this.showUserMenu = false;
    // TODO: Create order history component
    this.error = 'Order History feature is coming soon!';
    setTimeout(() => this.error = '', 3000);
  }

  navigateToProfile(): void {
    this.showUserMenu = false;
    this.router.navigate(['/customer/profile']);
  }

  navigateToSettings(): void {
    this.showUserMenu = false;
    this.router.navigate(['/customer/settings']);
  }

  onSearchChange(): void {
    this.applyFiltersAndSort();
  }

  onCategoryChange(): void {
    this.applyFiltersAndSort();
  }

  onSortChange(): void {
    this.applyFiltersAndSort();
  }

  private applyFiltersAndSort(): void {
    let filtered = [...this.products];

    // Apply search filter
    if (this.searchTerm.trim()) {
      const search = this.searchTerm.toLowerCase();
      filtered = filtered.filter(product => 
        product.name.toLowerCase().includes(search) ||
        product.description.toLowerCase().includes(search) ||
        product.vendorName?.toLowerCase().includes(search)
      );
    }

    // Apply category filter
    if (this.selectedCategory) {
      filtered = filtered.filter(product => product.category === this.selectedCategory);
    }

    // Apply sorting
    filtered.sort((a, b) => {
      let compareValue = 0;
      
      switch (this.sortBy) {
        case 'name':
          compareValue = a.name.localeCompare(b.name);
          break;
        case 'price':
          compareValue = a.price - b.price;
          break;
        case 'vendor':
          compareValue = (a.vendorName || '').localeCompare(b.vendorName || '');
          break;
        default:
          compareValue = 0;
      }

      return this.sortOrder === 'asc' ? compareValue : -compareValue;
    });

    this.filteredProducts = filtered;
  }

  addToCart(product: Product, quantity: number = 1): void {
    if (product.stockQuantity < quantity) {
      this.error = 'Not enough stock available';
      return;
    }

    this.cartService.addToCart(product, quantity);
    this.success = `${product.name} added to cart!`;
    setTimeout(() => this.success = '', 3000);
  }

  removeFromCart(productId: number): void {
    this.cartService.removeFromCart(productId);
  }

  updateCartQuantity(productId: number, quantity: number): void {
    this.cartService.updateQuantity(productId, quantity);
  }

  toggleCart(): void {
    this.showCart = !this.showCart;
  }

  proceedToCheckout(): void {
    if (this.cart.items.length === 0) {
      this.error = 'Your cart is empty';
      return;
    }
    
    this.showCart = false;
    this.showCheckout = true;
  }

  closeCheckout(): void {
    this.showCheckout = false;
    this.checkoutForm.reset();
  }

  placeOrder(): void {
    if (this.checkoutForm.invalid) return;

    this.orderProcessing = true;

    // Create separate order for each cart item (each item can be from different vendor)
    const orderRequests = this.cart.items.map(cartItem => {
      const backendOrder: BackendOrder = {
        orderName: cartItem.product.name,
        orderQuantity: cartItem.quantity,
        orderUnit: cartItem.product.productUnit || 'kg',
        orderPrice: cartItem.totalPrice,
        productId: cartItem.product.id,
        vendorId: cartItem.product.vendorId,
        productName: cartItem.product.name
      };

      return this.orderService.createOrder(backendOrder, this.currentUser!.id!);
    });

    // Execute all order creation requests in parallel
    forkJoin(orderRequests).subscribe({
      next: (orders) => {
        console.log('All orders created successfully:', orders);
        this.success = 'Order placed successfully! You will receive a confirmation email shortly.';
        this.cartService.clearCart();
        this.closeCheckout();
        this.orderProcessing = false;
        this.loadProducts(); // Refresh products to update stock
      },
      error: (error) => {
        console.error('Error placing orders:', error);
        this.error = 'Failed to place order. Please try again.';
        this.orderProcessing = false;
      }
    });
  }

  logout(): void {
    this.authService.logout();
  }

  getCategoryDisplayName(category: string): string {
    return category.charAt(0).toUpperCase() + category.slice(1).toLowerCase();
  }

  getProductQuantityInCart(productId: number): number {
    return this.cartService.getProductQuantityInCart(productId);
  }

  isProductInCart(productId: number): boolean {
    return this.cartService.isProductInCart(productId);
  }

  clearSearch(): void {
    this.searchTerm = '';
    this.selectedCategory = '';
    this.applyFiltersAndSort();
  }

  clearCart(): void {
    this.cartService.clearCart();
  }

  private connectWebSocket(): void {
    this.webSocketService.connect();

    this.productUpdateSubscription = this.webSocketService.getProductUpdates().subscribe({
      next: (productData) => {
        if (productData) {
          console.log('Real-time product update received:', productData);
          this.handleProductUpdate(productData);
        }
      },
      error: (error) => {
        console.error('WebSocket error:', error);
      }
    });
  }

  private handleProductUpdate(productData: any): void {
    console.log('Processing product update:', productData);

    this.loadProducts();

    if (productData.productName) {
      this.success = `Product "${productData.productName}" has been updated!`;
      setTimeout(() => this.success = '', 5000);
    }
  }

  ngOnDestroy(): void {
    if (this.productUpdateSubscription) {
      this.productUpdateSubscription.unsubscribe();
    }
    this.webSocketService.disconnect();
  }

  getNextDeliveryDate(schedule: string): Date {
    const today = new Date();
    const currentDay = today.getDay(); // 0 = Sunday, 6 = Saturday
    let daysToAdd = 0;

    if (schedule === 'SATURDAY') {
      // Saturday is day 6
      if (currentDay === 6) {
        daysToAdd = 7; // Next week's Saturday
      } else {
        daysToAdd = 6 - currentDay;
      }
    } else if (schedule === 'SUNDAY') {
      // Sunday is day 0
      if (currentDay === 0) {
        daysToAdd = 7; // Next week's Sunday
      } else {
        daysToAdd = 7 - currentDay;
      }
    }

    const nextDeliveryDate = new Date(today);
    nextDeliveryDate.setDate(today.getDate() + daysToAdd);
    return nextDeliveryDate;
  }

  getDeliveryScheduleDisplayText(schedule: string | undefined): string {
    if (!schedule) {
      return '';
    }
    return schedule.charAt(0).toUpperCase() + schedule.slice(1).toLowerCase();
  }
}