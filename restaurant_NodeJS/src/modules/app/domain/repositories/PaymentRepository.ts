import { Payment } from '../entities/Payment';

export interface PaymentRepository {
  create(data: Payment): Promise<Payment>;
  findById(id: string): Promise<Payment | null>;
  updateStatus(id: string, status: string): Promise<void>;
}