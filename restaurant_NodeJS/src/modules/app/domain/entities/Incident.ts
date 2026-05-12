export type IncidentStatus =
  | 'open'
  | 'assigned'
  | 'in_progress'
  | 'resolved'
  | 'closed'
  | 'cancelled';

export type IncidentPriority =
  | 'low'
  | 'medium'
  | 'high'
  | 'critical';

export type IncidentType =
  | 'waiter_call'
  | 'payment_issue'
  | 'food_issue'
  | 'promotion_issue'
  | 'service_issue'
  | 'technical_issue'
  | 'other';

export interface Incident {
  id: string;
  restaurantId: string;
  tableId: string;
  orderId?: string;
  customerId?: string;
  waiterId?: string;
  captainId?: string;
  title: string;
  description: string;
  type: IncidentType;
  priority: IncidentPriority;
  status: IncidentStatus;
  escalated: boolean;
  createdAt: Date;
  updatedAt: Date;
  resolvedAt?: Date;
}