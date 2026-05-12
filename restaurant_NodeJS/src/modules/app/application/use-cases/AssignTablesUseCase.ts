import { WaiterRepository } from '../../domain/repositories/WaiterRepository';

export class AssignTablesUseCase {
  constructor(
    private repository: WaiterRepository
  ) {}

  async execute(
    waiterId: string,
    tables: string[]
  ): Promise<void> {
    await this.repository.update(waiterId, {
      assignedTables: tables,
    });
  }
}