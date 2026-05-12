import { v4 as uuid } from 'uuid';
import { Promotion } from '../../domain/entities/Promotion';
import { PromotionRepository } from '../../domain/repositories/PromotionRepository';

export class CreatePromotionUseCase {
  constructor(private repository: PromotionRepository) {}

  async execute(
    input: Omit<Promotion, 'id' | 'createdAt'>
  ): Promise<Promotion> {
    return this.repository.create({
      ...input,
      id: uuid(),
      createdAt: new Date()
    });
  }
}