import { Waiter } from '../entities/Waiter';

export interface WaiterRepository {
  create(data: Waiter): Promise<Waiter>;

  findById(id: string): Promise<Waiter | null>;

  findByUserId(
    userId: string
  ): Promise<Waiter | null>;

  findAll(): Promise<Waiter[]>;

  update(
    id: string,
    data: Partial<Waiter>
  ): Promise<void>;

  delete(id: string): Promise<void>;

  updateToken(id: string, tokenDevice: string): Promise<void>;
}