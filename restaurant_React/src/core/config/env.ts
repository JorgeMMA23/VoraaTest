/**
 * Configuración centralizada del entorno.
 * Single source of truth para variables de entorno.
 */
export const env = {
  apiBaseUrl: import.meta.env.VITE_API_BASE_URL ?? 'http://localhost:3000/api',
  apiTimeout: Number(import.meta.env.VITE_API_TIMEOUT ?? 15000),
  isDev: import.meta.env.DEV,
  isProd: import.meta.env.PROD,
  firebase: {
    apiKey: import.meta.env.VITE_FIREBASE_API_KEY as string,
    authDomain: import.meta.env.VITE_FIREBASE_AUTH_DOMAIN as string,
    projectId: import.meta.env.VITE_FIREBASE_PROJECT_ID as string,
    appId: import.meta.env.VITE_FIREBASE_APP_ID as string,
  },
} as const;

export type AppEnv = typeof env;
