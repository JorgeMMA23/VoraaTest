import 'package:rest_app/features/checkout/data/models/payment_details_model.dart';
import 'package:rest_app/features/orders/domain/entities/order_entity.dart';

abstract class OrdersRepository {
  Future<List<PaymentDetailsModel>> getUserOrders();
  Future<OrderEntity> createOrder(List<OrderItemEntity> items);
  Future<void> requestHelp(String orderId);
}
