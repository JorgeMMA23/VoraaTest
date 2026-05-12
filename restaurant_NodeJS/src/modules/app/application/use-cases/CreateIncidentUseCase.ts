import { v4 as uuid } from 'uuid';

import { Incident } from '../../domain/entities/Incident';

import { IncidentRepository } from '../../domain/repositories/IncidentRepository';

export class CreateIncidentUseCase {
  constructor(
    private repository: IncidentRepository
  ) {}

  async execute(input: {
    restaurantId: string;
    tableId: string;
    orderId?: string;
    customerId?: string;
    title: string;
    description: string;
    type: Incident['type'];
    priority?: Incident['priority'];
  }): Promise<Incident> {
    const incident: Incident = {
      id: uuid(),
      restaurantId:
        input.restaurantId,
      tableId: input.tableId,
      orderId: input.orderId,
      customerId:
        input.customerId,
      title: input.title,
      description:
        input.description,
      type: input.type,
      priority:
        input.priority || 'medium',
      status: 'open',
      escalated: false,
      createdAt: new Date(),
      updatedAt: new Date(),
    };

    return this.repository.create(
      incident
    );
  }
}