import { Product, Order } from './types';

export const PRODUCTS: Product[] = [
  {
    id: '1',
    name: 'Fresh Spinach Bunch',
    price: 45,
    unit: 'bunch',
    image: 'https://images.unsplash.com/photo-1576045057995-568f588f82fb?q=80&w=800&auto=format&fit=crop',
    category: 'Vegetables',
    vendor: 'Green Farm Co.',
    stock: 45,
    status: 'in-stock'
  },
  {
    id: '2',
    name: 'Organic Carrots',
    price: 80,
    unit: 'kg',
    image: 'https://images.unsplash.com/photo-1598170845058-32b9d6a5da37?q=80&w=800&auto=format&fit=crop',
    category: 'Vegetables',
    vendor: "Nature's Best",
    stock: 5,
    status: 'low-stock'
  },
  {
    id: '3',
    name: 'Kashmiri Red Apples',
    price: 160,
    unit: 'kg',
    image: 'https://images.unsplash.com/photo-1560806887-1e4cd0b6cbd6?q=80&w=800&auto=format&fit=crop',
    category: 'Fruits',
    vendor: 'Himalayan Orchards',
    stock: 20,
    status: 'in-stock'
  },
  {
    id: '4',
    name: 'Fresh Farm Milk',
    price: 65,
    unit: '1L',
    image: 'https://images.unsplash.com/photo-1550583724-125581f77833?q=80&w=800&auto=format&fit=crop',
    category: 'Dairy',
    vendor: 'Pure Dairy',
    stock: 0,
    status: 'out-of-stock'
  },
  {
    id: '5',
    name: 'Hass Avocados',
    price: 320,
    unit: 'unit',
    image: 'https://images.unsplash.com/photo-1523049673857-eb18f1d7b578?q=80&w=800&auto=format&fit=crop',
    category: 'Produce',
    vendor: 'Premium Imports',
    stock: 12,
    status: 'in-stock'
  }
];

export const ORDERS: Order[] = [
  {
    id: 'o1',
    productName: 'Organic Vegetable Box',
    price: 34.50,
    quantity: 1,
    status: 'pending',
    estimatedDelivery: 'Today, 5:00 PM',
    orderId: '#HB-8821',
    image: 'https://images.unsplash.com/photo-1542838132-92c53300491e?q=80&w=800&auto=format&fit=crop'
  },
  {
    id: 'o2',
    productName: 'Farm Fresh Whole Milk',
    price: 12.20,
    quantity: 2,
    status: 'processing',
    estimatedDelivery: 'Packing in progress...',
    orderId: '#HB-8945',
    image: 'https://images.unsplash.com/photo-1550583724-125581f77833?q=80&w=800&auto=format&fit=crop'
  },
  {
    id: 'o3',
    productName: 'Weekly Fruit Pack',
    price: 45.00,
    quantity: 1,
    status: 'scheduled',
    estimatedDelivery: 'Delivery on Oct 14, 09:00 AM',
    orderId: '#HB-9102',
    image: 'https://images.unsplash.com/photo-1610832958506-aa56368176cf?q=80&w=800&auto=format&fit=crop'
  }
];
