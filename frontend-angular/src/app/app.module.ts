import { NgModule } from '@angular/core';
import { BrowserModule } from '@angular/platform-browser';
import { ReactiveFormsModule, FormsModule } from '@angular/forms';
import { HttpClientModule, HTTP_INTERCEPTORS } from '@angular/common/http';
import { BrowserAnimationsModule } from '@angular/platform-browser/animations';

import { AppRoutingModule } from './app-routing.module';
import { AppComponent } from './app.component';

// Auth Components
import { LoginComponent } from './components/auth/login/login.component';
import { RegisterComponent } from './components/auth/register/register.component';

// Vendor Components
import { VendorDashboardComponent } from './components/vendor/vendor-dashboard/vendor-dashboard.component';

// Customer Components
import { CustomerDashboardComponent } from './components/customer/customer-dashboard/customer-dashboard.component';
import { MyPickupPointsComponent } from './components/customer/my-pickup-points/my-pickup-points.component';
import { CustomerProfileComponent } from './components/customer/customer-profile/customer-profile.component';
import { CustomerSettingsComponent } from './components/customer/customer-settings/customer-settings.component';

// More Vendor Components
import { VendorPickupPointsComponent } from './components/vendor/vendor-pickup-points/vendor-pickup-points.component';

// Admin Components
import { AdminDashboardComponent } from './components/admin/admin-dashboard/admin-dashboard.component';

// Services
import { AuthService } from './services/auth.service';
import { ProductService } from './services/product.service';
import { CartService } from './services/cart.service';
import { VendorCodeService } from './services/vendor-code.service';

// Guards
import { AuthGuard } from './guards/auth.guard';
import { VendorGuard } from './guards/vendor.guard';
import { CustomerGuard } from './guards/customer.guard';
import { AdminGuard } from './guards/admin.guard';

// Interceptors
import { AuthInterceptor } from './interceptors/auth.interceptor';

import { VendorProfileComponent } from './components/vendor/vendor-profile/vendor-profile.component';
import { VendorSettingsComponent } from './components/vendor/vendor-settings/vendor-settings.component';

@NgModule({
  declarations: [
    AppComponent,
    LoginComponent,
    RegisterComponent,
    VendorDashboardComponent,
    CustomerDashboardComponent,
    AdminDashboardComponent,
    VendorProfileComponent,
    VendorSettingsComponent,
    CustomerProfileComponent,
    CustomerSettingsComponent
  ],
  imports: [
    BrowserModule,
    AppRoutingModule,
    ReactiveFormsModule,
    FormsModule,
    HttpClientModule,
    BrowserAnimationsModule,
    MyPickupPointsComponent,
    VendorPickupPointsComponent
  ],
  providers: [
    AuthService,
    ProductService,
    CartService,
    VendorCodeService,
    AuthGuard,
    VendorGuard,
    CustomerGuard,
    AdminGuard,
    {
      provide: HTTP_INTERCEPTORS,
      useClass: AuthInterceptor,
      multi: true
    }
  ],
  bootstrap: [AppComponent]
})
export class AppModule { }