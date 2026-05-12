export type TableStatus =
  | 'available'
  | 'occupied'
  | 'reserved'
  | 'cleaning'
  | 'disabled';

export interface RestaurantTable {
  id: string;
  restaurantId: string;
  tableNumber: string;
  qrCode: string;
  capacity: number;
  assignedWaiterId?: string;
  currentOrderId?: string;
  status: TableStatus;
  active: boolean;
  createdAt: Date;
  updatedAt: Date;
}