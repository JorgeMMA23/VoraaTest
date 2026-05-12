import { Incident } from '../entities/Incident';

export interface IncidentRepository {
  create(
    data: Incident
  ): Promise<Incident>;

  findById(
    id: string
  ): Promise<Incident | null>;

  findAll(): Promise<Incident[]>;

  update(
    id: string,
    data: Partial<Incident>
  ): Promise<void>;

  delete(id: string): Promise<void>;
}