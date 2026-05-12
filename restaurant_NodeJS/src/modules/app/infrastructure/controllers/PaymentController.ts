import { Request, Response } from 'express';
import { FirebasePaymentRepository } from '../repositories/FirebasePaymentRepository';
import { FirebaseCustomerRepository } from '../repositories/FirebaseCustomerRepository';
import { ConektaService } from '../services/ConektaService';
import { CreateCustomerUseCase } from '../../application/use-cases/CreateCustomerUseCase';
import { ProcessPaymentUseCase } from '../../application/use-cases/ProcessPaymentUseCase';

const paymentRepository = new FirebasePaymentRepository();
const customerRepository = new FirebaseCustomerRepository();
const conektaService = new ConektaService();

const createCustomerUseCase =
  new CreateCustomerUseCase(
    customerRepository,
    conektaService
  );

const processPaymentUseCase =
  new ProcessPaymentUseCase(
    paymentRepository,
    conektaService
  );
export class PaymentController {
  async createCustomer(
    req: Request,
    res: Response
  ): Promise<Response> {
    try {
      const customer =
        await createCustomerUseCase.execute(req.body);

      return res.status(201).json(customer);
    } catch (error) {
      return res.status(500).json({
        error: 'Error creating customer'
      });
    }
  }

  async processPayment(
    req: Request,
    res: Response
  ): Promise<Response> {
    try {
      const payment =
        await processPaymentUseCase.execute(req.body);

      return res.status(201).json(payment);
    } catch (error) {
      return res.status(500).json({
        error: 'Payment failed'
      });
    }
  }

  async getPayment(
    req: Request,
    res: Response
  ): Promise<Response> {
    try {
      const payment = await paymentRepository.findById(
        req.params.id.toString()
      );

      if (!payment) {
        return res.status(404).json({
          error: 'Payment not found'
        });
      }

      return res.json(payment);
    } catch (error) {
      return res.status(500).json({
        error: 'Internal server error'
      });
    }
  }
}