import { Request, Response } from 'express';
import { FirebaseIncidentRepository } from '../repositories/FirebaseIncidentRepository';
import { CreateIncidentUseCase } from '../../application/use-cases/CreateIncidentUseCase';
import { ResolveIncidentUseCase } from '../../application/use-cases/ResolveIncidentUseCase';

const repository =
  new FirebaseIncidentRepository();

const createIncidentUseCase =
  new CreateIncidentUseCase(
    repository
  );

const resolveIncidentUseCase =
  new ResolveIncidentUseCase(
    repository
  );

export class IncidentController {
  async create(
    req: Request,
    res: Response
  ): Promise<Response> {
    try {
      const incident =
        await createIncidentUseCase.execute(
          req.body
        );

      return res.status(201).json(
        incident
      );
    } catch (error) {
      console.error(error);

      return res.status(500).json({
        error:
          'Failed creating incident',
      });
    }
  }

  async getAll(
    req: Request,
    res: Response
  ): Promise<Response> {
    try {
      const incidents =
        await repository.findAll();

      return res.json(incidents);
    } catch (error) {
      return res.status(500).json({
        error:
          `Internal server error ${error}`,
      });
    }
  }
  
  async getById(
    req: Request,
    res: Response
  ): Promise<Response> {
    try {
      const incident =
        await repository.findById(
          req.params.id.toString()
        );

      if (!incident) {
        return res.status(404).json({
          error: 'Incident not found',
        });
      }

      return res.json(incident);
    } catch (error) {
      return res.status(500).json({
        error:
          `Internal server error ${error}`,
      });
    }
  }

  async resolve(
    req: Request,
    res: Response
  ): Promise<Response> {
    try {
      await resolveIncidentUseCase.execute(
        req.params.id.toString()
      );

      return res.json({
        success: true,
      });
    } catch (error) {
      return res.status(500).json({
        error:
          'Resolve failed',
      });
    }
  }
}