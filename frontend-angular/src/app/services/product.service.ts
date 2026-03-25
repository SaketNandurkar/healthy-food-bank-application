import { Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Observable, throwError } from 'rxjs';
import { catchError, map } from 'rxjs/operators';
import { Product, ProductCreateRequest, ProductUpdateRequest, ProductCategory } from '../models/product.model';
import { AuthService } from './auth.service';
import { environment } from '../../environments/environment';

@Injectable({
  providedIn: 'root'
})
export class ProductService {
  private apiUrl = environment.productServiceUrl;

  constructor(
    private http: HttpClient,
    private authService: AuthService
  ) {}

  getAllProducts(): Observable<Product[]> {
    const url = `${this.apiUrl}/products`;
    return this.http.get<any[]>(url)
      .pipe(
        map(products => products.map(product => this.mapBackendToFrontend(product))),
        catchError(this.handleError)
      );
  }

  getProductById(id: number): Observable<Product> {
    const url = `${this.apiUrl}/products/${id}`;
    return this.http.get<any>(url, { headers: this.authService.getAuthHeaders() })
      .pipe(
        map(product => this.mapBackendToFrontend(product)),
        catchError(this.handleError)
      );
  }

  getProductsByVendor(vendorId: string): Observable<Product[]> {
    const url = `${this.apiUrl}/products/vendor/${vendorId}`;
    return this.http.get<any[]>(url, { headers: this.authService.getAuthHeaders() })
      .pipe(
        map(products => products.map(product => this.mapBackendToFrontend(product))),
        catchError(this.handleError)
      );
  }

  getProductsByCategory(category: ProductCategory): Observable<Product[]> {
    const url = `${this.apiUrl}/products/category/${category}`;
    return this.http.get<any[]>(url, { headers: this.authService.getAuthHeaders() })
      .pipe(
        map(products => products.map(product => this.mapBackendToFrontend(product))),
        catchError(this.handleError)
      );
  }

  getProductsByPickupPoint(pickupPointId: number): Observable<Product[]> {
    const url = `${this.apiUrl}/products/by-pickup-point/${pickupPointId}`;
    return this.http.get<any[]>(url)
      .pipe(
        map(products => products.map(product => this.mapBackendToFrontend(product))),
        catchError(this.handleError)
      );
  }

  createProduct(product: ProductCreateRequest): Observable<Product> {
    const url = `${this.apiUrl}/products`;
    const currentUser = this.authService.currentUserValue;
    const backendProduct = this.mapFrontendToBackend(product);
    
    // Set vendor ID from current user
    backendProduct.vendorId = currentUser?.vendorId || 'UNKNOWN';
    
    // Add X-User-Id header for backend requirement
    const headers = this.authService.getAuthHeaders().set('X-User-Id', currentUser?.id?.toString() || '1');
    
    return this.http.post<any>(url, backendProduct, { headers })
      .pipe(
        map(this.mapBackendToFrontend),
        catchError(this.handleError)
      );
  }

  updateProduct(product: ProductUpdateRequest): Observable<Product> {
    const url = `${this.apiUrl}/products/${product.id || product.productId}`;
    const currentUser = this.authService.currentUserValue;
    const backendProduct = this.mapFrontendToBackend(product);
    
    // Set vendor ID from current user
    backendProduct.vendorId = currentUser?.vendorId || 'UNKNOWN';
    
    // Add X-User-Id header for backend requirement  
    const headers = this.authService.getAuthHeaders().set('X-User-Id', currentUser?.id?.toString() || '1');
    
    return this.http.put<any>(url, backendProduct, { headers })
      .pipe(
        map(this.mapBackendToFrontend),
        catchError(this.handleError)
      );
  }

  deleteProduct(id: number): Observable<any> {
    const url = `${this.apiUrl}/products/${id}`;
    return this.http.delete(url, { headers: this.authService.getAuthHeaders() })
      .pipe(catchError(this.handleError));
  }

  searchProducts(searchTerm: string): Observable<Product[]> {
    const url = `${this.apiUrl}/products/search?q=${encodeURIComponent(searchTerm)}`;
    return this.http.get<Product[]>(url, { headers: this.authService.getAuthHeaders() })
      .pipe(catchError(this.handleError));
  }

  getProductCategories(): ProductCategory[] {
    return Object.values(ProductCategory);
  }

  private mapBackendToFrontend(backendProduct: any): Product {
    return {
      // Backend fields
      productId: backendProduct.productId || 0,
      productName: backendProduct.productName || '',
      productPrice: backendProduct.productPrice || 0,
      productQuantity: backendProduct.productQuantity || 0,
      productUnit: backendProduct.productUnit || 'unit',
      productAdditionDate: backendProduct.productAdditionDate,
      productUpdatedDate: backendProduct.productUpdatedDate,
      productAddedBy: backendProduct.productAddedBy,

      // Frontend compatibility fields
      id: backendProduct.productId || 0,
      name: backendProduct.productName || 'Unknown Product',
      description: `${backendProduct.productName || 'Unknown Product'} - ${backendProduct.productUnit || 'unit'}`,
      price: backendProduct.productPrice || 0,
      category: backendProduct.category || ProductCategory.OTHERS, // Use actual category from backend
      stockQuantity: backendProduct.productQuantity || 0,
      vendorId: backendProduct.vendorId || backendProduct.productAddedBy?.toString() || 'unknown',
      vendorName: backendProduct.vendorName || (backendProduct.vendorId ? `Vendor ${backendProduct.vendorId}` : `Vendor ${backendProduct.productAddedBy || 'Unknown'}`),
      imageUrl: '',
      active: true,
      createdDate: backendProduct.productAdditionDate,
      updatedDate: backendProduct.productUpdatedDate,
      unitQuantity: backendProduct.unitQuantity,
      deliverySchedule: backendProduct.deliverySchedule
    };
  }

  private mapFrontendToBackend(frontendProduct: ProductCreateRequest): any {
    return {
      productName: frontendProduct.name || frontendProduct.productName,
      productPrice: frontendProduct.price || frontendProduct.productPrice,
      productQuantity: frontendProduct.stockQuantity || frontendProduct.productQuantity,
      productUnit: frontendProduct.productUnit || 'unit',
      unitQuantity: frontendProduct.unitQuantity,
      category: frontendProduct.category || ProductCategory.OTHERS, // Include category in backend mapping
      deliverySchedule: frontendProduct.deliverySchedule // Include delivery schedule
    };
  }

  private handleError(error: any) {
    console.error('Product Service Error:', error);
    let errorMessage = 'An unexpected error occurred';
    
    if (error.error instanceof ErrorEvent) {
      errorMessage = error.error.message;
    } else if (error.status) {
      switch (error.status) {
        case 400:
          errorMessage = error.error?.message || 'Invalid request';
          break;
        case 401:
          errorMessage = 'Unauthorized access. Please login again.';
          break;
        case 403:
          errorMessage = 'You do not have permission to perform this action';
          break;
        case 404:
          errorMessage = 'Product not found';
          break;
        case 409:
          errorMessage = 'Product already exists';
          break;
        case 500:
          errorMessage = 'Server error. Please try again later';
          break;
        default:
          errorMessage = `Error Code: ${error.status}\nMessage: ${error.message}`;
      }
    }
    
    return throwError(errorMessage);
  }
}