/**
 * Composition root: aquí (y solo aquí) se decide qué implementaciones
 * concretas se usan. Es el lugar correcto para sustituirlas por mocks
 * cuando se hagan tests.
 */

import { IncidentRepositoryImpl } from '@data/repositories/IncidentRepositoryImpl';
import { ChatRepositoryImpl } from '@data/repositories/ChatRepositoryImpl';
import { UserRepositoryImpl } from '@data/repositories/UserRepositoryImpl';
import { MetricsRepositoryImpl } from '@data/repositories/MetricsRepositoryImpl';

import {
  CreateIncidentUseCase,
  DeleteIncidentUseCase,
  GetIncidentUseCase,
  ListIncidentsUseCase,
  UpdateIncidentUseCase,
} from '@domain/usecases/incident.usecases';

import {
  DeleteMessageUseCase,
  ListMessagesUseCase,
  SendMessageUseCase,
  SubscribeToMessagesUseCase,
  UpdateMessageUseCase,
} from '@domain/usecases/chat.usecases';

import {
  CreateUserUseCase,
  DeleteUserUseCase,
  GetUserUseCase,
  ListUsersUseCase,
  UpdateUserUseCase,
} from '@domain/usecases/user.usecases';

import { GetDashboardMetricsUseCase } from '@domain/usecases/metrics.usecases';

// Repositorios (singletons)
const incidentRepo = new IncidentRepositoryImpl();
const chatRepo = new ChatRepositoryImpl();
const userRepo = new UserRepositoryImpl();
const metricsRepo = new MetricsRepositoryImpl();

export const container = {
  incidents: {
    list: new ListIncidentsUseCase(incidentRepo),
    get: new GetIncidentUseCase(incidentRepo),
    create: new CreateIncidentUseCase(incidentRepo),
    update: new UpdateIncidentUseCase(incidentRepo),
    delete: new DeleteIncidentUseCase(incidentRepo),
  },
  chat: {
    list: new ListMessagesUseCase(chatRepo),
    send: new SendMessageUseCase(chatRepo),
    update: new UpdateMessageUseCase(chatRepo),
    delete: new DeleteMessageUseCase(chatRepo),
    subscribe: new SubscribeToMessagesUseCase(chatRepo),
  },
  users: {
    list: new ListUsersUseCase(userRepo),
    get: new GetUserUseCase(userRepo),
    create: new CreateUserUseCase(userRepo),
    update: new UpdateUserUseCase(userRepo),
    delete: new DeleteUserUseCase(userRepo),
  },
  metrics: {
    dashboard: new GetDashboardMetricsUseCase(metricsRepo),
  },
};

export type AppContainer = typeof container;
