import { Router } from 'express';

import { OrderController } from '../controllers/OrderController';

const controller =
  new OrderController();

export const orderRoutes = Router();

orderRoutes.post(
  '/',
  (req, res) =>
    controller.create(req, res)
);

orderRoutes.get(
  '/',
  (req, res) =>
    controller.getAll(req, res)
);

orderRoutes.get(
  '/tips/paid',
  (req, res) =>
    controller.getTotalTipsPaid(req, res)
);

orderRoutes.post(
  '/:id/coupon/:couponId?',
  (req, res) =>
    controller.getByIdWithCoupon(req, res)
);

orderRoutes.get(
  '/:id',
  (req, res) =>
    controller.getById(req, res)
);

orderRoutes.patch(
  '/:id/status',
  (req, res) =>
    controller.updateStatus(req, res)
);

orderRoutes.delete(
  '/:id',
  (req, res) =>
    controller.delete(req, res)
);

orderRoutes.post(
  '/:id/help',
  (req, res) =>
    controller.sendHelpRequest(req, res)
);