import { Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Observable, throwError } from 'rxjs';
import { catchError } from 'rxjs/operators';
import { VendorCode } from '../models/vendor-code.model';
import { AuthService } from './auth.service';
import { environment } from '../../environments/environment';

@Injectable({
  providedIn: 'root'
})
export class VendorCodeService {
  private apiUrl = environment.userServiceUrl;

  constructor(
    private http: HttpClient,
    private authService: AuthService
  ) {}

  getAllVendorCodes(): Observable<VendorCode[]> {
    const url = `${this.apiUrl}/user/admin/vendor-codes`;
    return this.http.get<VendorCode[]>(url, { headers: this.authService.getAuthHeaders() })
      .pipe(catchError(this.handleError));
  }

  getUnusedVendorCodes(): Observable<VendorCode[]> {
    const url = `${this.apiUrl}/user/admin/vendor-codes/unused`;
    return this.http.get<VendorCode[]>(url, { headers: this.authService.getAuthHeaders() })
      .pipe(catchError(this.handleError));
  }

  getUsedVendorCodes(): Observable<VendorCode[]> {
    const url = `${this.apiUrl}/user/admin/vendor-codes/used`;
    return this.http.get<VendorCode[]>(url, { headers: this.authService.getAuthHeaders() })
      .pipe(catchError(this.handleError));
  }

  createVendorCode(vendorCode: VendorCode): Observable<VendorCode> {
    const url = `${this.apiUrl}/user/admin/vendor-codes`;
    const headers = this.authService.getAuthHeaders();
    
    console.log('Creating vendor code with URL:', url);
    console.log('Headers:', headers);
    console.log('Payload:', vendorCode);
    
    return this.http.post<VendorCode>(url, vendorCode, { headers })
      .pipe(catchError(this.handleError));
  }

  updateVendorCode(id: number, vendorCode: VendorCode): Observable<VendorCode> {
    const url = `${this.apiUrl}/user/admin/vendor-codes/${id}`;
    return this.http.put<VendorCode>(url, vendorCode, { headers: this.authService.getAuthHeaders() })
      .pipe(catchError(this.handleError));
  }

  deactivateVendorCode(id: number): Observable<string> {
    const url = `${this.apiUrl}/user/admin/vendor-codes/${id}`;
    return this.http.delete<string>(url, { headers: this.authService.getAuthHeaders() })
      .pipe(catchError(this.handleError));
  }

  validateVendorCode(vendorCode: string): Observable<boolean> {
    const url = `${this.apiUrl}/user/validate-vendor-code/${vendorCode}`;
    return this.http.get<boolean>(url)
      .pipe(catchError(this.handleError));
  }

  private handleError(error: any) {
    console.error('Vendor Code Service Error:', error);
    let errorMessage = 'An unexpected error occurred';
    
    if (error.error instanceof ErrorEvent) {
      errorMessage = error.error.message;
    } else if (error.status) {
      switch (error.status) {
        case 400:
          errorMessage = error.error?.message || 'Invalid request data';
          break;
        case 401:
          errorMessage = 'Unauthorized access. Please login again.';
          break;
        case 403:
          errorMessage = 'Access denied. Admin privileges required.';
          break;
        case 404:
          errorMessage = 'Vendor code not found';
          break;
        case 409:
          errorMessage = 'Vendor code or ID already exists';
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