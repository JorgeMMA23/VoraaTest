import { RestaurantTable } from '../entities/Table';

export interface TableRepository {
  create(
    data: RestaurantTable
  ): Promise<RestaurantTable>;

  findById(
    id: string
  ): Promise<RestaurantTable | null>;

  findAll(): Promise<RestaurantTable[]>;

  update(
    id: string,
    data: Partial<RestaurantTable>
  ): Promise<void>;

  delete(id: string): Promise<void>;
}