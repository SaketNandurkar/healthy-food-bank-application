export interface PickupPoint {
  id?: number;
  name: string;
  address: string;
  city?: string;
  state?: string;
  zipCode?: string;
  contactNumber?: string;
  active: boolean;
  createdDate?: Date;
  updatedDate?: Date;
}
