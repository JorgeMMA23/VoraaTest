import { API_ENDPOINTS } from '@core/config/endpoints';
import { httpClient, type IHttpClient } from '@core/http/HttpClient';
import type { ChatMessageDto } from '@data/dto/dto';
import type {
  CreateMessageInput,
  UpdateMessageInput,
} from '@domain/entities/ChatMessage';

export class ChatRemoteDataSource {
  constructor(private readonly http: IHttpClient = httpClient) {}

  listByIncident(incidentId: string): Promise<ChatMessageDto[]> {
    return this.http.get<ChatMessageDto[]>(API_ENDPOINTS.incidents.messages(incidentId));
  }

  create(incidentId: string, input: CreateMessageInput): Promise<ChatMessageDto> {
    return this.http.post<ChatMessageDto, CreateMessageInput>(
      API_ENDPOINTS.incidents.messages(incidentId),
      input,
    );
  }

  update(
    incidentId: string,
    messageId: string,
    input: UpdateMessageInput,
  ): Promise<ChatMessageDto> {
    return this.http.put<ChatMessageDto, UpdateMessageInput>(
      API_ENDPOINTS.incidents.messageById(incidentId, messageId),
      input,
    );
  }

  delete(incidentId: string, messageId: string): Promise<void> {
    return this.http.delete<void>(API_ENDPOINTS.incidents.messageById(incidentId, messageId));
  }
}
