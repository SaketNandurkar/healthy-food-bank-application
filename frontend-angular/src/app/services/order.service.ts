import { Injectable } from '@angular/core';
import { HttpClient, HttpHeaders } from '@angular/common/http';
import { Observable, throwError } from 'rxjs';
import { catchError } from 'rxjs/operators';
import { Order, OrderDTO, OrderStatus } from '../models/order.model';

@Injectable({
  providedIn: 'root'
})
export class OrderService {
  private baseUrl = 'http://localhost:9092/order';

  constructor(private http: HttpClient) {}

  private getHttpOptions() {
    return {
      headers: new HttpHeaders({
        'Content-Type': 'application/json'
      })
    };
  }

  createOrder(order: Order, customerId: number): Observable<Order> {
    const headers = new HttpHeaders({
      'Content-Type': 'application/json',
      'X-Customer-Id': customerId.toString()
    });

    return this.http.post<Order>(this.baseUrl, order, { headers })
      .pipe(catchError(this.handleError));
  }

  updateOrderStatus(orderId: number, status: OrderStatus): Observable<Order> {
    const url = `${this.baseUrl}/${orderId}/status`;
    return this.http.put<Order>(url, status, this.getHttpOptions())
      .pipe(catchError(this.handleError));
  }

  deleteOrder(orderId: number): Observable<string> {
    const url = `${this.baseUrl}/${orderId}`;
    return this.http.delete<string>(url)
      .pipe(catchError(this.handleError));
  }

  getOrderById(orderId: number): Observable<Order> {
    const url = `${this.baseUrl}/${orderId}`;
    return this.http.get<Order>(url)
      .pipe(catchError(this.handleError));
  }

  getAllOrders(): Observable<OrderDTO[]> {
    return this.http.get<OrderDTO[]>(this.baseUrl)
      .pipe(catchError(this.handleError));
  }

  getOrdersByCustomerId(customerId: number): Observable<OrderDTO[]> {
    const url = `${this.baseUrl}/customer/${customerId}`;
    return this.http.get<OrderDTO[]>(url)
      .pipe(catchError(this.handleError));
  }

  getOrdersByStatus(status: OrderStatus): Observable<OrderDTO[]> {
    const url = `${this.baseUrl}/status/${status}`;
    return this.http.get<OrderDTO[]>(url)
      .pipe(catchError(this.handleError));
  }

  getOrdersByVendorId(vendorId: string): Observable<OrderDTO[]> {
    const url = `${this.baseUrl}/vendor/${vendorId}`;
    return this.http.get<OrderDTO[]>(url)
      .pipe(catchError(this.handleError));
  }

  getActiveOrdersByVendorId(vendorId: string): Observable<OrderDTO[]> {
    const url = `${this.baseUrl}/vendor/${vendorId}/active`;
    return this.http.get<OrderDTO[]>(url)
      .pipe(catchError(this.handleError));
  }

  getOrderHistoryByVendorId(vendorId: string): Observable<OrderDTO[]> {
    const url = `${this.baseUrl}/vendor/${vendorId}/history`;
    return this.http.get<OrderDTO[]>(url)
      .pipe(catchError(this.handleError));
  }

  acceptOrder(orderId: number): Observable<Order> {
    const url = `${this.baseUrl}/${orderId}/accept`;
    return this.http.post<Order>(url, null)
      .pipe(catchError(this.handleError));
  }

  rejectOrder(orderId: number): Observable<Order> {
    const url = `${this.baseUrl}/${orderId}/reject`;
    return this.http.post<Order>(url, null)
      .pipe(catchError(this.handleError));
  }

  getIssuedOrdersByVendorId(vendorId: string): Observable<OrderDTO[]> {
    const url = `${this.baseUrl}/vendor/${vendorId}/issued`;
    return this.http.get<OrderDTO[]>(url)
      .pipe(catchError(this.handleError));
  }

  getScheduledOrdersByVendorId(vendorId: string): Observable<OrderDTO[]> {
    const url = `${this.baseUrl}/vendor/${vendorId}/scheduled`;
    return this.http.get<OrderDTO[]>(url)
      .pipe(catchError(this.handleError));
  }

  getCancelledOrdersByVendorId(vendorId: string): Observable<OrderDTO[]> {
    const url = `${this.baseUrl}/vendor/${vendorId}/cancelled`;
    return this.http.get<OrderDTO[]>(url)
      .pipe(catchError(this.handleError));
  }

  getDeliveryDates(vendorId: string): Observable<string[]> {
    const url = `${this.baseUrl}/vendor/${vendorId}/delivery-dates`;
    return this.http.get<string[]>(url)
      .pipe(catchError(this.handleError));
  }

  downloadDeliverySheet(vendorId: string, date: string): Observable<Blob> {
    const url = `${this.baseUrl}/vendor/${vendorId}/delivery-sheet?date=${date}`;
    return this.http.get(url, { responseType: 'blob' })
      .pipe(catchError(this.handleError));
  }

  private handleError(error: any): Observable<never> {
    console.error('Order service error:', error);
    let errorMessage = 'An error occurred';

    if (error.error?.message) {
      errorMessage = error.error.message;
    } else if (error.message) {
      errorMessage = error.message;
    } else if (typeof error.error === 'string') {
      errorMessage = error.error;
    }

    return throwError(() => errorMessage);
  }
}