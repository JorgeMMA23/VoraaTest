import { Router } from 'express';
import { MenuController } from '../controllers/MenuController';

const controller = new MenuController();

export const menuRoutes = Router();

menuRoutes.post('/', (req, res) => controller.create(req, res));
menuRoutes.get('/', (req, res) => controller.getAll(req, res));
menuRoutes.delete('/:id', (req, res) => controller.delete(req, res));
