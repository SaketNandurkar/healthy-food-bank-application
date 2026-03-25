import { Injectable } from '@angular/core';
import { HttpClient, HttpHeaders } from '@angular/common/http';
import { Observable } from 'rxjs';
import { environment } from '../../environments/environment';

export interface CustomerPickupPoint {
  id: number;
  customerId: number;
  pickupPointId: number;
  active: boolean;
  createdDate: string;
  updatedDate: string;
}

export interface AddPickupPointRequest {
  pickupPointId: number;
  makeActive: boolean;
}

export interface ApiResponse {
  success: boolean;
  message: string;
  data?: any;
  error?: string;
}

@Injectable({
  providedIn: 'root'
})
export class CustomerPickupPointService {
  private apiUrl = `${environment.userServiceUrl}/customer-pickup-points`;

  constructor(private http: HttpClient) {}

  private getHeaders(): HttpHeaders {
    const token = localStorage.getItem('token');
    return new HttpHeaders({
      'Content-Type': 'application/json',
      'Authorization': `Bearer ${token}`
    });
  }

  /**
   * Get all pickup points for a customer
   */
  getCustomerPickupPoints(customerId: number): Observable<CustomerPickupPoint[]> {
    return this.http.get<CustomerPickupPoint[]>(
      `${this.apiUrl}/${customerId}`,
      { headers: this.getHeaders() }
    );
  }

  /**
   * Get the active pickup point for a customer
   */
  getActivePickupPoint(customerId: number): Observable<CustomerPickupPoint> {
    return this.http.get<CustomerPickupPoint>(
      `${this.apiUrl}/${customerId}/active`,
      { headers: this.getHeaders() }
    );
  }

  /**
   * Add a new pickup point for a customer
   */
  addPickupPoint(customerId: number, request: AddPickupPointRequest): Observable<ApiResponse> {
    return this.http.post<ApiResponse>(
      `${this.apiUrl}/${customerId}`,
      request,
      { headers: this.getHeaders() }
    );
  }

  /**
   * Set a pickup point as active (deactivates all others)
   */
  setActivePickupPoint(customerId: number, pickupPointId: number): Observable<ApiResponse> {
    return this.http.put<ApiResponse>(
      `${this.apiUrl}/${customerId}/active/${pickupPointId}`,
      {},
      { headers: this.getHeaders() }
    );
  }

  /**
   * Delete a pickup point
   */
  deletePickupPoint(customerId: number, pickupPointId: number): Observable<ApiResponse> {
    return this.http.delete<ApiResponse>(
      `${this.apiUrl}/${customerId}/${pickupPointId}`,
      { headers: this.getHeaders() }
    );
  }
}
