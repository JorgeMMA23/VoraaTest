import { MenuItem } from '../entities/MenuItem';

export interface MenuRepository {
  create(data: MenuItem): Promise<MenuItem>;
  findById(id: string): Promise<MenuItem | null>;
  findAll(): Promise<MenuItem[]>;
  delete(id: string): Promise<void>;
}
