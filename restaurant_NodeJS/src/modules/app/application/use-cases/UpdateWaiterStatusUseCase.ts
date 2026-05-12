import { WaiterStatus } from '../../domain/entities/Waiter';

import { WaiterRepository } from '../../domain/repositories/WaiterRepository';

export class UpdateWaiterStatusUseCase {
  constructor(
    private repository: WaiterRepository
  ) {}

  async execute(
    waiterId: string,
    status: WaiterStatus
  ): Promise<void> {
    await this.repository.update(waiterId, {
      status,
    });
  }
}