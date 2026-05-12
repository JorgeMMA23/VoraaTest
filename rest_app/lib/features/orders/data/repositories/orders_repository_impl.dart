import 'package:rest_app/features/checkout/data/models/payment_details_model.dart';
import 'package:rest_app/features/orders/data/datasources/orders_remote_data_source.dart';
import 'package:rest_app/features/orders/data/models/order_model.dart';
import 'package:rest_app/features/orders/domain/entities/order_entity.dart';
import 'package:rest_app/features/orders/domain/repositories/orders_repository.dart';

class OrdersRepositoryImpl implements OrdersRepository {
  final OrdersRemoteDataSource remoteDataSource;

  OrdersRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<PaymentDetailsModel>> getUserOrders() {
    return remoteDataSource.getUserOrders();
  }

  @override
  Future<OrderEntity> createOrder(List<OrderItemEntity> items) {
    final models = items
        .map((item) => OrderItemModel.fromEntity(item))
        .toList();
    return remoteDataSource.createOrder(models);
  }

  @override
  Future<void> requestHelp(String orderId) =>
      remoteDataSource.requestHelp(orderId);
}
