import { Product } from './product.model';

export interface CartItem {
  product: Product;
  quantity: number;
  totalPrice: number;
}

export interface Cart {
  items: CartItem[];
  totalQuantity: number;
  totalAmount: number;
}

export interface Order {
  id?: number;
  customerId: number;
  customerName?: string;
  items: OrderItem[];
  totalAmount: number;
  orderStatus: OrderStatus;
  orderDate?: Date;
  deliveryAddress: string;
  contactNumber: string;
}

export interface OrderItem {
  productId: number;
  productName?: string;
  vendorId: string;
  quantity: number;
  unitPrice: number;
  totalPrice: number;
}

export enum OrderStatus {
  PENDING = 'PENDING',
  CONFIRMED = 'CONFIRMED',
  PROCESSING = 'PROCESSING',
  SHIPPED = 'SHIPPED',
  DELIVERED = 'DELIVERED',
  CANCELLED = 'CANCELLED'
}