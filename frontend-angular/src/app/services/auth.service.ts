import { Injectable } from '@angular/core';
import { HttpClient, HttpHeaders } from '@angular/common/http';
import { Router } from '@angular/router';
import { BehaviorSubject, Observable, throwError } from 'rxjs';
import { map, catchError } from 'rxjs/operators';
import { User, UserRegistration, LoginRequest, LoginResponse, UserRole, ProfileUpdateResponse } from '../models/user.model';
import { environment } from '../../environments/environment';

@Injectable({
  providedIn: 'root'
})
export class AuthService {
  private currentUserSubject: BehaviorSubject<User | null>;
  public currentUser: Observable<User | null>;
  private apiUrl = environment.userServiceUrl;

  constructor(private http: HttpClient, private router: Router) {
    this.currentUserSubject = new BehaviorSubject<User | null>(this.getCurrentUserFromStorage());
    this.currentUser = this.currentUserSubject.asObservable();
  }

  public get currentUserValue(): User | null {
    return this.currentUserSubject.value;
  }

  register(userRegistration: UserRegistration): Observable<any> {
    let url = `${this.apiUrl}/user/new`;
    
    // Add vendor code as query parameter for vendor registration
    if (userRegistration.role === UserRole.VENDOR && userRegistration.vendorCode) {
      url += `?vendorCode=${encodeURIComponent(userRegistration.vendorCode)}`;
    }
    
    const registerData = {
      firstName: userRegistration.firstName,
      lastName: userRegistration.lastName,
      email: userRegistration.email || null,
      phoneNumber: parseInt(userRegistration.phoneNumber.toString()),
      role: userRegistration.role,
      vendorId: userRegistration.vendorId || null,
      userName: userRegistration.userName,
      password: userRegistration.password,
      roles: userRegistration.role,
      pickupPointId: userRegistration.pickupPointId || null
    };

    return this.http.post(url, registerData).pipe(
      catchError(this.handleError)
    );
  }

  login(loginRequest: LoginRequest): Observable<LoginResponse> {
    const url = `${this.apiUrl}/user/authenticate`;
    return this.http.post<LoginResponse>(url, loginRequest).pipe(
      map(response => {
        if (response && response.token) {
          // Map roles string to role enum for consistency
          const user = response.user;
          if (user.roles && !user.role) {
            user.role = user.roles as UserRole;
          }
          
          localStorage.setItem('currentUser', JSON.stringify(user));
          localStorage.setItem('token', response.token);
          this.currentUserSubject.next(user);
        }
        return response;
      }),
      catchError(this.handleError)
    );
  }

  logout(): void {
    // Clear localStorage
    localStorage.removeItem('currentUser');
    localStorage.removeItem('token');
    
    // Clear current user state
    this.currentUserSubject.next(null);
    
    // Navigate to login page
    this.router.navigate(['/login']).then(() => {
      console.log('User logged out successfully');
    });
  }

  isLoggedIn(): boolean {
    return !!this.getToken();
  }

  getToken(): string | null {
    return localStorage.getItem('token');
  }

  getUserRole(): UserRole | null {
    const user = this.currentUserValue;
    return user ? user.role : null;
  }

  isVendor(): boolean {
    return this.getUserRole() === UserRole.VENDOR;
  }

  isCustomer(): boolean {
    return this.getUserRole() === UserRole.CUSTOMER;
  }

  isAdmin(): boolean {
    return this.getUserRole() === UserRole.ADMIN;
  }

  getVendorId(): string | null {
    const user = this.currentUserValue;
    return user && user.vendorId ? user.vendorId : null;
  }

  getAuthHeaders(): HttpHeaders {
    const token = this.getToken();
    return new HttpHeaders({
      'Authorization': `Bearer ${token}`,
      'Content-Type': 'application/json'
    });
  }

  validateVendorCode(vendorCode: string): Observable<boolean> {
    const url = `${this.apiUrl}/user/validate-vendor-code/${vendorCode}`;
    return this.http.get<boolean>(url).pipe(
      catchError(error => {
        console.error('Vendor code validation error:', error);
        return throwError(false);
      })
    );
  }

  updateProfile(profileData: { firstName?: string, lastName?: string, email?: string, phoneNumber?: string }): Observable<User> {
    const user = this.currentUserValue;
    if (!user || !user.id) {
      return throwError('User not authenticated');
    }

    const url = `${this.apiUrl}/user/profile/${user.id}`;
    return this.http.put<ProfileUpdateResponse>(url, profileData, { headers: this.getAuthHeaders() }).pipe(
      map(response => {
        const updatedUser = response.user;

        // If a new token was issued, update it
        if (response.tokenRefreshed && response.newToken) {
          localStorage.setItem('token', response.newToken);
          console.log('JWT token refreshed due to username/email change');
        }

        // Update local storage and current user subject with new data
        localStorage.setItem('currentUser', JSON.stringify(updatedUser));
        this.currentUserSubject.next(updatedUser);

        return updatedUser;
      }),
      catchError(this.handleError)
    );
  }

  changePassword(currentPassword: string, newPassword: string): Observable<string> {
    const user = this.currentUserValue;
    if (!user || !user.id) {
      return throwError('User not authenticated');
    }

    const url = `${this.apiUrl}/user/password/${user.id}`;
    const passwordData = {
      currentPassword: currentPassword,
      newPassword: newPassword
    };

    return this.http.put(url, passwordData, { 
      headers: this.getAuthHeaders(),
      responseType: 'text'
    }).pipe(
      catchError(this.handleError)
    );
  }

  private getCurrentUserFromStorage(): User | null {
    const userStr = localStorage.getItem('currentUser');
    if (userStr) {
      try {
        const user = JSON.parse(userStr);
        // Map roles string to role enum for consistency if needed
        if (user.roles && !user.role) {
          user.role = user.roles as UserRole;
        }
        return user;
      } catch (error) {
        localStorage.removeItem('currentUser');
        return null;
      }
    }
    return null;
  }

  private handleError(error: any) {
    console.error('Auth Service Error:', error);
    let errorMessage = 'An unexpected error occurred';
    
    if (error.error instanceof ErrorEvent) {
      errorMessage = error.error.message;
    } else if (error.status) {
      switch (error.status) {
        case 400:
          errorMessage = error.error?.message || 'Invalid request';
          break;
        case 401:
          errorMessage = 'Invalid username or password';
          break;
        case 403:
          errorMessage = 'Access denied';
          break;
        case 409:
          errorMessage = 'User already exists';
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