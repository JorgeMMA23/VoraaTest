import { RestaurantMetrics } from '../dtos/RestaurantMetrics';

export interface MetricsRepository {
  getRestaurantMetrics(
    restaurantId: string
  ): Promise<RestaurantMetrics>;
}