import { Router } from 'express';
import { TableController } from '../controllers/TableController';

const controller =
  new TableController();

export const tableRoutes = Router();

tableRoutes.post(
  '/',
  (req, res) =>
    controller.create(req, res)
);

tableRoutes.get(
  '/',
  (req, res) =>
    controller.getAll(req, res)
);

tableRoutes.get(
  '/:id',
  (req, res) =>
    controller.getById(req, res)
);

tableRoutes.patch(
  '/:id/assign-waiter',
  (req, res) =>
    controller.assignWaiter(req, res)
);

tableRoutes.patch(
  '/:id/status',
  (req, res) =>
    controller.updateStatus(req, res)
);

tableRoutes.delete(
  '/:id',
  (req, res) =>
    controller.delete(req, res)
);