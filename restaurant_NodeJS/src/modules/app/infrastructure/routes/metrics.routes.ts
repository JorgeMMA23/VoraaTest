import { Router } from 'express';
import { MetricsController } from '../controllers/MetricsController';

const controller =
  new MetricsController();

export const metricsRoutes = Router();

metricsRoutes.get(
  '/dashboard',
  (req, res) =>
    controller.getRestaurantMetrics(
      req,
      res
    )
);