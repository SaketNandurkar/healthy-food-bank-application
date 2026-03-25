import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { Router } from '@angular/router';
import { CustomerPickupPointService, CustomerPickupPoint } from '../../../services/customer-pickup-point.service';
import { PickupPointService } from '../../../services/pickup-point.service';
import { AuthService } from '../../../services/auth.service';

interface PickupPointWithDetails extends CustomerPickupPoint {
  name?: string;
  address?: string;
}

@Component({
  selector: 'app-my-pickup-points',
  standalone: true,
  imports: [CommonModule, FormsModule],
  templateUrl: './my-pickup-points.component.html',
  styleUrls: ['./my-pickup-points.component.css']
})
export class MyPickupPointsComponent implements OnInit {
  pickupPoints: PickupPointWithDetails[] = [];
  allPickupPoints: any[] = [];
  loading = false;
  showAddModal = false;
  selectedPickupPointId: number | null = null;
  errorMessage = '';
  successMessage = '';
  customerId: number | null = null;

  constructor(
    private customerPickupPointService: CustomerPickupPointService,
    private pickupPointService: PickupPointService,
    private authService: AuthService,
    private router: Router
  ) {}

  ngOnInit() {
    const currentUser = this.authService.currentUserValue;
    if (!currentUser || !currentUser.id) {
      this.router.navigate(['/login']);
      return;
    }

    this.customerId = currentUser.id;
    this.loadPickupPoints();
    this.loadAllPickupPoints();
  }

  loadPickupPoints() {
    if (!this.customerId) return;

    this.loading = true;
    this.customerPickupPointService.getCustomerPickupPoints(this.customerId).subscribe({
      next: (points) => {
        this.pickupPoints = points;
        // Load details for each pickup point
        this.loadPickupPointDetails();
      },
      error: (error) => {
        console.error('Error loading pickup points:', error);
        this.errorMessage = 'Failed to load pickup points';
        this.loading = false;
      }
    });
  }

  loadPickupPointDetails() {
    // Load details for each pickup point
    const detailsPromises = this.pickupPoints.map(point =>
      this.pickupPointService.getPickupPointById(point.pickupPointId).toPromise()
    );

    Promise.all(detailsPromises).then(details => {
      this.pickupPoints = this.pickupPoints.map((point, index) => ({
        ...point,
        name: details[index]?.name,
        address: details[index]?.address
      }));
      this.loading = false;
    }).catch(error => {
      console.error('Error loading pickup point details:', error);
      this.loading = false;
    });
  }

  loadAllPickupPoints() {
    this.pickupPointService.getAllPickupPoints().subscribe({
      next: (points) => {
        this.allPickupPoints = points;
      },
      error: (error) => {
        console.error('Error loading all pickup points:', error);
      }
    });
  }

  openAddModal() {
    this.showAddModal = true;
    this.selectedPickupPointId = null;
    this.errorMessage = '';
    this.successMessage = '';
  }

  closeAddModal() {
    this.showAddModal = false;
    this.selectedPickupPointId = null;
  }

  addPickupPoint() {
    if (!this.customerId || !this.selectedPickupPointId) {
      this.errorMessage = 'Please select a pickup point';
      return;
    }

    this.loading = true;
    this.customerPickupPointService.addPickupPoint(this.customerId, {
      pickupPointId: this.selectedPickupPointId,
      makeActive: this.pickupPoints.length === 0 // Make active if it's the first one
    }).subscribe({
      next: (response) => {
        this.successMessage = response.message || 'Pickup point added successfully';
        this.closeAddModal();
        this.loadPickupPoints();
      },
      error: (error) => {
        this.errorMessage = error.error?.error || 'Failed to add pickup point';
        this.loading = false;
      }
    });
  }

  setActive(pickupPointId: number) {
    if (!this.customerId) return;

    this.loading = true;
    this.customerPickupPointService.setActivePickupPoint(this.customerId, pickupPointId).subscribe({
      next: (response) => {
        this.successMessage = response.message || 'Active pickup point updated';
        this.loadPickupPoints();

        // Reload the page to refresh product list
        setTimeout(() => {
          window.location.reload();
        }, 1500);
      },
      error: (error) => {
        this.errorMessage = error.error?.error || 'Failed to set active pickup point';
        this.loading = false;
      }
    });
  }

  deletePickupPoint(pickupPointId: number) {
    if (!this.customerId) return;

    if (!confirm('Are you sure you want to delete this pickup point?')) {
      return;
    }

    this.loading = true;
    this.customerPickupPointService.deletePickupPoint(this.customerId, pickupPointId).subscribe({
      next: (response) => {
        this.successMessage = response.message || 'Pickup point deleted successfully';
        this.loadPickupPoints();
      },
      error: (error) => {
        this.errorMessage = error.error?.error || 'Failed to delete pickup point';
        this.loading = false;
      }
    });
  }

  getAvailablePickupPoints() {
    return this.allPickupPoints.filter(pp =>
      !this.pickupPoints.some(cpp => cpp.pickupPointId === pp.id)
    );
  }

  clearMessages() {
    this.errorMessage = '';
    this.successMessage = '';
  }

  goBack() {
    this.router.navigate(['/customer-dashboard']);
  }
}
