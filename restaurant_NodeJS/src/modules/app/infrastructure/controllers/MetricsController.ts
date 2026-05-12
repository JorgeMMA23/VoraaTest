import { Request, Response } from 'express';
import { FirebaseMetricsRepository } from '../repositories/FirebaseMetricsRepository';
import { GetRestaurantMetricsUseCase } from '../../application/use-cases/GetRestaurantMetricsUseCase';

const repository =
  new FirebaseMetricsRepository();

const getMetricsUseCase =
  new GetRestaurantMetricsUseCase(
    repository
  );

export class MetricsController {
  async getRestaurantMetrics(
    req: Request,
    res: Response
  ): Promise<Response> {
    try {
      const restaurantId =
        req.params.restaurantId || 'REST_001';

      const metrics =
        await getMetricsUseCase.execute(
          restaurantId.toString()
        );

      return res.json(metrics);
    } catch (error) {
      console.error(error);

      return res.status(500).json({
        error:
          'Failed obtaining metrics',
      });
    }
  }
}