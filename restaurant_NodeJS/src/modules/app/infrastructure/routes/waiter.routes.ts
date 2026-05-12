import { Router } from 'express';

import { WaiterController } from '../controllers/WaiterController';

const controller =
  new WaiterController();

export const waiterRoutes = Router();

waiterRoutes.post(
  '/',
  (req, res) =>
    controller.create(req, res)
);

waiterRoutes.get(
  '/',
  (req, res) =>
    controller.getAll(req, res)
);

waiterRoutes.patch(
  '/:id/tables',
  (req, res) =>
    controller.assignTables(req, res)
);

waiterRoutes.patch(
  '/:id/status',
  (req, res) =>
    controller.updateStatus(req, res)
);

waiterRoutes.patch(
  '/:id/promote',
  (req, res) =>
    controller.promote(req, res)
);

waiterRoutes.patch(
  '/:id/token',
  (req, res) =>
    controller.updateToken(req, res)
);

