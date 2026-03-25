export interface VendorCode {
  id?: number;
  vendorCode: string;
  vendorId: string;
  vendorName: string;
  description?: string;
  active?: boolean;
  used?: boolean;
  usedBy?: number;
  usedDate?: Date | string;
  createdBy?: number;
  createdDate?: Date | string;
  updatedDate?: Date | string;
}