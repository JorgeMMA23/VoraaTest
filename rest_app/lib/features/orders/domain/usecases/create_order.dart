import 'package:rest_app/features/orders/domain/entities/order_entity.dart';
import 'package:rest_app/features/orders/domain/repositories/orders_repository.dart';

class CreateOrder {
  final OrdersRepository repository;

  CreateOrder(this.repository);

  Future<OrderEntity> call(List<OrderItemEntity> items) {
    return repository.createOrder(items);
  }
}
