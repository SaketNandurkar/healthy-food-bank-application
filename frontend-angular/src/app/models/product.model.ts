export interface Product {
  productId: number;
  productName: string;
  productPrice: number;
  productQuantity: number;
  productUnit: string;
  unitQuantity?: number;
  productAdditionDate?: Date;
  productUpdatedDate?: Date;
  productAddedBy?: number;
  deliverySchedule?: string;

  // Frontend compatibility fields
  id: number;
  name: string;
  description: string;
  price: number;
  category: ProductCategory;
  vendorId: string;
  vendorName: string;
  stockQuantity: number;
  imageUrl: string;
  createdDate?: Date;
  updatedDate?: Date;
  active: boolean;
}

export enum ProductCategory {
  VEGETABLES = 'VEGETABLES',
  FRUITS = 'FRUITS',
  DAIRY = 'DAIRY',
  GRAINS = 'GRAINS',
  PROTEINS = 'PROTEINS',
  BEVERAGES = 'BEVERAGES',
  ORGANIC = 'ORGANIC',
  OTHERS = 'OTHERS'
}

export interface ProductCreateRequest {
  productName: string;
  productPrice: number;
  productQuantity: number;
  productUnit: string;
  unitQuantity?: number;
  deliverySchedule?: string;

  // Frontend compatibility
  name?: string;
  description?: string;
  price?: number;
  category?: ProductCategory;
  stockQuantity?: number;
  imageUrl?: string;
}

export interface ProductUpdateRequest {
  productId: number;
  productName: string;
  productPrice: number;
  productQuantity: number;
  productUnit: string;
  unitQuantity?: number;
  deliverySchedule?: string;

  // Frontend compatibility
  id?: number;
  name?: string;
  description?: string;
  price?: number;
  category?: ProductCategory;
  stockQuantity?: number;
  imageUrl?: string;
}