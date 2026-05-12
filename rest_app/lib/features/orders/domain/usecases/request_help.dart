import 'package:rest_app/features/orders/domain/repositories/orders_repository.dart';

class RequestHelp {
  final OrdersRepository repository;

  RequestHelp(this.repository);

  Future<void> call(String orderId) => repository.requestHelp(orderId);
}
