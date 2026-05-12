import { firestore } from '../../../../config/firebase/firebase';
import { Incident } from '../../domain/entities/Incident';
import { IncidentRepository } from '../../domain/repositories/IncidentRepository';

export class FirebaseIncidentRepository
  implements IncidentRepository
{
  private collection =
    firestore.collection('incidents');

  async create(
    data: Incident
  ): Promise<Incident> {
    await this.collection.doc(data.id).set(data);

    return data;
  }

  async findById(
    id: string
  ): Promise<Incident | null> {
    const doc = await this.collection.doc(id).get();

    if (!doc.exists) {
      return null;
    }

    return doc.data() as Incident;
  }

  async findAll(): Promise<Incident[]> {
    const snapshot =
      await this.collection.get();

    return snapshot.docs.map(
      (doc) =>
        doc.data() as Incident
    );
  }

  async update(
    id: string,
    data: Partial<Incident>
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