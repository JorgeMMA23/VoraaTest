import { firestore } from '../../../../config/firebase/firebase';
import { MenuRepository } from '../../domain/repositories/MenuRepository';
import { MenuItem } from '../../domain/entities/MenuItem';

export class FirebaseMenuRepository implements MenuRepository {
  private collection = firestore.collection('menu');

  async create(data: MenuItem): Promise<MenuItem> {
    await this.collection.doc(data.id).set(data);
    return data;
  }

  async findById(id: string): Promise<MenuItem | null> {
    const doc = await this.collection.doc(id).get();

    if (!doc.exists) {
      return null;
    }

    return doc.data() as MenuItem;
  }

  async findAll(): Promise<MenuItem[]> {
    const snapshot = await this.collection.get();
    return snapshot.docs.map((doc) => doc.data() as MenuItem);
  }

  async delete(id: string): Promise<void> {
    await this.collection.doc(id).delete();
  }
}
