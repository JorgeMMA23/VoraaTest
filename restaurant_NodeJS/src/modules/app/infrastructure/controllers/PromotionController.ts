import { Request, Response } from 'express';
import { FirebasePromotionRepository } from '../repositories/FirebasePromotionRepository';
import { CreatePromotionUseCase } from '../../application/use-cases/CreatePromotionUseCase';
import { UpdatePromotionUseCase } from '../../application/use-cases/UpdatePromotionUseCase';

const repository = new FirebasePromotionRepository();
const createUseCase = new CreatePromotionUseCase(repository);
const updateUseCase = new UpdatePromotionUseCase(repository);

export class PromotionController {
  async create(req: Request, res: Response): Promise<Response> {
    try {
      const promotion = await createUseCase.execute(req.body);

      return res.status(201).json(promotion);
    } catch (error) {
      return res.status(500).json({
        error: 'Internal server error'
      });
    }
  }

  async update(req: Request, res: Response): Promise<Response> {
    try {
      await updateUseCase.execute(req.params.id.toString(), req.body);

      return res.status(200).json({
        success: true
      });
    } catch (error) {
      return res.status(500).json({
        error: 'Internal server error'
      });
    }
  }

  async getAll(req: Request, res: Response): Promise<Response> {
    try {
      const promotions = await repository.findAll();

      return res.json(promotions);
    } catch (error) {
      return res.status(500).json({
        error: 'Internal server error'
      });
    }
  }

  async getById(req: Request, res: Response): Promise<Response> {
    try {
      const promotion = await repository.findById(req.params.id.toString());

      if (!promotion) {
        return res.status(404).json({
          error: 'Promotion not found'
        });
      }

      return res.json(promotion);
    } catch (error) {
      return res.status(500).json({
        error: 'Internal server error'
      });
    }
  }

  async delete(req: Request, res: Response): Promise<Response> {
    try {
      await repository.delete(req.params.id.toString());

      return res.status(204).send();
    } catch (error) {
      return res.status(500).json({
        error: 'Internal server error'
      });
    }
  }
}