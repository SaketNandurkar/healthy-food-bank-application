import { Component, OnInit, OnDestroy } from '@angular/core';
import { FormBuilder, FormGroup, Validators } from '@angular/forms';
import { Router } from '@angular/router';
import { AuthService } from '../../../services/auth.service';
import { ProductService } from '../../../services/product.service';
import { OrderService } from '../../../services/order.service';
import { WebSocketService } from '../../../services/websocket.service';
import { Product, ProductCreateRequest, ProductUpdateRequest, ProductCategory } from '../../../models/product.model';
import { User } from '../../../models/user.model';
import { OrderDTO, OrderStatus } from '../../../models/order.model';
import { Subscription } from 'rxjs';

@Component({
  selector: 'app-vendor-dashboard',
  templateUrl: './vendor-dashboard.component.html',
  styleUrls: ['./vendor-dashboard.component.css']
})
export class VendorDashboardComponent implements OnInit, OnDestroy {
  currentUser: User | null = null;
  products: Product[] = [];
  categories = Object.values(ProductCategory);
  loading = false;
  error = '';
  success = '';

  // Sidebar navigation
  activeSection: string = 'stock-management';

  // Product form
  productForm!: FormGroup;
  editingProduct: Product | null = null;
  showProductModal = false;

  // Search and filter
  searchTerm = '';
  selectedCategory = '';
  filteredProducts: Product[] = [];

  // Stats
  totalProducts = 0;
  totalValue = 0;
  lowStockProducts = 0;

  // Order notifications
  recentOrders: any[] = [];
  newOrdersCount = 0;

  // Order Management
  activeOrders: OrderDTO[] = [];
  orderHistory: OrderDTO[] = [];
  issuedOrders: OrderDTO[] = [];
  scheduledOrders: OrderDTO[] = [];
  cancelledOrders: OrderDTO[] = [];
  deliveryDates: string[] = [];
  activeOrderTab: string = 'issued';

  // Real-time updates
  private refreshInterval: any;
  autoRefreshEnabled = true;
  lastRefresh: Date = new Date();
  refreshCountdown = 30;

  // WebSocket subscriptions
  private productUpdateSubscription: Subscription = new Subscription();
  private orderNotificationSubscription: Subscription = new Subscription();

  constructor(
    private authService: AuthService,
    private productService: ProductService,
    private orderService: OrderService,
    private formBuilder: FormBuilder,
    private router: Router,
    private webSocketService: WebSocketService
  ) {}

  ngOnInit(): void {
    this.currentUser = this.authService.currentUserValue;
    this.initializeProductForm();
    this.loadVendorProducts();
    this.loadVendorOrders();
    this.startAutoRefresh();
    this.connectWebSocket();
  }

  ngOnDestroy(): void {
    this.stopAutoRefresh();
    if (this.productUpdateSubscription) {
      this.productUpdateSubscription.unsubscribe();
    }
    if (this.orderNotificationSubscription) {
      this.orderNotificationSubscription.unsubscribe();
    }
    this.webSocketService.disconnect();
  }

  private initializeProductForm(): void {
    this.productForm = this.formBuilder.group({
      name: ['', [Validators.required, Validators.minLength(2), Validators.maxLength(100)]],
      description: ['', [Validators.required, Validators.minLength(10), Validators.maxLength(500)]],
      price: ['', [Validators.required, Validators.min(0.01)]],
      unitQuantity: ['', [Validators.required, Validators.min(0.01)]],
      productUnit: ['', Validators.required],
      category: ['', Validators.required],
      stockQuantity: ['', [Validators.required, Validators.min(0)]],
      imageUrl: ['', Validators.pattern('^https?://.+')],
      deliverySchedule: ['']
    });
  }

  get f() { return this.productForm.controls; }

  loadVendorProducts(): void {
    if (!this.currentUser?.vendorId) return;

    this.loading = true;
    this.productService.getProductsByVendor(this.currentUser.vendorId).subscribe({
      next: (products) => {
        this.products = products;
        // Maintain current filters after refresh instead of showing all products
        this.filterProducts();
        this.updateStats();
        this.loading = false;
      },
      error: (error) => {
        this.error = error;
        this.loading = false;
      }
    });
  }

  private updateStats(): void {
    this.totalProducts = this.products.length;
    this.totalValue = this.products.reduce((sum, product) => sum + (product.price * product.stockQuantity), 0);
    this.lowStockProducts = this.products.filter(product => product.stockQuantity < 10).length;
  }

