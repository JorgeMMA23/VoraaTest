import { v4 as uuid } from 'uuid';
import { MenuRepository } from '../../domain/repositories/MenuRepository';
import { MenuItem } from '../../domain/entities/MenuItem';

export class CreateMenuItemUseCase {
  constructor(private repository: MenuRepository) {}

  async execute(
    input: Omit<MenuItem, 'id' | 'createdAt'>
  ): Promise<MenuItem> {
    return this.repository.create({
      ...input,
      id: uuid(),
      createdAt: new Date()
    });
  }
}
