import { Promotion } from '../entities/Promotion';

export interface PromotionRepository {
  create(data: Promotion): Promise<Promotion>;
  update(id: string, data: Partial<Promotion>): Promise<void>;
  findAll(): Promise<Promotion[]>;
  findById(id: string): Promise<Promotion | null>;
  delete(id: string): Promise<void>;
}