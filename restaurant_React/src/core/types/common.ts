/**
 * Tipos transversales de la aplicación.
 */

export type Nullable<T> = T | null;

export interface PaginatedResponse<T> {
  data: T[];
  total: number;
  page: number;
  pageSize: number;
}

export interface PaginationParams {
  page?: number;
  pageSize?: number;
}

/**
 * Patrón Result para forzar el manejo explícito de errores
 * sin lanzar excepciones a la capa de presentación.
 */
export type Result<T, E = Error> =
  | { success: true; data: T }
  | { success: false; error: E };

export const Ok = <T>(data: T): Result<T, never> => ({ success: true, data });
export const Err = <E>(error: E): Result<never, E> => ({ success: false, error });
