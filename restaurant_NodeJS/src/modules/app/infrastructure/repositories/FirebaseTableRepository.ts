import { firestore } from '../../../../config/firebase/firebase';
import { RestaurantTable } from '../../domain/entities/Table';
import { TableRepository } from '../../domain/repositories/TableRepository';

export class FirebaseTableRepository
  implements TableRepository
{
  private collection =
    firestore.collection('tables');

  async create(
    data: RestaurantTable
  ): Promise<RestaurantTable> {
    await this.collection.doc(data.id).set(data);

    return data;
  }

  async findById(
    id: string
  ): Promise<RestaurantTable | null> {
    const doc = await this.collection.doc(id).get();

    if (!doc.exists) {
      return null;
    }

    return doc.data() as RestaurantTable;
  }

  async findAll(): Promise<RestaurantTable[]> {
    const snapshot =
      await this.collection.get();

    return snapshot.docs.map(
      (doc) =>
        doc.data() as RestaurantTable
    );
  }

  async update(
    id: string,
    data: Partial<RestaurantTable>
  ): Promise<void> {
    await this.collection.doc(id).update({
      ...data,
      updatedAt: new Date(),
    });
  }

  async delete(id: string): Promise<void> {
    await this.collection.doc(id).delete();
  }
}