export interface Customer {
  id: string;
  name: string;
  email: string;
  phone: string;
  conektaCustomerId?: string;
  createdAt: Date;
}