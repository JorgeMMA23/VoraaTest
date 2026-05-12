import { IncidentRepository } from '../../domain/repositories/IncidentRepository';

export class ResolveIncidentUseCase {
  constructor(
    private repository: IncidentRepository
  ) {}

  async execute(
    incidentId: string
  ): Promise<void> {
    await this.repository.update(
      incidentId,
      {
        status: 'resolved',
        resolvedAt: new Date(),
      }
    );
  }
}