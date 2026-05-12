export interface User {
  id: string;
  name: string;
  email: string;
  photoUrl?: string;
  role: 'customer' | 'waiter' | 'captain' | 'admin';
  restaurantId?: string;
  active: boolean;
  createdAt: Date;
  token?: string;
}