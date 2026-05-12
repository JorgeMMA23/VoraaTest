import { Request, Response } from 'express';
import { FirebaseTableRepository } from '../repositories/FirebaseTableRepository';
import { FirebaseWaiterRepository } from '../repositories/FirebaseWaiterRepository';
import { CreateTableUseCase } from '../../application/use-cases/CreateTableUseCase';
import { AssignWaiterToTableUseCase } from '../../application/use-cases/AssignWaiterToTableUseCase';
import { UpdateTableStatusUseCase } from '../../application/use-cases/UpdateTableStatusUseCase';
import { SendWaiterHelpRequestUseCase } from '../../application/use-cases/SendWaiterHelpRequestUseCase';
import { FirebaseNotificationService } from '../services/FirebaseNotificationService';

const tableRepository =
  new FirebaseTableRepository();

const waiterRepository =
  new FirebaseWaiterRepository();

const notificationService =
  new FirebaseNotificationService();

const createTableUseCase =
  new CreateTableUseCase(tableRepository);

const assignWaiterUseCase =
  new AssignWaiterToTableUseCase(
    tableRepository
  );

const updateStatusUseCase =
  new UpdateTableStatusUseCase(
    tableRepository
  );



export class TableController {
  async create(
    req: Request,
    res: Response
  ): Promise<Response> {
    try {
      const table =
        await createTableUseCase.execute(
          req.body
        );

      return res.status(201).json(table);
    } catch (error) {
      return res.status(500).json({
        error: 'Failed creating table',
      });
    }
  }

  async getAll(
    req: Request,
    res: Response
  ): Promise<Response> {
    try {
      const tables =
        await tableRepository.findAll();

      return res.json(tables);
    } catch (error) {
      return res.status(500).json({
        error: 'Internal server error',
      });
    }
  }

  async getById(
    req: Request,
    res: Response
  ): Promise<Response> {
    try {
      const table =
        await tableRepository.findById(
          req.params.id.toString()
        );

      if (!table) {
        return res.status(404).json({
          error: 'Table not found',
        });
      }

      return res.json(table);
    } catch (error) {
      return res.status(500).json({
        error: 'Internal server error',
      });
    }
  }

  async assignWaiter(
    req: Request,
    res: Response
  ): Promise<Response> {
    try {
      await assignWaiterUseCase.execute(
        req.params.id.toString(),
        req.body.waiterId
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

  async delete(
    req: Request,
    res: Response
  ): Promise<Response> {
    try {
      await tableRepository.delete(
        req.params.id.toString()
      );

      return res.status(204).send();
    } catch (error) {
      return res.status(500).json({
        error: 'Delete failed',
      });
    }
  }
}