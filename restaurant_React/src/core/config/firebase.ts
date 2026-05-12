import { initializeApp, getApps, getApp } from 'firebase/app';
import { initializeFirestore, getFirestore, memoryLocalCache } from 'firebase/firestore';
import { env } from './env';

const isNew = !getApps().length;
const app = isNew ? initializeApp(env.firebase) : getApp();

// memoryLocalCache evita IndexedDB y la sincronización entre pestañas
// que causa el error "No Listener: tabs:outgoing.message.ready"
export const db = isNew
  ? initializeFirestore(app, { localCache: memoryLocalCache() })
  : getFirestore(app);