  filterProducts(): void {
    let filtered = this.products;

    // Filter by search term
    if (this.searchTerm.trim()) {
      const search = this.searchTerm.toLowerCase();
      filtered = filtered.filter(product => 
        product.name.toLowerCase().includes(search) ||
        product.description.toLowerCase().includes(search)
      );
    }

    // Filter by category
    if (this.selectedCategory) {
      filtered = filtered.filter(product => product.category === this.selectedCategory);
    }

    this.filteredProducts = filtered;
  }

  onSearchChange(): void {
    this.filterProducts();
  }

  onCategoryChange(): void {
    this.filterProducts();
  }

  openProductModal(product?: Product): void {
    this.editingProduct = product || null;

    if (product) {
      // Edit mode
      this.productForm.patchValue({
        name: product.name,
        description: product.description,
        price: product.price,
        unitQuantity: product.unitQuantity || 1,
        productUnit: product.productUnit || 'unit',
        category: product.category,
        stockQuantity: product.stockQuantity,
        imageUrl: product.imageUrl || '',
        deliverySchedule: product.deliverySchedule || ''
      });
    } else {
      // Create mode
      this.productForm.reset();
      this.productForm.patchValue({
        unitQuantity: 1,
        productUnit: 'unit',
        deliverySchedule: ''
      });
    }

    this.showProductModal = true;
    this.error = '';
    this.success = '';
  }

  closeProductModal(): void {
    this.showProductModal = false;
    this.editingProduct = null;
    this.productForm.reset();
    this.error = '';
    this.success = '';
  }

  onSubmitProduct(): void {
    if (this.productForm.invalid) return;

    this.loading = true;
    
    if (this.editingProduct) {
      // Update existing product
      const updateData: ProductUpdateRequest = {
        productId: this.editingProduct.id,
        productName: this.f['name'].value,
        productPrice: this.f['price'].value,
        productQuantity: this.f['stockQuantity'].value,
        productUnit: this.f['productUnit'].value,
        unitQuantity: this.f['unitQuantity'].value,
        deliverySchedule: this.f['deliverySchedule'].value || undefined,
        id: this.editingProduct.id,
        name: this.f['name'].value,
        description: this.f['description'].value,
        price: this.f['price'].value,
        category: this.f['category'].value,
        stockQuantity: this.f['stockQuantity'].value,
        imageUrl: this.f['imageUrl'].value || ''
      };

      this.productService.updateProduct(updateData).subscribe({
        next: (product) => {
          this.success = 'Product updated successfully!';
          this.loadVendorProducts();
          this.closeProductModal();
          this.loading = false;
        },
        error: (error) => {
          this.error = error;
          this.loading = false;
        }
      });
    } else {
      // Create new product
      const createData: ProductCreateRequest = {
        productName: this.f['name'].value,
        productPrice: this.f['price'].value,
        productQuantity: this.f['stockQuantity'].value,
        productUnit: this.f['productUnit'].value,
        unitQuantity: this.f['unitQuantity'].value,
        deliverySchedule: this.f['deliverySchedule'].value || undefined,
        name: this.f['name'].value,
        description: this.f['description'].value,
        price: this.f['price'].value,
        category: this.f['category'].value,
        stockQuantity: this.f['stockQuantity'].value,
        imageUrl: this.f['imageUrl'].value || ''
      };

      this.productService.createProduct(createData).subscribe({
        next: (product) => {
          this.success = 'Product created successfully!';
          this.loadVendorProducts();
          this.closeProductModal();
          this.loading = false;
        },
        error: (error) => {
          this.error = error;
          this.loading = false;
        }
      });
    }
  }

  deleteProduct(product: Product): void {
    if (confirm(`Are you sure you want to delete "${product.name}"?`)) {
      this.loading = true;
      this.productService.deleteProduct(product.id!).subscribe({
        next: () => {
          this.success = 'Product deleted successfully!';
          this.loadVendorProducts();
          this.loading = false;
        },
        error: (error) => {
          this.error = error;
          this.loading = false;
        }
      });
    }
  }

  navigateToPickupPoints(): void {
    this.router.navigate(['/vendor/pickup-points']);
  }

  logout(): void {
    // Clean up intervals before logout
    this.stopAutoRefresh();
    this.authService.logout();
  }

  getCategoryDisplayName(category: string): string {
    return category.charAt(0).toUpperCase() + category.slice(1).toLowerCase();
  }

