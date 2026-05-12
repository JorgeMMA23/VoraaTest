import { firestore } from '../../../../config/firebase/firebase';

import { User } from '../../domain/entities/User';
import { UserRepository } from '../../domain/repositories/UserRepository';

export class FirebaseUserRepository
  implements UserRepository
{
  private collection =
    firestore.collection('users');

  async create(data: User): Promise<User> {
    await this.collection.doc(data.id).set(data);

    return data;
  }

  async findById(
    id: string
  ): Promise<User | null> {
    const doc = await this.collection.doc(id).get();

    if (!doc.exists) {
      return null;
    }

    return doc.data() as User;
  }

  async findByEmail(
    email: string
  ): Promise<User | null> {
    const snapshot = await this.collection
      .where('email', '==', email)
      .limit(1)
      .get();

    if (snapshot.empty) {
      return null;
    }

    return snapshot.docs[0].data() as User;
  }

  async update(
    id: string,
    data: Partial<User>
  ): Promise<void> {
    await this.collection.doc(id).update(data);
  }
}