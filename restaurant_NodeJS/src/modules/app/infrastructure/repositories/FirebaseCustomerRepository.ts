import { firestore } from '../../../../config/firebase/firebase';
import { Customer } from '../../domain/entities/Customer';
import { CustomerRepository } from '../../domain/repositories/CustomerRepository';

export class FirebaseCustomerRepository
  implements CustomerRepository
{
  private collection = firestore.collection('customers');

  async create(data: Customer): Promise<Customer> {
    await this.collection.doc(data.id).set(data);

    return data;
  }

  async findById(id: string): Promise<Customer | null> {
    const doc = await this.collection.doc(id).get();

    if (!doc.exists) {
      return null;
    }

    return doc.data() as Customer;
  }
}