import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { Router } from '@angular/router';
import { AuthService } from '../../../services/auth.service';
import { VendorPickupPointService, VendorPickupPoint } from '../../../services/vendor-pickup-point.service';
import { PickupPointService } from '../../../services/pickup-point.service';

interface PickupPointWithDetails {
  id: number;
  vendorId: string;
  pickupPointId: number;
  active: boolean;
  name?: string;
  address?: string;
  city?: string;
  state?: string;
  zipCode?: string;
}

@Component({
  selector: 'app-vendor-pickup-points',
  standalone: true,
  imports: [CommonModule, FormsModule],
  templateUrl: './vendor-pickup-points.component.html',
  styleUrls: ['./vendor-pickup-points.component.css']
})
export class VendorPickupPointsComponent implements OnInit {
  pickupPoints: PickupPointWithDetails[] = [];
  allPickupPoints: any[] = [];
  loading = false;
  error = '';
  success = '';
  showAddModal = false;
  selectedPickupPointId: number | null = null;
  currentVendorId: string | null = null;

  constructor(
    private authService: AuthService,
    private vendorPickupPointService: VendorPickupPointService,
    private pickupPointService: PickupPointService,
    private router: Router
  ) {}

  ngOnInit(): void {
    const currentUser = this.authService.currentUserValue;
    this.currentVendorId = currentUser?.userName || null;

    if (this.currentVendorId) {
      this.loadPickupPoints();
      this.loadAllPickupPoints();
    }
  }

  loadPickupPoints(): void {
    if (!this.currentVendorId) return;

    this.loading = true;
    this.vendorPickupPointService.getVendorPickupPoints(this.currentVendorId).subscribe({
      next: (points) => {
        this.pickupPoints = points as PickupPointWithDetails[];
        // Load details for each pickup point
        this.pickupPoints.forEach(point => {
          this.pickupPointService.getPickupPointById(point.pickupPointId).subscribe({
            next: (details) => {
              point.name = details.name;
              point.address = details.address;
              point.city = details.city;
              point.state = details.state;
              point.zipCode = details.zipCode;
            },
            error: (err) => {
              console.error('Error loading pickup point details:', err);
            }
          });
        });
        this.loading = false;
      },
      error: (err) => {
        this.error = 'Error loading pickup points: ' + err;
        this.loading = false;
      }
    });
  }

  loadAllPickupPoints(): void {
    this.pickupPointService.getActivePickupPoints().subscribe({
      next: (points) => {
        this.allPickupPoints = points;
      },
      error: (err) => {
        console.error('Error loading all pickup points:', err);
      }
    });
  }

  openAddModal(): void {
    this.showAddModal = true;
    this.selectedPickupPointId = null;
    this.error = '';
    this.success = '';
  }

  closeAddModal(): void {
    this.showAddModal = false;
    this.selectedPickupPointId = null;
  }

  addPickupPoint(): void {
    if (!this.currentVendorId || !this.selectedPickupPointId) {
      this.error = 'Please select a pickup point';
      return;
    }

    // Check if already added
    const alreadyAdded = this.pickupPoints.some(p => p.pickupPointId === this.selectedPickupPointId);
    if (alreadyAdded) {
      this.error = 'This pickup point is already added';
      return;
    }

    this.loading = true;
    this.vendorPickupPointService.addPickupPoint(this.currentVendorId, {
      pickupPointId: this.selectedPickupPointId
    }).subscribe({
      next: (response) => {
        this.success = 'Pickup point added successfully!';
        this.closeAddModal();
        this.loadPickupPoints();
        setTimeout(() => this.success = '', 3000);
      },
      error: (err) => {
        this.error = 'Error adding pickup point: ' + err;
        this.loading = false;
      }
    });
  }

  toggleActive(pickupPointId: number): void {
    if (!this.currentVendorId) return;

    this.vendorPickupPointService.togglePickupPoint(this.currentVendorId, pickupPointId).subscribe({
      next: (response) => {
        this.success = 'Pickup point status updated!';
        this.loadPickupPoints();
        setTimeout(() => this.success = '', 3000);
      },
      error: (err) => {
        this.error = 'Error updating pickup point: ' + err;
      }
    });
  }

  removePickupPoint(pickupPointId: number, pickupPointName: string): void {
    if (!this.currentVendorId) return;

    if (!confirm(`Are you sure you want to remove "${pickupPointName}"? Products associated with this pickup point will no longer be available there.`)) {
      return;
    }

    this.vendorPickupPointService.removePickupPoint(this.currentVendorId, pickupPointId).subscribe({
      next: (response) => {
        this.success = 'Pickup point removed successfully!';
        this.loadPickupPoints();
        setTimeout(() => this.success = '', 3000);
      },
      error: (err) => {
        this.error = 'Error removing pickup point: ' + err;
      }
    });
  }

  getAvailablePickupPoints(): any[] {
    return this.allPickupPoints.filter(pp =>
      !this.pickupPoints.some(vpp => vpp.pickupPointId === pp.id)
    );
  }

  goBack(): void {
    this.router.navigate(['/vendor/dashboard']);
  }
}
