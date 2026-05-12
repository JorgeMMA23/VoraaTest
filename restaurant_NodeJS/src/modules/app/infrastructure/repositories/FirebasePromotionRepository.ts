import { firestore } from '../../../../config/firebase/firebase';
import { Promotion } from '../../domain/entities/Promotion';
import { PromotionRepository } from '../../domain/repositories/PromotionRepository';

export class FirebasePromotionRepository
  implements PromotionRepository
{
  private collection = firestore.collection('promotions');

  async create(data: Promotion): Promise<Promotion> {
    await this.collection.doc(data.id).set(data);
    return data;
  }

  async update(id: string, data: Partial<Promotion>): Promise<void> {
    await this.collection.doc(id).update(data);
  }

  async findAll(): Promise<Promotion[]> {
    const snapshot = await this.collection.get();

    return snapshot.docs.map((doc) => doc.data() as Promotion);
  }

  async findById(id: string): Promise<Promotion | null> {
    const doc = await this.collection.doc(id).get();

    if (!doc.exists) {
      return null;
    }

    return doc.data() as Promotion;
  }

  async delete(id: string): Promise<void> {
    await this.collection.doc(id).delete();
  }
}