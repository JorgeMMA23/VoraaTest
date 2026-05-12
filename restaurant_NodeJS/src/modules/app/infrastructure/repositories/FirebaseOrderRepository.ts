import { firestore } from '../../../../config/firebase/firebase';

import { Order } from '../../domain/entities/Order';

import { OrderRepository } from '../../domain/repositories/OrderRepository';

export class FirebaseOrderRepository
  implements OrderRepository
{
  private collection =
    firestore.collection('orders');

  async create(data: Order): Promise<Order> {
    await this.collection.doc(data.id).set(data);

    return data;
  }

  async findById(
    id: string
  ): Promise<Order | null> {
    const doc = await this.collection.doc(id).get();

    if (!doc.exists) {
      return null;
    }

    return doc.data() as Order;
  }

  async findAll(): Promise<Order[]> {
    const snapshot =
      await this.collection.get();

    return snapshot.docs.map(
      (doc) => doc.data() as Order
    );
  }

  async update(
    id: string,
    data: Partial<Order>
  ): Promise<void> {
    await this.collection.doc(id).update({
      ...data,
      updatedAt: new Date(),
    });
  }

  async delete(id: string): Promise<void> {
    await this.collection.doc(id).delete();
  }

  async getTotalTipsByPaidOrders(): Promise<number> {
    const snapshot = await this.collection
      .where('status', '==', 'paid')
      .get();

    return snapshot.docs.reduce(
      (acc, doc) => acc + ((doc.data() as Order).tip || 0),
      0
    );
  }
}