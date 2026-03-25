import { Component, OnInit } from '@angular/core';
import { FormBuilder, FormGroup, Validators } from '@angular/forms';
import { Router } from '@angular/router';
import { AuthService } from '../../../services/auth.service';
import { User } from '../../../models/user.model';

@Component({
  selector: 'app-customer-settings',
  templateUrl: './customer-settings.component.html',
  styleUrl: './customer-settings.component.css'
})
export class CustomerSettingsComponent implements OnInit {
  currentUser: User | null = null;
  passwordForm!: FormGroup;
  notificationForm!: FormGroup;
  loading = false;
  success = '';
  error = '';

  constructor(
    private formBuilder: FormBuilder,
    private authService: AuthService,
    private router: Router
  ) {}

  ngOnInit(): void {
    this.currentUser = this.authService.currentUserValue;
    this.initializeForms();
  }

  private initializeForms(): void {
    this.passwordForm = this.formBuilder.group({
      currentPassword: ['', [Validators.required]],
      newPassword: ['', [Validators.required, Validators.minLength(6)]],
      confirmPassword: ['', [Validators.required]]
    });

    this.notificationForm = this.formBuilder.group({
      emailNotifications: [true],
      smsNotifications: [false],
      orderNotifications: [true],
      deliveryUpdates: [true],
      marketingEmails: [false]
    });
  }

  get pf() { return this.passwordForm.controls; }
  get nf() { return this.notificationForm.controls; }

  onChangePassword(): void {
    if (this.passwordForm.invalid) return;

    if (this.pf['newPassword'].value !== this.pf['confirmPassword'].value) {
      this.error = 'New password and confirm password do not match';
      return;
    }

    this.loading = true;
    this.error = '';
    this.success = '';

    this.authService.changePassword(
      this.pf['currentPassword'].value,
      this.pf['newPassword'].value
    ).subscribe({
      next: (response) => {
        this.success = 'Password changed successfully!';
        this.passwordForm.reset();
        this.loading = false;
      },
      error: (error) => {
        this.error = error || 'Failed to change password';
        this.loading = false;
      }
    });
  }

  onUpdateNotifications(): void {
    this.loading = true;
    this.success = 'Notification preferences updated successfully!';
    this.error = '';
    this.loading = false;
  }

  backToDashboard(): void {
    this.router.navigate(['/customer/dashboard']);
  }
}
