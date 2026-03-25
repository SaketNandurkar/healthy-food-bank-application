import { Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Observable } from 'rxjs';
import { environment } from '../../environments/environment';

export interface VendorPickupPoint {
  id: number;
  vendorId: string;
  pickupPointId: number;
  active: boolean;
  createdDate: string;
  updatedDate: string;
}

export interface AddVendorPickupPointRequest {
  pickupPointId: number;
}

export interface ApiResponse {
  success: boolean;
  message: string;
  data?: any;
}

@Injectable({
  providedIn: 'root'
})
export class VendorPickupPointService {
  private apiUrl = `${environment.userServiceUrl}/vendor-pickup-points`;

  constructor(private http: HttpClient) {}

  getVendorPickupPoints(vendorId: string): Observable<VendorPickupPoint[]> {
    const encodedVendorId = encodeURIComponent(vendorId);
    return this.http.get<VendorPickupPoint[]>(`${this.apiUrl}/${encodedVendorId}`);
  }

  addPickupPoint(vendorId: string, request: AddVendorPickupPointRequest): Observable<ApiResponse> {
    const encodedVendorId = encodeURIComponent(vendorId);
    return this.http.post<ApiResponse>(`${this.apiUrl}/${encodedVendorId}`, request);
  }

  togglePickupPoint(vendorId: string, pickupPointId: number): Observable<ApiResponse> {
    const encodedVendorId = encodeURIComponent(vendorId);
    return this.http.put<ApiResponse>(`${this.apiUrl}/${encodedVendorId}/toggle/${pickupPointId}`, {});
  }

  removePickupPoint(vendorId: string, pickupPointId: number): Observable<ApiResponse> {
    const encodedVendorId = encodeURIComponent(vendorId);
    return this.http.delete<ApiResponse>(`${this.apiUrl}/${encodedVendorId}/${pickupPointId}`);
  }
}
