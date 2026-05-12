import { PromotionRepository } from '../../domain/repositories/PromotionRepository';

export class UpdatePromotionUseCase {
  constructor(private repository: PromotionRepository) {}

  async execute(id: string, data: any): Promise<void> {
    await this.repository.update(id, data);
  }
}