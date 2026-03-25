import { NgModule } from '@angular/core';
import { RouterModule, Routes } from '@angular/router';
import { LoginComponent } from './components/auth/login/login.component';
import { RegisterComponent } from './components/auth/register/register.component';
import { VendorDashboardComponent } from './components/vendor/vendor-dashboard/vendor-dashboard.component';
import { VendorProfileComponent } from './components/vendor/vendor-profile/vendor-profile.component';
import { VendorSettingsComponent } from './components/vendor/vendor-settings/vendor-settings.component';
import { VendorPickupPointsComponent } from './components/vendor/vendor-pickup-points/vendor-pickup-points.component';
import { CustomerDashboardComponent } from './components/customer/customer-dashboard/customer-dashboard.component';
import { MyPickupPointsComponent } from './components/customer/my-pickup-points/my-pickup-points.component';
import { CustomerProfileComponent } from './components/customer/customer-profile/customer-profile.component';
import { CustomerSettingsComponent } from './components/customer/customer-settings/customer-settings.component';
import { AdminDashboardComponent } from './components/admin/admin-dashboard/admin-dashboard.component';
import { AuthGuard } from './guards/auth.guard';
import { VendorGuard } from './guards/vendor.guard';
import { CustomerGuard } from './guards/customer.guard';
import { AdminGuard } from './guards/admin.guard';

const routes: Routes = [
  { path: '', redirectTo: '/login', pathMatch: 'full' },
  { path: 'login', component: LoginComponent },
  { path: 'register', component: RegisterComponent },
  {
    path: 'vendor',
    canActivate: [AuthGuard, VendorGuard],
    children: [
      { path: '', redirectTo: 'dashboard', pathMatch: 'full' },
      { path: 'dashboard', component: VendorDashboardComponent },
      { path: 'profile', component: VendorProfileComponent },
      { path: 'pickup-points', component: VendorPickupPointsComponent },
      { path: 'settings', component: VendorSettingsComponent }
    ]
  },
  {
    path: 'customer',
    canActivate: [AuthGuard, CustomerGuard],
    children: [
      { path: '', redirectTo: 'dashboard', pathMatch: 'full' },
      { path: 'dashboard', component: CustomerDashboardComponent },
      { path: 'my-pickup-points', component: MyPickupPointsComponent },
      { path: 'profile', component: CustomerProfileComponent },
      { path: 'settings', component: CustomerSettingsComponent }
    ]
  },
  { 
    path: 'admin', 
    canActivate: [AuthGuard, AdminGuard],
    children: [
      { path: '', redirectTo: 'dashboard', pathMatch: 'full' },
      { path: 'dashboard', component: AdminDashboardComponent }
    ]
  },
  { path: '**', redirectTo: '/login' }
];

@NgModule({
  imports: [RouterModule.forRoot(routes)],
  exports: [RouterModule]
})
export class AppRoutingModule { }