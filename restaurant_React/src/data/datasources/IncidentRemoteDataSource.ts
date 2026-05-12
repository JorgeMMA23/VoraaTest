import { API_ENDPOINTS } from '@core/config/endpoints';
import { httpClient, type IHttpClient } from '@core/http/HttpClient';
import type { IncidentDto } from '@data/dto/dto';
import type {
  CreateIncidentInput,
  UpdateIncidentInput,
} from '@domain/entities/Incident';

/**
 * Único punto que conoce los endpoints HTTP de incidencias.
 * Si mañana el backend cambia de Node a otro, solo se toca aquí.
 */
export class IncidentRemoteDataSource {
  constructor(private readonly http: IHttpClient = httpClient) {}

  list(): Promise<IncidentDto[]> {
    return this.http.get<IncidentDto[]>(API_ENDPOINTS.incidents.base);
  }
  getById(id: string): Promise<IncidentDto> {
    return this.http.get<IncidentDto>(API_ENDPOINTS.incidents.byId(id));
  }
  create(input: CreateIncidentInput): Promise<IncidentDto> {
    return this.http.post<IncidentDto, CreateIncidentInput>(
      API_ENDPOINTS.incidents.base,
      input,
    );
  }
  update(id: string, input: UpdateIncidentInput): Promise<IncidentDto> {
    return this.http.put<IncidentDto, UpdateIncidentInput>(
      API_ENDPOINTS.incidents.byId(id),
      input,
    );
  }
  delete(id: string): Promise<void> {
    return this.http.delete<void>(API_ENDPOINTS.incidents.byId(id));
  }
}
