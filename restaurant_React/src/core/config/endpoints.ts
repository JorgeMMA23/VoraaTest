/**
 * Catálogo único de endpoints del backend NodeJS (localhost:3000).
 * Mantener aquí evita strings mágicos repartidos en datasources.
 */
export const API_ENDPOINTS = {
  incidents: {
    base: '/incidents',
    byId: (id: string) => `/incidents/${id}`,
    messages: (incidentId: string) => `/incidents/${incidentId}/messages`,
    messageById: (incidentId: string, messageId: string) =>
      `/incidents/${incidentId}/messages/${messageId}`,
  },
  users: {
    base: '/users',
    byId: (id: string) => `/users/${id}`,
  },
  metrics: {
    dashboard: '/metrics/dashboard',
  },
} as const;
