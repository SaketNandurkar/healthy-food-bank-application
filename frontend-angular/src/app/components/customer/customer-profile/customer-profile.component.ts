import { Component, OnInit } from '@angular/core';
import { FormBuilder, FormGroup, Validators } from '@angular/forms';
import { Router } from '@angular/router';
import { AuthService } from '../../../services/auth.service';
import { User } from '../../../models/user.model';

@Component({
  selector: 'app-customer-profile',
  templateUrl: './customer-profile.component.html',
  styleUrl: './customer-profile.component.css'
})
export class CustomerProfileComponent implements OnInit {
  currentUser: User | null = null;
  profileForm!: FormGroup;
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
    this.initializeProfileForm();
  }

  private initializeProfileForm(): void {
    this.profileForm = this.formBuilder.group({
      firstName: [this.currentUser?.firstName || '', [Validators.required, Validators.minLength(2)]],
      lastName: [this.currentUser?.lastName || '', [Validators.required, Validators.minLength(2)]],
      email: [this.currentUser?.email || '', [Validators.required, Validators.email]],
      phoneNumber: [this.currentUser?.phoneNumber || '', [Validators.pattern(/^\d{10}$/)]]
    });
  }

  get f() { return this.profileForm.controls; }

  onUpdateProfile(): void {
    if (this.profileForm.invalid) return;

    this.loading = true;
    this.error = '';
    this.success = '';

    const profileData = {
      firstName: this.f['firstName'].value,
      lastName: this.f['lastName'].value,
      email: this.f['email'].value,
      phoneNumber: this.f['phoneNumber'].value
    };

    this.authService.updateProfile(profileData).subscribe({
      next: (updatedUser) => {
        this.success = 'Profile updated successfully!';
        this.currentUser = updatedUser;
        this.loading = false;
      },
      error: (error) => {
        this.error = error || 'Failed to update profile';
        this.loading = false;
      }
    });
  }

  backToDashboard(): void {
    this.router.navigate(['/customer/dashboard']);
  }
}
