import { Order } from '../entities/Order';

export interface OrderRepository {
  create(data: Order): Promise<Order>;

  findById(id: string): Promise<Order | null>;

  findAll(): Promise<Order[]>;

  update(
    id: string,
    data: Partial<Order>
  ): Promise<void>;

  delete(id: string): Promise<void>;

  getTotalTipsByPaidOrders(): Promise<number>;
}