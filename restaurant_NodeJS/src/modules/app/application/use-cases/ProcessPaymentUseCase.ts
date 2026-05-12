import { v4 as uuid } from 'uuid';
import { PaymentRepository } from '../../domain/repositories/PaymentRepository';
import { Payment } from '../../domain/entities/Payment';
import { ConektaService } from '../../infrastructure/services/ConektaService';

export class ProcessPaymentUseCase {
  constructor(
    private repository: PaymentRepository,
    private conektaService: ConektaService
  ) {}

  async execute(input: {
    orderId: string;
    customerId: string;
    amount: number;
    tip: number;
    tokenId: string;
  }): Promise<Payment> {

    const total = input.amount + input.tip;

    const conektaOrder =
      await this.conektaService.createOrder({
        customerId: input.customerId,
        amount: total,
        tokenId: input.tokenId,
        description: `Order ${input.orderId}`
      });

    const payment: Payment = {
      id: uuid(),
      orderId: input.orderId,
      customerId: input.customerId,
      amount: input.amount,
      tip: input.tip,
      total,
      currency: 'MXN',
      status: 'paid',
      paymentMethod: 'card',
      conektaOrderId: conektaOrder.id,
      createdAt: new Date()
    };

    return this.repository.create(payment);
  }
}