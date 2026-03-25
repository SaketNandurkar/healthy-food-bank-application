export interface Order {
  id?: number;
  orderName: string;
  orderQuantity: number;
  orderUnit: string;
  orderPrice: number;
  orderPlacedDate?: Date;
  orderDeliveredDate?: Date;
  customerId?: number;
  orderStatus?: OrderStatus;
  productId?: number;
  vendorId?: string;
  productName?: string;
  customerName?: string;
  customerPhone?: string;
  customerPickupPoint?: string;
}

export interface OrderDTO {
  id: number;
  orderName: string;
  orderQuantity: number;
  orderUnit: string;
  orderPrice: number;
  orderPlacedDate: Date;
  orderDeliveredDate?: Date;
  customerId: number;
  orderStatus: OrderStatus;
  productId?: number;
  vendorId?: string;
  productName?: string;
  customerName?: string;
  customerPhone?: string;
  customerPickupPoint?: string;
}

export enum OrderStatus {
  PENDING = 'PENDING',
  PROCESSING = 'PROCESSING',
  DELIVERED = 'DELIVERED',
  CANCELLED = 'CANCELLED',
  ISSUED = 'ISSUED',
  SCHEDULED = 'SCHEDULED',
  CANCELLED_BY_VENDOR = 'CANCELLED_BY_VENDOR'
}