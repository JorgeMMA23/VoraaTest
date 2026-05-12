import { Router } from 'express';
import { PromotionController } from '../controllers/PromotionController';

const controller = new PromotionController();

export const promotionRoutes = Router();

promotionRoutes.post('/', (req, res) => controller.create(req, res));
promotionRoutes.put('/:id', (req, res) => controller.update(req, res));
promotionRoutes.get('/', (req, res) => controller.getAll(req, res));
promotionRoutes.get('/:id', (req, res) => controller.getById(req, res));
promotionRoutes.delete('/:id', (req, res) => controller.delete(req, res));