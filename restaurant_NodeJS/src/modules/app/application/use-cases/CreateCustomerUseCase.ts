import { v4 as uuid } from 'uuid';
import { CustomerRepository } from '../../domain/repositories/CustomerRepository';
import { Customer } from '../../domain/entities/Customer';
import { ConektaService } from '../../infrastructure/services/ConektaService';

export class CreateCustomerUseCase {
  constructor(
    private repository: CustomerRepository,
    private conektaService: ConektaService
  ) {}

  async execute(input: {
    name: string;
    email: string;
    phone: string;
  }): Promise<Customer> {
    const conektaCustomer =
      await this.conektaService.createCustomer(input);

    const customer: Customer = {
      id: uuid(),
      name: input.name,
      email: input.email,
      phone: input.phone,
      conektaCustomerId: conektaCustomer.id,
      createdAt: new Date()
    };

    return this.repository.create(customer);
  }
}
