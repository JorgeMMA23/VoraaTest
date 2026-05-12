export interface RestaurantMetrics {
  totalOrders: number;
  totalSales: number;
  incidentsCount: number;
  ordersWithoutIncidents: number;
  incidentRate: number;
  promotionUsageCount: number;
  promotionDiscountAmount: number;
  totalTips: number;
  averageTip: number;
  tipPercentageAverage: number;
}