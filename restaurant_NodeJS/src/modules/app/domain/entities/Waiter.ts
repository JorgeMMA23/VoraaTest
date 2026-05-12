export type WaiterRole =
  | 'waiter'
  | 'captain';

export type WaiterStatus =
  | 'available'
  | 'busy'
  | 'offline';

export interface Waiter {
  id: string;
  userId: string;
  restaurantId: string;
  fullName: string;
  email: string;
  tokenDevice: string;
  phone?: string;
  role: WaiterRole;
  status: WaiterStatus;
  assignedTables: string[];
  active: boolean;
  createdAt: Date;
  updatedAt: Date;
}