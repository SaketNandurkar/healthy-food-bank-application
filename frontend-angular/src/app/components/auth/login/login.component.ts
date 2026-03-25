import { Component, OnInit } from '@angular/core';
import { FormBuilder, FormGroup, Validators } from '@angular/forms';
import { Router, ActivatedRoute } from '@angular/router';
import { AuthService } from '../../../services/auth.service';
import { LoginRequest, UserRole } from '../../../models/user.model';

@Component({
  selector: 'app-login',
  templateUrl: './login.component.html',
  styleUrls: ['./login.component.css']
})
export class LoginComponent implements OnInit {
  loginForm!: FormGroup;
  loading = false;
  submitted = false;
  error = '';
  showPassword = false;
  sessionExpiredMessage = '';

  constructor(
    private formBuilder: FormBuilder,
    private authService: AuthService,
    private router: Router,
    private route: ActivatedRoute
  ) {}

  ngOnInit(): void {
    // Check for session expiration query parameter
    this.route.queryParams.subscribe(params => {
      if (params['sessionExpired'] === 'true') {
        this.sessionExpiredMessage = 'Your session has expired. Please log in again.';
        // Clear the message after 5 seconds
        setTimeout(() => {
          this.sessionExpiredMessage = '';
        }, 5000);
      }
    });

    // Redirect if already logged in
    if (this.authService.isLoggedIn()) {
      this.redirectToDashboard();
    }

    this.loginForm = this.formBuilder.group({
      userName: ['', [Validators.required, Validators.minLength(3)]],
      password: ['', [Validators.required, Validators.minLength(6)]]
    });
  }

  get f() { return this.loginForm.controls; }

  onSubmit(): void {
    this.submitted = true;
    this.error = '';

    if (this.loginForm.invalid) {
      return;
    }

    this.loading = true;
    const loginRequest: LoginRequest = {
      userName: this.f['userName'].value,
      password: this.f['password'].value
    };

    this.authService.login(loginRequest).subscribe({
      next: (response) => {
        this.loading = false;
        this.redirectToDashboard();
      },
      error: (error) => {
        this.error = error;
        this.loading = false;
      }
    });
  }

  private redirectToDashboard(): void {
    const userRole = this.authService.getUserRole();
    
    switch (userRole) {
      case UserRole.VENDOR:
        this.router.navigate(['/vendor/dashboard']);
        break;
      case UserRole.CUSTOMER:
        this.router.navigate(['/customer/dashboard']);
        break;
      case UserRole.ADMIN:
        this.router.navigate(['/admin/dashboard']);
        break;
      default:
        this.router.navigate(['/dashboard']);
    }
  }

  togglePasswordVisibility(): void {
    this.showPassword = !this.showPassword;
  }

  navigateToRegister(): void {
    this.router.navigate(['/register']);
  }

  onReset(): void {
    this.submitted = false;
    this.loginForm.reset();
    this.error = '';
    this.showPassword = false;
  }
}