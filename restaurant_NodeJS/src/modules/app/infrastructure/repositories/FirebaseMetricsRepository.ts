import { firestore } from '../../../../config/firebase/firebase';
import { RestaurantMetrics } from '../../domain/dtos/RestaurantMetrics';
import { MetricsRepository } from '../../domain/repositories/MetricsRepository';

export class FirebaseMetricsRepository
  implements MetricsRepository
{
  async getRestaurantMetrics(
    restaurantId: string
  ): Promise<RestaurantMetrics> {
    const ordersSnapshot =
      await firestore
        .collection('orders')
        .where(
          'restaurantId',
          '==',
          restaurantId
        )
        .get();

    const incidentsSnapshot =
      await firestore
        .collection('incidents')
        .where(
          'restaurantId',
          '==',
          restaurantId
        )
        .get();

    const promotionsSnapshot =
      await firestore
        .collection('promotions')
        .where(
          'restaurantId',
          '==',
          restaurantId
        )
        .get();

    const orders =
      ordersSnapshot.docs.map((doc) =>
        doc.data()
      );

    const incidents =
      incidentsSnapshot.docs.map((doc) =>
        doc.data()
      );

    const promotions =
      promotionsSnapshot.docs.map((doc) =>
        doc.data()
      );

    const totalOrders = orders.length;

    const totalSales = orders.reduce(
      (acc, order: any) =>
        acc + (order.total || 0),
      0
    );

    const totalTips = orders.reduce(
      (acc, order: any) =>
        acc + (order.tip || 0),
      0
    );

    const averageTip =
      totalOrders > 0
        ? totalTips / totalOrders
        : 0;

    const tipPercentageAverage =
      totalSales > 0
        ? (totalTips / totalSales) * 100
        : 0;

    const incidentsCount =
      incidents.length;

    const ordersWithoutIncidents =
      totalOrders - incidentsCount;

    const incidentRate =
      totalOrders > 0
        ? (incidentsCount /
            totalOrders) *
          100
        : 0;

    const promotionUsageCount =
      promotions.reduce(
        (acc, promotion: any) =>
          acc +
          (promotion.usageCount || 0),
        0
      );

    const promotionDiscountAmount =
      promotions.reduce(
        (acc, promotion: any) =>
          acc +
          (promotion.totalDiscountAmount ||
            0),
        0
      );

    return {
      totalOrders,
      totalSales,
      incidentsCount,
      ordersWithoutIncidents,
      incidentRate,
      promotionUsageCount,
      promotionDiscountAmount,
      totalTips,
      averageTip,
      tipPercentageAverage,
    };
  }
}