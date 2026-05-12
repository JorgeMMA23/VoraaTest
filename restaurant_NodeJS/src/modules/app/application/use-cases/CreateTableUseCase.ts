import { v4 as uuid } from 'uuid';

import { RestaurantTable } from '../../domain/entities/Table';

import { TableRepository } from '../../domain/repositories/TableRepository';

export class CreateTableUseCase {
  constructor(
    private repository: TableRepository
  ) {}

  async execute(input: {
    restaurantId: string;
    tableNumber: string;
    capacity: number;
  }): Promise<RestaurantTable> {
    const tableId = uuid();

    const qrCode =
      `restaurant://${input.restaurantId}/table/${tableId}`;

    const table: RestaurantTable = {
      id: tableId,
      restaurantId:
        input.restaurantId,
      tableNumber:
        input.tableNumber,
      qrCode,
      capacity: input.capacity,
      status: 'available',
      active: true,
      createdAt: new Date(),
      updatedAt: new Date(),
    };

    return this.repository.create(table);
  }
}