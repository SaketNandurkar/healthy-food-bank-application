export type UserRole = 'customer' | 'vendor' | 'admin';

export interface Product {
  id: string;
  name: string;
  price: number;
  unit: string;
  image: string;
  category: string;
  vendor: string;
  stock: number;
  status: 'in-stock' | 'low-stock' | 'out-of-stock';
}

export interface Order {
  id: string;
  productName: string;
  price: number;
  quantity: number;
  status: 'pending' | 'processing' | 'scheduled' | 'completed';
  estimatedDelivery?: string;
  orderId: string;
  image: string;
}

export type Screen = 
  | 'splash' 
  | 'login' 
  | 'register' 
  | 'home' 
  | 'cart' 
  | 'orders' 
  | 'profile' 
  | 'stock-management' 
  | 'vendor-management' 
  | 'order-management';
