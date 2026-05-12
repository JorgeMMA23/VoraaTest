import { Request, Response } from 'express';
import { FirebaseWaiterRepository } from '../repositories/FirebaseWaiterRepository';
import { CreateWaiterUseCase } from '../../application/use-cases/CreateWaiterUseCase';
import { AssignTablesUseCase } from '../../application/use-cases/AssignTablesUseCase';
import { UpdateWaiterStatusUseCase } from '../../application/use-cases/UpdateWaiterStatusUseCase';
import { PromoteWaiterUseCase } from '../../application/use-cases/PromoteWaiterUseCase';

const repository =
  new FirebaseWaiterRepository();

const createWaiterUseCase =
  new CreateWaiterUseCase(repository);

const assignTablesUseCase =
  new AssignTablesUseCase(repository);

const updateStatusUseCase =
  new UpdateWaiterStatusUseCase(repository);

const promoteWaiterUseCase =
  new PromoteWaiterUseCase(repository);

export class WaiterController {
  async create(
    req: Request,
    res: Response
  ): Promise<Response> {
    try {
      const waiter =
        await createWaiterUseCase.execute(
          req.body
        );

      return res.status(201).json(waiter);
    } catch (error) {
      return res.status(500).json({
        error: 'Failed creating waiter',
      });
    }
  }

  async getAll(
    req: Request,
    res: Response
  ): Promise<Response> {
    try {
      const waiters =
        await repository.findAll();

      return res.json(waiters);
    } catch (error) {
      return res.status(500).json({
        error: 'Internal server error',
      });
    }
  }

  async assignTables(
    req: Request,
    res: Response
  ): Promise<Response> {
    try {
      await assignTablesUseCase.execute(
        req.params.id.toString(),
        req.body.tables
      );

      return res.json({
        success: true,
      });
    } catch (error) {
      return res.status(500).json({
        error: 'Assignment failed',
      });
    }
  }

  async updateStatus(
    req: Request,
    res: Response
  ): Promise<Response> {
    try {
      await updateStatusUseCase.execute(
        req.params.id.toString(),
        req.body.status
      );

      return res.json({
        success: true,
      });
    } catch (error) {
      return res.status(500).json({
        error: 'Status update failed',
      });
    }
  }

  async promote(
    req: Request,
    res: Response
  ): Promise<Response> {
    try {
      await promoteWaiterUseCase.execute(
        req.params.id.toString()
      );

      return res.json({
        success: true,
      });
    } catch (error) {
      return res.status(500).json({
        error: 'Promotion failed',
      });
    }
  }

  async updateToken(
    req: Request,
    res: Response
  ): Promise<Response> {
    try {
      await repository.updateToken(
        req.params.id.toString(),
        req.body.tokenDevice
      );

      return res.json({
        success: true,
      });
    } catch (error) {
      return res.status(500).json({
        error: 'Token update failed',
      });
    }
  }
}