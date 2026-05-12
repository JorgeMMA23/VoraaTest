/**
 * Errores de la aplicación. Permiten a la capa de presentación
 * reaccionar de forma específica según el tipo de fallo.
 */

export class AppError extends Error {
  public readonly code: string;
  public readonly cause?: unknown;

  constructor(message: string, code = 'APP_ERROR', cause?: unknown) {
    super(message);
    this.name = 'AppError';
    this.code = code;
    this.cause = cause;
  }
}

export class NetworkError extends AppError {
  constructor(message = 'Error de red', cause?: unknown) {
    super(message, 'NETWORK_ERROR', cause);
    this.name = 'NetworkError';
  }
}

export class HttpError extends AppError {
  public readonly status: number;

  constructor(status: number, message: string, cause?: unknown) {
    super(message, `HTTP_${status}`, cause);
    this.name = 'HttpError';
    this.status = status;
  }
}

export class NotFoundError extends AppError {
  constructor(resource: string) {
    super(`Recurso no encontrado: ${resource}`, 'NOT_FOUND');
    this.name = 'NotFoundError';
  }
}

export class ValidationError extends AppError {
  public readonly fields: Record<string, string>;

  constructor(message: string, fields: Record<string, string> = {}) {
    super(message, 'VALIDATION_ERROR');
    this.name = 'ValidationError';
    this.fields = fields;
  }
}
