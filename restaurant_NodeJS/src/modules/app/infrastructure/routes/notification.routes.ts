import { Router } from 'express';
import { NotificationController } from '../controllers/NotificationController';

const controller = new NotificationController();

export const notificationRoutes = Router();

notificationRoutes.post(
  '/device',
  (req, res) =>
    controller.sendToUser(req, res)
);