import { Injectable } from '@angular/core';
import { Router, CanActivate, ActivatedRouteSnapshot, RouterStateSnapshot } from '@angular/router';
import { AuthService } from '../services/auth.service';

@Injectable({ providedIn: 'root' })
export class CustomerGuard implements CanActivate {
  constructor(
    private router: Router,
    private authService: AuthService
  ) {}

  canActivate(route: ActivatedRouteSnapshot, state: RouterStateSnapshot): boolean {
    if (this.authService.isCustomer()) {
      return true;
    }

    // Not a customer, redirect to appropriate dashboard
    if (this.authService.isVendor()) {
      this.router.navigate(['/vendor/dashboard']);
    } else {
      this.router.navigate(['/login']);
    }
    return false;
  }
}