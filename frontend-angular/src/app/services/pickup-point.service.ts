import { Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Observable } from 'rxjs';
import { PickupPoint } from '../models/pickup-point.model';
import { environment } from '../../environments/environment';

@Injectable({
  providedIn: 'root'
})
export class PickupPointService {
  private apiUrl = `${environment.userServiceUrl}/pickup-points`;

  constructor(private http: HttpClient) {}

  getAllPickupPoints(): Observable<PickupPoint[]> {
    return this.http.get<PickupPoint[]>(this.apiUrl);
  }

  getActivePickupPoints(): Observable<PickupPoint[]> {
    return this.http.get<PickupPoint[]>(`${this.apiUrl}/active`);
  }

  getPickupPointById(id: number): Observable<PickupPoint> {
    return this.http.get<PickupPoint>(`${this.apiUrl}/${id}`);
  }

  createPickupPoint(pickupPoint: PickupPoint): Observable<PickupPoint> {
    return this.http.post<PickupPoint>(this.apiUrl, pickupPoint);
  }

  updatePickupPoint(id: number, pickupPoint: PickupPoint): Observable<PickupPoint> {
    return this.http.put<PickupPoint>(`${this.apiUrl}/${id}`, pickupPoint);
  }

  deletePickupPoint(id: number): Observable<void> {
    return this.http.delete<void>(`${this.apiUrl}/${id}`);
  }

  deactivatePickupPoint(id: number): Observable<PickupPoint> {
    return this.http.put<PickupPoint>(`${this.apiUrl}/${id}/deactivate`, {});
  }

  activatePickupPoint(id: number): Observable<PickupPoint> {
    return this.http.put<PickupPoint>(`${this.apiUrl}/${id}/activate`, {});
  }
}