  getStockStatusClass(stockQuantity: number): string {
    if (stockQuantity === 0) return 'text-danger';
    if (stockQuantity < 10) return 'text-warning';
    return 'text-success';
  }

  getStockStatusText(stockQuantity: number): string {
    if (stockQuantity === 0) return 'Out of Stock';
    if (stockQuantity < 10) return 'Low Stock';
    return 'In Stock';
  }

  navigateToProfile(): void {
    this.router.navigate(['/vendor/profile']);
  }

  navigateToSettings(): void {
    this.router.navigate(['/vendor/settings']);
  }

  private startAutoRefresh(): void {
    if (this.refreshInterval) {
      clearInterval(this.refreshInterval);
    }
    
    this.refreshInterval = setInterval(() => {
      if (this.autoRefreshEnabled && !this.loading && !this.showProductModal) {
        this.refreshCountdown--;
        if (this.refreshCountdown <= 0) {
          this.loadVendorProducts();
          this.refreshCountdown = 30;
          this.lastRefresh = new Date();
        }
      }
    }, 1000);
  }

  private stopAutoRefresh(): void {
    if (this.refreshInterval) {
      clearInterval(this.refreshInterval);
      this.refreshInterval = null;
    }
  }

  private connectWebSocket(): void {
    // TODO: Temporarily disabled WebSocket connections due to compilation issues
    // Will re-enable once WebSocket service is properly configured
    console.log('WebSocket connection temporarily disabled');

    // this.webSocketService.connect();
    //
    // this.productUpdateSubscription = this.webSocketService.getProductUpdates().subscribe({
    //   next: (productData) => {
    //     if (productData) {
    //       console.log('Real-time product update received:', productData);
    //       this.handleProductUpdate(productData);
    //     }
    //   },
    //   error: (error) => {
    //     console.error('WebSocket error:', error);
    //   }
    // });
  }

  private handleProductUpdate(productData: any): void {
    console.log('Processing product update:', productData);

    this.loadVendorProducts();

    if (productData.productName) {
      this.success = `Product "${productData.productName}" has been updated!`;
      setTimeout(() => this.success = '', 5000);
    }
  }

  private handleOrderNotification(orderData: any): void {
    console.log('Processing order notification:', orderData);

    // Check if this order is for the current vendor
    if (orderData.vendorId === this.currentUser?.vendorId) {
      // Add to recent orders list
      this.recentOrders.unshift({
        ...orderData,
        receivedAt: new Date()
      });

      // Keep only last 10 orders
      if (this.recentOrders.length > 10) {
        this.recentOrders = this.recentOrders.slice(0, 10);
      }

      // Update counter
      this.newOrdersCount++;

      // Show success message
      if (orderData.orderName) {
        this.success = `🔔 New order received: "${orderData.orderName}" from Customer #${orderData.customerId}`;
        setTimeout(() => this.success = '', 8000);
      }

      // Refresh active orders to show the new order
      this.loadActiveOrders();
    }
  }

  toggleAutoRefresh(): void {
    this.autoRefreshEnabled = !this.autoRefreshEnabled;
    if (this.autoRefreshEnabled) {
      this.refreshCountdown = 30;
    }
  }

  manualRefresh(): void {
    this.loadVendorProducts();
    this.loadVendorOrders();
    this.refreshCountdown = 30;
    this.lastRefresh = new Date();
  }

  loadVendorOrders(): void {
    if (!this.currentUser?.vendorId) return;

    this.loadActiveOrders();
    this.loadOrderHistory();
    this.loadIssuedOrders();
    this.loadScheduledOrders();
    this.loadCancelledOrders();
    this.loadDeliveryDates();
  }

  private loadActiveOrders(): void {
    const vendorId = this.currentUser?.vendorId;
    if (!vendorId) return;

    this.orderService.getActiveOrdersByVendorId(vendorId).subscribe({
      next: (orders) => {
        this.activeOrders = orders;
      },
      error: (error) => {
        console.error('Error loading active orders:', error);
      }
    });
  }

  private loadOrderHistory(): void {
    const vendorId = this.currentUser?.vendorId;
    if (!vendorId) return;

    this.orderService.getOrderHistoryByVendorId(vendorId).subscribe({
      next: (orders) => {
        this.orderHistory = orders;
      },
      error: (error) => {
        console.error('Error loading order history:', error);
      }
    });
  }

