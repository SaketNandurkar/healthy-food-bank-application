export interface User {
  id?: number;
  firstName: string;
  lastName: string;
  email?: string;
  phoneNumber: number | string;
  role: UserRole;
  vendorId?: string;
  userName: string;
  password?: string;
  active?: boolean;
  roles?: string;
  pickupPointId?: number;
  createdDate?: Date;
  updatedDate?: Date;
}

export enum UserRole {
  CUSTOMER = 'CUSTOMER',
  VENDOR = 'VENDOR',
  ADMIN = 'ADMIN'
}

export interface UserRegistration {
  firstName: string;
  lastName: string;
  email?: string;
  phoneNumber: number | string;
  role: UserRole;
  vendorId?: string;
  vendorCode?: string;
  pickupPointId?: number;
  userName: string;
  password: string;
  confirmPassword: string;
}

export interface LoginRequest {
  userName: string;
  password: string;
}

export interface LoginResponse {
  token: string;
  user: User;
  expiresIn?: number;
}

export interface ProfileUpdateResponse {
  user: User;
  newToken?: string;
  tokenRefreshed: boolean;
}