export type OrderStatus =
  | 'pending'
  | 'confirmed'
  | 'preparing'
  | 'ready'
  | 'delivered'
  | 'completed'
  | 'paid'
  | 'cancelled';

export interface OrderItem {
  productId: string;
  productName: string;
  quantity: number;
  unitPrice: number;
  price?: number;
  notes?: string;
}

export interface Order {
  id: string;
  restaurantId: string;
  tableId: string;
  customerId?: string;
  waiterId?: string;
  items: OrderItem[];
  subtotal: number;
  tip: number;
  total: number;
  discount?: number;
  status: OrderStatus;
  paymentStatus:
  | 'pending'
  | 'paid'
  | 'refunded';
  createdAt: Date;
  updatedAt: Date;
}