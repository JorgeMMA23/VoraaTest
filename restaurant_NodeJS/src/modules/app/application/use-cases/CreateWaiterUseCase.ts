import { v4 as uuid } from 'uuid';

import { Waiter } from '../../domain/entities/Waiter';

import { WaiterRepository } from '../../domain/repositories/WaiterRepository';

export class CreateWaiterUseCase {
  constructor(
    private repository: WaiterRepository
  ) {}

  async execute(input: {
    userId: string;
    restaurantId: string;
    fullName: string;
    email: string;
    phone?: string;
    role?: 'waiter' | 'captain';
    tokenDevice: string;
  }): Promise<Waiter> {
    const waiter: Waiter = {
      id: uuid(),
      userId: input.userId,
      restaurantId:
        input.restaurantId,
      fullName: input.fullName,
      email: input.email,
      phone: input.phone,
      role: input.role || 'waiter',
      status: 'available',
      assignedTables: [],
      active: true,
      createdAt: new Date(),
      updatedAt: new Date(),
      tokenDevice: input.tokenDevice,
    };

    return this.repository.create(waiter);
  }
}