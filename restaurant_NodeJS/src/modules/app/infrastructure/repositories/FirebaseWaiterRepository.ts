import { firestore } from '../../../../config/firebase/firebase';

import { Waiter } from '../../domain/entities/Waiter';

import { WaiterRepository } from '../../domain/repositories/WaiterRepository';

export class FirebaseWaiterRepository
  implements WaiterRepository
{
  private collection =
    firestore.collection('waiters');

  async create(data: Waiter): Promise<Waiter> {
    await this.collection.doc(data.id).set(data);

    return data;
  }

  async findById(
    id: string
  ): Promise<Waiter | null> {
    const doc = await this.collection.doc(id).get();

    if (!doc.exists) {
      return null;
    }

    return doc.data() as Waiter;
  }

  async findByUserId(
    userId: string
  ): Promise<Waiter | null> {
    const snapshot = await this.collection
      .where('userId', '==', userId)
      .limit(1)
      .get();

    if (snapshot.empty) {
      return null;
    }

    return snapshot.docs[0].data() as Waiter;
  }

  async findAll(): Promise<Waiter[]> {
    const snapshot =
      await this.collection.get();

    return snapshot.docs.map(
      (doc) => doc.data() as Waiter
    );
  }

  async update(
    id: string,
    data: Partial<Waiter>
  ): Promise<void> {
    await this.collection.doc(id).update({
      ...data,
      updatedAt: new Date(),
    });
  }

  async delete(id: string): Promise<void> {
    await this.collection.doc(id).delete();
  }

  async updateToken(id: string, tokenDevice: string): Promise<void> {
    console.log(tokenDevice)
    await this.collection.doc(id).update({
      tokenDevice: tokenDevice,
      updatedAt: new Date(),
    });
  }
}