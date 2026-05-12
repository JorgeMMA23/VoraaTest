import { Router } from 'express';

import { AuthController } from '../controllers/AuthController';

import { verifyFirebaseToken } from '../../../../app/middlewares/verifyFirebaseToken';

const controller = new AuthController();

export const authRoutes = Router();

authRoutes.post(
  '/me',
  (req, res) => controller.me(req, res)
);