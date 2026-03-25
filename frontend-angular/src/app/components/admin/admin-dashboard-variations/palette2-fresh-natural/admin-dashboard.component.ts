import { Component, OnInit } from '@angular/core';
import { FormBuilder, FormGroup, Validators } from '@angular/forms';
import { AuthService } from '../../../services/auth.service';
import { VendorCodeService } from '../../../services/vendor-code.service';
import { PickupPointService } from '../../../services/pickup-point.service';
import { User } from '../../../models/user.model';
import { VendorCode } from '../../../models/vendor-code.model';
import { PickupPoint } from '../../../models/pickup-point.model';

@Component({
  selector: 'app-admin-dashboard',
  templateUrl: './admin-dashboard.component.html',
  styleUrls: ['./admin-dashboard.component.css']
})
export class AdminDashboardComponent implements OnInit {
  currentUser: User | null = null;

  // Active section
  activeSection = 'vendor-management';

  // Vendor Management
  vendorCodes: VendorCode[] = [];
  unusedVendorCodes: VendorCode[] = [];
  usedVendorCodes: VendorCode[] = [];
  vendorCodeForm!: FormGroup;
  showVendorCodeForm = false;
  vendorActiveTab = 'all';
  creatingVendorCode = false;

  // Pickup Management
  pickupPoints: PickupPoint[] = [];
  pickupPointForm!: FormGroup;
  showPickupPointForm = false;
  editingPickupPoint: PickupPoint | null = null;
  creatingPickupPoint = false;

  // Common
  loading = false;
  error = '';
  success = '';

  constructor(
    private authService: AuthService,
    private vendorCodeService: VendorCodeService,
    private pickupPointService: PickupPointService,
    private formBuilder: FormBuilder
  ) {}

  ngOnInit(): void {
    this.currentUser = this.authService.currentUserValue;
    this.initializeForms();
    this.loadInitialData();
  }

  private initializeForms(): void {
    // Vendor Code Form
    this.vendorCodeForm = this.formBuilder.group({
      vendorCode: ['', [Validators.required, Validators.minLength(5), Validators.maxLength(20)]],
      vendorId: ['', [Validators.required, Validators.minLength(3), Validators.maxLength(20)]],
      vendorName: ['', [Validators.required, Validators.minLength(3), Validators.maxLength(100)]],
      description: ['', [Validators.maxLength(255)]]
    });

    // Pickup Point Form
    this.pickupPointForm = this.formBuilder.group({
      name: ['', [Validators.required, Validators.minLength(3), Validators.maxLength(100)]],
      address: ['', [Validators.required, Validators.minLength(10), Validators.maxLength(255)]],
      contactNumber: ['', [Validators.pattern(/^[+]?[\d\s-()]+$/)]]
    });
  }

  private loadInitialData(): void {
    if (this.activeSection === 'vendor-management') {
      this.loadVendorCodes();
    } else if (this.activeSection === 'pickup-management') {
      this.loadPickupPoints();
    }
  }

  get vf() { return this.vendorCodeForm.controls; }
  get pf() { return this.pickupPointForm.controls; }

  // ============ NAVIGATION ============

  switchSection(section: string): void {
    this.activeSection = section;
    this.clearMessages();
    this.showVendorCodeForm = false;
    this.showPickupPointForm = false;
    this.editingPickupPoint = null;

    if (section === 'vendor-management') {
      this.loadVendorCodes();
    } else if (section === 'pickup-management') {
      this.loadPickupPoints();
    }
  }

  // ============ VENDOR MANAGEMENT ============

  loadVendorCodes(): void {
    this.loading = true;
    this.error = '';

    this.vendorCodeService.getAllVendorCodes().subscribe({
      next: (codes) => {
        this.vendorCodes = codes;
        this.loading = false;
      },
      error: (error) => {
        this.error = 'Failed to load vendor codes: ' + error;
        this.loading = false;
      }
    });
  }

  loadUnusedVendorCodes(): void {
    this.loading = true;
    this.error = '';

    this.vendorCodeService.getUnusedVendorCodes().subscribe({
      next: (codes) => {
        this.unusedVendorCodes = codes;
        this.loading = false;
      },
      error: (error) => {
        this.error = 'Failed to load unused vendor codes: ' + error;
        this.loading = false;
      }
    });
  }

  loadUsedVendorCodes(): void {
    this.loading = true;
    this.error = '';

    this.vendorCodeService.getUsedVendorCodes().subscribe({
      next: (codes) => {
        this.usedVendorCodes = codes;
        this.loading = false;
      },
      error: (error) => {
        this.error = 'Failed to load used vendor codes: ' + error;
        this.loading = false;
      }
    });
  }

  onVendorTabChange(tab: string): void {
    this.vendorActiveTab = tab;
    this.error = '';
    this.success = '';

    switch (tab) {
      case 'all':
        this.loadVendorCodes();
        break;
      case 'unused':
        this.loadUnusedVendorCodes();
        break;
      case 'used':
        this.loadUsedVendorCodes();
        break;
    }
  }

  toggleVendorCodeForm(): void {
    this.showVendorCodeForm = !this.showVendorCodeForm;
    if (!this.showVendorCodeForm) {
      this.vendorCodeForm.reset();
      this.error = '';
      this.success = '';
    }
  }

