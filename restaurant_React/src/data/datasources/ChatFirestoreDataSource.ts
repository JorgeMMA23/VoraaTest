import { collection, onSnapshot, orderBy, query, Timestamp } from 'firebase/firestore';
import { db } from '@core/config/firebase';
import type { ChatMessage } from '@domain/entities/ChatMessage';

function timestampToISO(val: unknown): string {
  if (typeof val === 'string') return val;
  if (val instanceof Timestamp) return val.toDate().toISOString();
  if (val && typeof (val as { seconds: number }).seconds === 'number') {
    return new Date((val as { seconds: number }).seconds * 1000).toISOString();
  }
  return new Date().toISOString();
}

export class ChatFirestoreDataSource {
  subscribe(
    incidentId: string,
    onUpdate: (messages: ChatMessage[]) => void,
  ): () => void {
    const q = query(
      collection(db, 'incidents', incidentId, 'messages'),
      orderBy('createdAt', 'asc'),
    );

    return onSnapshot(q, (snapshot) => {
      const messages: ChatMessage[] = snapshot.docs.map((doc) => {
        const data = doc.data();
        return {
          id: doc.id,
          incidentId,
          authorId: data.authorId ?? '',
          authorName: data.authorName ?? 'Anónimo',
          content: data.content ?? '',
          createdAt: timestampToISO(data.createdAt),
        };
      });
      onUpdate(messages);
    });
  }
}
