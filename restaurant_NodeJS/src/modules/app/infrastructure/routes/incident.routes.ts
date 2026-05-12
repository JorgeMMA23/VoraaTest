import { Router } from 'express';
import { IncidentController } from '../controllers/IncidentController';

const controller =
  new IncidentController();

export const incidentRoutes =
  Router();

incidentRoutes.post(
  '/',
  (req, res) =>
    controller.create(req, res)
);

incidentRoutes.get(
  '/',
  (req, res) =>
    controller.getAll(req, res)
);

incidentRoutes.get(
  '/:id',
  (req, res) =>
    controller.getById(req, res)
);

incidentRoutes.patch(
  '/:id/resolve',
  (req, res) =>
    controller.resolve(req, res)
);