  onCreateVendorCode(): void {
    if (this.vendorCodeForm.invalid) {
      return;
    }

    this.creatingVendorCode = true;
    this.error = '';
    this.success = '';

    const vendorCode: VendorCode = {
      vendorCode: this.vf['vendorCode'].value,
      vendorId: this.vf['vendorId'].value,
      vendorName: this.vf['vendorName'].value,
      description: this.vf['description'].value,
      active: true,
      used: false,
      createdBy: this.currentUser?.id
    };

    this.vendorCodeService.createVendorCode(vendorCode).subscribe({
      next: (createdCode) => {
        this.success = 'Vendor code created successfully!';
        this.creatingVendorCode = false;
        this.toggleVendorCodeForm();
        this.loadVendorCodes();
      },
      error: (error) => {
        this.error = 'Failed to create vendor code: ' + error;
        this.creatingVendorCode = false;
      }
    });
  }

  deactivateVendorCode(id: number): void {
    if (!confirm('Are you sure you want to deactivate this vendor code?')) {
      return;
    }

    this.vendorCodeService.deactivateVendorCode(id).subscribe({
      next: () => {
        this.success = 'Vendor code deactivated successfully!';
        this.loadVendorCodes();
      },
      error: (error) => {
        this.error = 'Failed to deactivate vendor code: ' + error;
      }
    });
  }

  // ============ PICKUP POINT MANAGEMENT ============

  private getErrorMessage(error: any): string {
    if (error?.error?.message) {
      return error.error.message;
    } else if (error?.message) {
      return error.message;
    } else if (typeof error === 'string') {
      return error;
    } else if (error?.error) {
      return typeof error.error === 'string' ? error.error : JSON.stringify(error.error);
    }
    return 'An unknown error occurred';
  }

  loadPickupPoints(): void {
    this.loading = true;
    this.error = '';

    this.pickupPointService.getAllPickupPoints().subscribe({
      next: (points) => {
        this.pickupPoints = points;
        this.loading = false;
      },
      error: (error) => {
        this.error = 'Failed to load pickup points: ' + this.getErrorMessage(error);
        this.loading = false;
      }
    });
  }

  togglePickupPointForm(): void {
    this.showPickupPointForm = !this.showPickupPointForm;
    if (!this.showPickupPointForm) {
      this.pickupPointForm.reset();
      this.editingPickupPoint = null;
      this.error = '';
      this.success = '';
    }
  }

  onCreatePickupPoint(): void {
    if (this.pickupPointForm.invalid) {
      return;
    }

    this.creatingPickupPoint = true;
    this.error = '';
    this.success = '';

    const pickupPoint: PickupPoint = {
      name: this.pf['name'].value,
      address: this.pf['address'].value,
      contactNumber: this.pf['contactNumber'].value,
      active: true
    };

    if (this.editingPickupPoint) {
      // Update existing
      this.pickupPointService.updatePickupPoint(this.editingPickupPoint.id!, pickupPoint).subscribe({
        next: () => {
          this.success = 'Pickup point updated successfully!';
          this.creatingPickupPoint = false;
          this.togglePickupPointForm();
          this.loadPickupPoints();
        },
        error: (error) => {
          this.error = 'Failed to update pickup point: ' + this.getErrorMessage(error);
          this.creatingPickupPoint = false;
        }
      });
    } else {
      // Create new
      this.pickupPointService.createPickupPoint(pickupPoint).subscribe({
        next: () => {
          this.success = 'Pickup point created successfully!';
          this.creatingPickupPoint = false;
          this.togglePickupPointForm();
          this.loadPickupPoints();
        },
        error: (error) => {
          this.error = 'Failed to create pickup point: ' + this.getErrorMessage(error);
          this.creatingPickupPoint = false;
        }
      });
    }
  }

  editPickupPoint(point: PickupPoint): void {
    this.editingPickupPoint = point;
    this.pickupPointForm.patchValue({
      name: point.name,
      address: point.address,
      contactNumber: point.contactNumber
    });
    this.showPickupPointForm = true;
  }

  deletePickupPoint(id: number): void {
    if (!confirm('Are you sure you want to permanently delete this pickup point?')) {
      return;
    }

    this.pickupPointService.deletePickupPoint(id).subscribe({
      next: () => {
        this.success = 'Pickup point deleted successfully!';
        this.loadPickupPoints();
      },
      error: (error) => {
        this.error = 'Failed to delete pickup point: ' + this.getErrorMessage(error);
      }
    });
  }

  togglePickupPointStatus(point: PickupPoint): void {
    const action = point.active ? 'deactivate' : 'activate';

    if (!confirm(`Are you sure you want to ${action} this pickup point?`)) {
      return;
    }

    const operation = point.active
      ? this.pickupPointService.deactivatePickupPoint(point.id!)
      : this.pickupPointService.activatePickupPoint(point.id!);

    operation.subscribe({
      next: () => {
        this.success = `Pickup point ${action}d successfully!`;
        this.loadPickupPoints();
      },
      error: (error) => {
        this.error = `Failed to ${action} pickup point: ` + this.getErrorMessage(error);
      }
    });
  }

  // ============ UTILITY ============

  logout(): void {
    this.authService.logout();
  }

  formatDate(date: string | Date | undefined): string {
    if (!date) return 'N/A';
    return new Date(date).toLocaleDateString() + ' ' + new Date(date).toLocaleTimeString();
  }

  clearMessages(): void {
    this.error = '';
    this.success = '';
  }
}
