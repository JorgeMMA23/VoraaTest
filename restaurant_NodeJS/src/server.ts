import express from 'express';
import cors from 'cors';
import helmet from 'helmet';
import compression from 'compression';
import morgan from 'morgan';

import { menuRoutes } from './modules/app/infrastructure/routes/menu.routes';
import { promotionRoutes } from './modules/app/infrastructure/routes/promotion.routes';
import { paymentRoutes } from './modules/app/infrastructure/routes/payment.routes';
import { firestore } from './config/firebase/firebase';
import { notificationRoutes } from './modules/app/infrastructure/routes/notification.routes';
import { authRoutes } from './modules/app/infrastructure/routes/auth.routes';
import { orderRoutes } from './modules/app/infrastructure/routes/order.routes';
import { waiterRoutes } from './modules/app/infrastructure/routes/waiter.routes';
import { tableRoutes } from './modules/app/infrastructure/routes/table.routes';
import { metricsRoutes } from './modules/app/infrastructure/routes/metrics.routes';
import { incidentRoutes } from './modules/app/infrastructure/routes/incident.routes';

export const app = express();

app.use(cors());
app.use(helmet());
app.use(compression());
app.use(morgan('dev'));
app.use(express.json());

app.get('/health', (_, res) => {
  return res.json({
    success: true
  });
});

app.use('/api/menu', menuRoutes);
app.use('/api/promotions', promotionRoutes);
app.use('/api/payments', paymentRoutes);
app.use('/api/notifications', notificationRoutes);
app.use('/api/auth', authRoutes);
app.use('/api/orders', orderRoutes);
app.use('/api/waiters', waiterRoutes);
app.use('/api/tables', tableRoutes);
app.use('/api/metrics', metricsRoutes);
app.use(
  '/api/incidents',
  incidentRoutes
);
app.post('/api/incidents/:id/messages', async (req, res) => {
  const incidentId = req.params.id;

  const message = {
    authorId: req.body.authorId || 'Restaurant01',
    authorName: req.body.authorName || 'Restaurant',
    content: req.body.content,
    createdAt: new Date(),
  };

  await firestore
    .collection('incidents')
    .doc(incidentId)
    .collection('messages')
    .add(message);

  return res.status(201).json({
    success: true,
    incidentId: incidentId,
    ...message
  });
});

app.get('/api/incidents/:id/messages', async (req, res) => {
  const incidentId = req.params.id;

  const snapshot = await firestore
    .collection('incidents')
    .doc(incidentId)
    .collection('messages')
    .orderBy('createdAt', 'asc')
    .get();

  const messages = snapshot.docs.map((doc) => ({
    id: doc.id,
    ...doc.data(),
  }));

  return res.json(messages);
});