import { env } from '@core/config/env';
import { HttpError, NetworkError, NotFoundError } from '@core/errors/AppError';

/**
 * Cliente HTTP. Encapsula fetch para que el resto de la app
 * no dependa directamente de la API del navegador (Dependency Inversion).
 */

export interface RequestOptions {
  signal?: AbortSignal;
  headers?: Record<string, string>;
  params?: Record<string, string | number | boolean | undefined>;
}

export interface IHttpClient {
  get<T>(path: string, options?: RequestOptions): Promise<T>;
  post<T, B = unknown>(path: string, body?: B, options?: RequestOptions): Promise<T>;
  put<T, B = unknown>(path: string, body?: B, options?: RequestOptions): Promise<T>;
  patch<T, B = unknown>(path: string, body?: B, options?: RequestOptions): Promise<T>;
  delete<T = void>(path: string, options?: RequestOptions): Promise<T>;
}

const buildUrl = (
  baseUrl: string,
  path: string,
  params?: RequestOptions['params'],
): string => {
  const url = new URL(path.replace(/^\//, ''), baseUrl.endsWith('/') ? baseUrl : `${baseUrl}/`);
  if (params) {
    Object.entries(params).forEach(([k, v]) => {
      if (v !== undefined && v !== null) url.searchParams.append(k, String(v));
    });
  }
  return url.toString();
};

export class HttpClient implements IHttpClient {
  constructor(
    private readonly baseUrl: string = env.apiBaseUrl,
    private readonly timeoutMs: number = env.apiTimeout,
  ) {}

  private async request<T>(
    method: string,
    path: string,
    body?: unknown,
    options: RequestOptions = {},
  ): Promise<T> {
    const controller = new AbortController();
    const timeout = setTimeout(() => controller.abort(), this.timeoutMs);
    const signal = options.signal ?? controller.signal;

    try {
      const response = await fetch(buildUrl(this.baseUrl, path, options.params), {
        method,
        signal,
        headers: {
          'Content-Type': 'application/json',
          Accept: 'application/json',
          ...options.headers,
        },
        body: body !== undefined ? JSON.stringify(body) : undefined,
      });

      if (!response.ok) {
        const text = await response.text().catch(() => '');
        if (response.status === 404) {
          throw new NotFoundError(path);
        }
        throw new HttpError(
          response.status,
          text || `Solicitud fallida con estado ${response.status}`,
        );
      }

      if (response.status === 204) return undefined as T;

      const contentType = response.headers.get('content-type') ?? '';
      if (contentType.includes('application/json')) {
        return (await response.json()) as T;
      }
      return (await response.text()) as unknown as T;
    } catch (error) {
      if (error instanceof HttpError || error instanceof NotFoundError) throw error;
      if (error instanceof DOMException && error.name === 'AbortError') {
        throw new NetworkError('La solicitud fue cancelada o expiró', error);
      }
      throw new NetworkError('No se pudo conectar con el servidor', error);
    } finally {
      clearTimeout(timeout);
    }
  }

  get<T>(path: string, options?: RequestOptions): Promise<T> {
    return this.request<T>('GET', path, undefined, options);
  }
  post<T, B = unknown>(path: string, body?: B, options?: RequestOptions): Promise<T> {
    return this.request<T>('POST', path, body, options);
  }
  put<T, B = unknown>(path: string, body?: B, options?: RequestOptions): Promise<T> {
    return this.request<T>('PUT', path, body, options);
  }
  patch<T, B = unknown>(path: string, body?: B, options?: RequestOptions): Promise<T> {
    return this.request<T>('PATCH', path, body, options);
  }
  delete<T = void>(path: string, options?: RequestOptions): Promise<T> {
    return this.request<T>('DELETE', path, undefined, options);
  }
}

/** Instancia compartida. Se puede sustituir fácilmente en tests. */
export const httpClient: IHttpClient = new HttpClient();
