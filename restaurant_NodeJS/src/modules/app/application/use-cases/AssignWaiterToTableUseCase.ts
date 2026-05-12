import { TableRepository } from '../../domain/repositories/TableRepository';

export class AssignWaiterToTableUseCase {
  constructor(
    private repository: TableRepository
  ) {}

  async execute(
    tableId: string,
    waiterId: string
  ): Promise<void> {
    await this.repository.update(tableId, {
      assignedWaiterId: waiterId,
    });
  }
}