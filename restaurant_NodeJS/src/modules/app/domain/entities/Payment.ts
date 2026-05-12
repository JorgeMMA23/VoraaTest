export interface Payment {
  id: string;
  orderId: string;
  customerId: string;
  amount: number;
  tip: number;
  total: number;
  currency: string;
  status: 'pending' | 'paid' | 'failed';
  paymentMethod: 'card';
  conektaOrderId?: string;
  createdAt: Date;
}