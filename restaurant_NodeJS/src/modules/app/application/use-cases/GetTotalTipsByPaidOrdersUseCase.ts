import { OrderRepository } from '../../domain/repositories/OrderRepository';

export class GetTotalTipsByPaidOrdersUseCase {
  constructor(
    private readonly repository: OrderRepository
  ) {}

  async execute(): Promise<number> {
    return this.repository.getTotalTipsByPaidOrders();
  }
}
