import { v4 as uuid } from 'uuid';

import {
  Order,
  OrderItem,
} from '../../domain/entities/Order';

import { OrderRepository } from '../../domain/repositories/OrderRepository';

export class CreateOrderUseCase {
  constructor(
    private repository: OrderRepository
  ) {}

  async execute(input: {
    restaurantId?: string;
    tableId?: string;
    customerId?: string;
    waiterId?: string;
    items: OrderItem[];
    tip?: number;
  }): Promise<Order> {
    const subtotal = input.items.reduce(
      (acc, item) =>
        acc +
        item.unitPrice * item.quantity,
      0
    );

    const tip = input.tip || 0;

    const total = subtotal + tip;

    const order: Order = {
      id: uuid(),
      restaurantId: input.restaurantId || "REST_001",
      tableId: input.tableId || "371a6b53-1415-4bbe-8fe1-a23fa8d4c4cd",
      customerId: input.customerId,
      waiterId: input.waiterId || "f7a2635b-c3b5-475f-a880-2b53bd9211d8",
      items: input.items,
      subtotal,
      tip,
      total,
      status: 'pending',
      paymentStatus: 'pending',
      createdAt: new Date(),
      updatedAt: new Date(),
    };

    return this.repository.create(order);
  }
}