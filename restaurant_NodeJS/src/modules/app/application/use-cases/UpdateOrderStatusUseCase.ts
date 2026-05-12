import { OrderStatus } from '../../domain/entities/Order';

import { OrderRepository } from '../../domain/repositories/OrderRepository';

export class UpdateOrderStatusUseCase {
  constructor(
    private repository: OrderRepository
  ) {}

  async execute(
    id: string,
    data: {
      status: OrderStatus,
      total?: number,
      tip?: number,
      discount?: number,
      subtotal?: number
    }
  ): Promise<void> {
    console.log(data)
    await this.repository.update(id, {
      status: data.status,
      total: data.total,
      tip: data.tip,
      discount: data.discount,
      subtotal: data.subtotal
    });
  }
}