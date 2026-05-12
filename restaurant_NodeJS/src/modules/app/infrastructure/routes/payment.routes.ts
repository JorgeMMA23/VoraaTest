import { Router } from 'express';
import { PaymentController } from '../controllers/PaymentController';

const controller = new PaymentController();

export const paymentRoutes = Router();

paymentRoutes.post(
  '/customer',
  (req, res) => controller.createCustomer(req, res)
);

paymentRoutes.post(
  '/process',
  (req, res) => controller.processPayment(req, res)
);

paymentRoutes.get(
  '/:id',
  (req, res) => controller.getPayment(req, res)
);