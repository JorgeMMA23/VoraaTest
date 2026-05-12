import { TableStatus } from '../../domain/entities/Table';
import { TableRepository } from '../../domain/repositories/TableRepository';

export class UpdateTableStatusUseCase {
  constructor(
    private repository: TableRepository
  ) {}

  async execute(
    tableId: string,
    status: TableStatus
  ): Promise<void> {
    await this.repository.update(tableId, {
      status,
    });
  }
}