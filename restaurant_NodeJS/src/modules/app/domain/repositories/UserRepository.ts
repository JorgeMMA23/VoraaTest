import { User } from '../entities/User';

export interface UserRepository {
  create(data: User): Promise<User>;

  findById(id: string): Promise<User | null>;

  findByEmail(email: string): Promise<User | null>;

  update(
    id: string,
    data: Partial<User>
  ): Promise<void>;
}