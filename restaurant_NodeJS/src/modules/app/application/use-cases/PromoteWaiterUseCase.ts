import { WaiterRepository } from '../../domain/repositories/WaiterRepository';

export class PromoteWaiterUseCase {
  constructor(
    private repository: WaiterRepository
  ) {}

  async execute(
    waiterId: string
  ): Promise<void> {
    await this.repository.update(waiterId, {
      role: 'captain',
    });
  }
}