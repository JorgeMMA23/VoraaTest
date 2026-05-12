import { API_ENDPOINTS } from '@core/config/endpoints';
import { httpClient, type IHttpClient } from '@core/http/HttpClient';
import type { DashboardMetricsDto } from '@data/dto/dto';

export class MetricsRemoteDataSource {
  constructor(private readonly http: IHttpClient = httpClient) {}

  getDashboard(): Promise<DashboardMetricsDto> {
    return this.http.get<DashboardMetricsDto>(API_ENDPOINTS.metrics.dashboard);
  }
}