  private loadIssuedOrders(): void {
    const vendorId = this.currentUser?.vendorId;
    console.log('[DEBUG] loadIssuedOrders called with vendorId:', vendorId);
    if (!vendorId) {
      console.log('[DEBUG] No vendorId found, returning');
      return;
    }

    this.orderService.getIssuedOrdersByVendorId(vendorId).subscribe({
      next: (orders) => {
        console.log('[DEBUG] Received issued orders:', orders);
        console.log('[DEBUG] Number of issued orders:', orders.length);
        this.issuedOrders = orders;
      },
      error: (error) => {
        console.error('[ERROR] Error loading issued orders:', error);
      }
    });
  }

  private loadScheduledOrders(): void {
    const vendorId = this.currentUser?.vendorId;
    if (!vendorId) return;

    this.orderService.getScheduledOrdersByVendorId(vendorId).subscribe({
      next: (orders) => {
        this.scheduledOrders = orders;
      },
      error: (error) => {
        console.error('Error loading scheduled orders:', error);
      }
    });
  }

  private loadCancelledOrders(): void {
    const vendorId = this.currentUser?.vendorId;
    if (!vendorId) return;

    this.orderService.getCancelledOrdersByVendorId(vendorId).subscribe({
      next: (orders) => {
        this.cancelledOrders = orders;
      },
      error: (error) => {
        console.error('Error loading cancelled orders:', error);
      }
    });
  }

  private loadDeliveryDates(): void {
    const vendorId = this.currentUser?.vendorId;
    if (!vendorId) return;

    this.orderService.getDeliveryDates(vendorId).subscribe({
      next: (dates) => {
        this.deliveryDates = dates;
      },
      error: (error) => {
        console.error('Error loading delivery dates:', error);
      }
    });
  }

  updateOrderStatus(orderId: number, status: string): void {
    this.loading = true;
    this.orderService.updateOrderStatus(orderId, status as OrderStatus).subscribe({
      next: (updatedOrder) => {
        this.success = `Order #${orderId} status updated to ${status}`;
        this.loadVendorOrders();
        this.loading = false;
        setTimeout(() => this.success = '', 3000);
      },
      error: (error) => {
        this.error = `Failed to update order status: ${error}`;
        this.loading = false;
        setTimeout(() => this.error = '', 5000);
      }
    });
  }

  switchSection(section: string): void {
    this.activeSection = section;
    this.error = '';
    this.success = '';
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

  acceptOrder(orderId: number): void {
    if (confirm('Are you sure you want to accept this order?')) {
      this.loading = true;
      this.orderService.acceptOrder(orderId).subscribe({
        next: (updatedOrder) => {
          this.success = `Order #${orderId} has been accepted and scheduled for delivery`;
          this.loadVendorOrders();
          this.loading = false;
          setTimeout(() => this.success = '', 3000);
        },
        error: (error) => {
          this.error = `Failed to accept order: ${error}`;
          this.loading = false;
          setTimeout(() => this.error = '', 5000);
        }
      });
    }
  }

  rejectOrder(orderId: number): void {
    if (confirm('Are you sure you want to reject this order? This action cannot be undone.')) {
      this.loading = true;
      this.orderService.rejectOrder(orderId).subscribe({
        next: (updatedOrder) => {
          this.success = `Order #${orderId} has been rejected`;
          this.loadVendorOrders();
          this.loading = false;
          setTimeout(() => this.success = '', 3000);
        },
        error: (error) => {
          this.error = `Failed to reject order: ${error}`;
          this.loading = false;
          setTimeout(() => this.error = '', 5000);
        }
      });
    }
  }

  switchOrderTab(tab: string): void {
    this.activeOrderTab = tab;
  }

  downloadDeliverySheet(date: string): void {
    const vendorId = this.currentUser?.vendorId;
    if (!vendorId) return;

    this.loading = true;
    this.orderService.downloadDeliverySheet(vendorId, date).subscribe({
      next: (blob) => {
        const url = window.URL.createObjectURL(blob);
        const link = document.createElement('a');
        link.href = url;
        link.download = `delivery-sheet-${date}.pdf`;
        link.click();
        window.URL.revokeObjectURL(url);
        this.success = `Delivery sheet for ${date} downloaded successfully`;
        this.loading = false;
        setTimeout(() => this.success = '', 3000);
      },
      error: (error) => {
        this.error = `Failed to download delivery sheet: ${error}`;
        this.loading = false;
        setTimeout(() => this.error = '', 5000);
      }
    });
  }
}