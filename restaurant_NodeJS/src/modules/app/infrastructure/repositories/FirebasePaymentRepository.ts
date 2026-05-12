import { firestore } from '../../../../config/firebase/firebase';
import { Payment } from '../../domain/entities/Payment';
import { PaymentRepository } from '../../domain/repositories/PaymentRepository';

export class FirebasePaymentRepository
  implements PaymentRepository
{
  private collection = firestore.collection('payments');

  async create(data: Payment): Promise<Payment> {
    await this.collection.doc(data.id).set(data);

    return data;
  }

  async findById(id: string): Promise<Payment | null> {
    const doc = await this.collection.doc(id).get();

    if (!doc.exists) {
      return null;
    }

    return doc.data() as Payment;
  }

  async updateStatus(id: string, status: string): Promise<void> {
    await this.collection.doc(id).update({
      status
    });
  }
}