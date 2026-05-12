import { Customer } from '../entities/Customer';

export interface CustomerRepository {
  create(data: Customer): Promise<Customer>;
  findById(id: string): Promise<Customer | null>;
}