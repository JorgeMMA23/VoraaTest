import { RestaurantMetrics } from '../../domain/dtos/RestaurantMetrics';
import { MetricsRepository } from '../../domain/repositories/MetricsRepository';

export class GetRestaurantMetricsUseCase {
  constructor(
    private repository: MetricsRepository
  ) {}

  async execute(
    restaurantId: string
  ): Promise<RestaurantMetrics> {
    return this.repository.getRestaurantMetrics(
      restaurantId
    );
  }
}