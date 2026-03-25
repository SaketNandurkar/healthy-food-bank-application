import { Component, OnInit } from '@angular/core';
import { FormBuilder, FormGroup, Validators, AbstractControl } from '@angular/forms';
import { Router } from '@angular/router';
import { AuthService } from '../../../services/auth.service';
import { PickupPointService } from '../../../services/pickup-point.service';
import { CustomerPickupPointService } from '../../../services/customer-pickup-point.service';
import { UserRegistration, UserRole } from '../../../models/user.model';
import { PickupPoint } from '../../../models/pickup-point.model';

@Component({
  selector: 'app-register',
  templateUrl: './register.component.html',
  styleUrls: ['./register.component.css']
})
export class RegisterComponent implements OnInit {
  registerForm!: FormGroup;
  loading = false;
  submitted = false;
  error = '';
  success = '';
  userRoles = Object.values(UserRole);
  showVendorCode = false;
  showPickupPoint = false;
  vendorCodeValidating = false;
  pickupPoints: PickupPoint[] = [];

  constructor(
    private formBuilder: FormBuilder,
    private authService: AuthService,
    private pickupPointService: PickupPointService,
    private customerPickupPointService: CustomerPickupPointService,
    private router: Router
  ) {}

  ngOnInit(): void {
    this.loadPickupPoints();

    this.registerForm = this.formBuilder.group({
      firstName: ['', [Validators.required, Validators.minLength(2), Validators.maxLength(50)]],
      lastName: ['', [Validators.required, Validators.minLength(2), Validators.maxLength(50)]],
      email: ['', [Validators.email]],
      phoneNumber: ['', [Validators.required, Validators.pattern('^[0-9]{10}$')]],
      role: ['', Validators.required],
      vendorCode: [''],
      pickupPointId: [''],
      userName: ['', [Validators.required, Validators.minLength(3), Validators.maxLength(20)]],
      password: ['', [Validators.required, Validators.minLength(6), Validators.maxLength(100)]],
      confirmPassword: ['', Validators.required]
    }, {
      validators: this.passwordMatchValidator
    });

    this.registerForm.get('role')?.valueChanges.subscribe(role => {
      this.onRoleChange(role);
    });
  }

  loadPickupPoints(): void {
    this.pickupPointService.getActivePickupPoints().subscribe({
      next: (points) => {
        this.pickupPoints = points;
      },
      error: (error) => {
        console.error('Error loading pickup points:', error);
      }
    });
  }

  get f() { return this.registerForm.controls; }

  onRoleChange(role: string): void {
    this.showVendorCode = role === UserRole.VENDOR;
    this.showPickupPoint = role === UserRole.CUSTOMER;

    const vendorCodeControl = this.registerForm.get('vendorCode');
    const pickupPointControl = this.registerForm.get('pickupPointId');

    // Vendor Code validation
    if (this.showVendorCode) {
      vendorCodeControl?.setValidators([Validators.required, Validators.minLength(5)]);
    } else {
      vendorCodeControl?.clearValidators();
      vendorCodeControl?.setValue('');
    }
    vendorCodeControl?.updateValueAndValidity();

    // Pickup Point validation - required for customers only
    if (this.showPickupPoint) {
      pickupPointControl?.setValidators([Validators.required]);
    } else {
      pickupPointControl?.clearValidators();
      pickupPointControl?.setValue('');
    }
    pickupPointControl?.updateValueAndValidity();
  }

  onVendorCodeChange(): void {
    const vendorCode = this.registerForm.get('vendorCode')?.value;
    if (vendorCode && vendorCode.length >= 5) {
      this.vendorCodeValidating = true;
      this.authService.validateVendorCode(vendorCode).subscribe({
        next: (isValid) => {
          this.vendorCodeValidating = false;
          const vendorCodeControl = this.registerForm.get('vendorCode');
          if (!isValid) {
            vendorCodeControl?.setErrors({ 'invalidVendorCode': true });
          } else {
            // Remove custom error but keep other validation errors
            const errors = vendorCodeControl?.errors;
            if (errors) {
              delete errors['invalidVendorCode'];
              const hasOtherErrors = Object.keys(errors).length > 0;
              vendorCodeControl?.setErrors(hasOtherErrors ? errors : null);
            }
          }
        },
        error: () => {
          this.vendorCodeValidating = false;
          this.registerForm.get('vendorCode')?.setErrors({ 'invalidVendorCode': true });
        }
      });
    }
  }

  passwordMatchValidator(control: AbstractControl): { [key: string]: boolean } | null {
    const password = control.get('password');
    const confirmPassword = control.get('confirmPassword');
    
    if (password && confirmPassword && password.value !== confirmPassword.value) {
      return { 'passwordMismatch': true };
    }
    return null;
  }

  onSubmit(): void {
    this.submitted = true;
    this.error = '';
    this.success = '';

    if (this.registerForm.invalid) {
      return;
    }

    this.loading = true;
    const userRegistration: UserRegistration = {
      firstName: this.f['firstName'].value,
      lastName: this.f['lastName'].value,
      email: this.f['email'].value,
      phoneNumber: this.f['phoneNumber'].value,
      role: this.f['role'].value,
      vendorCode: this.f['vendorCode'].value || undefined,
      pickupPointId: this.f['pickupPointId'].value || undefined,
      userName: this.f['userName'].value,
      password: this.f['password'].value,
      confirmPassword: this.f['confirmPassword'].value
    };

    this.authService.register(userRegistration).subscribe({
      next: (response) => {
        this.success = 'Registration successful! Please login with your credentials.';
        this.loading = false;

        // If customer with pickup point, add pickup point to customer_pickup_points
        if (userRegistration.role === UserRole.CUSTOMER && userRegistration.pickupPointId && response.data?.id) {
          this.customerPickupPointService.addPickupPoint(response.data.id, {
            pickupPointId: userRegistration.pickupPointId,
            makeActive: true
          }).subscribe({
            next: () => {
              console.log('Pickup point added successfully');
            },
            error: (err) => {
              console.error('Error adding pickup point:', err);
            }
          });
        }

        setTimeout(() => {
          this.router.navigate(['/login']);
        }, 2000);
      },
      error: (error) => {
        this.error = error;
        this.loading = false;
      }
    });
  }

  onReset(): void {
    this.submitted = false;
    this.registerForm.reset();
    this.showVendorCode = false;
    this.error = '';
    this.success = '';
  }

  navigateToLogin(): void {
    this.router.navigate(['/login']);
  }
}