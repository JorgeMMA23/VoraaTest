import { Request, Response } from 'express';
import { FirebaseMenuRepository } from '../repositories/FirebaseMenuRepository';
import { CreateMenuItemUseCase } from '../../application/use-cases/CreateMenuItemUseCase';

const repository = new FirebaseMenuRepository();
const createUseCase = new CreateMenuItemUseCase(repository);

export class MenuController {
  async create(req: Request, res: Response): Promise<Response> {
    try {
      const item = await createUseCase.execute(req.body);
      return res.status(201).json(item);
    } catch (error) {
      return res.status(500).json({ error: 'Internal server error' });
    }
  }

  async getAll(req: Request, res: Response): Promise<Response> {
    try {
      const items = await repository.findAll();
      return res.json(items);
    } catch (error) {
      return res.status(500).json({ error: 'Internal server error' });
    }
  }

  async delete(req: Request, res: Response): Promise<Response> {
    try {
      await repository.delete(req.params.id.toString());
      return res.status(204).send();
    } catch (error) {
      return res.status(500).json({ error: 'Internal server error' });
    }
  }
}
