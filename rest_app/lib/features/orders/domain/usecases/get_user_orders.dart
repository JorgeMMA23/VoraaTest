import 'package:rest_app/features/checkout/data/models/payment_details_model.dart';
import 'package:rest_app/features/orders/domain/repositories/orders_repository.dart';

class GetUserOrders {
  final OrdersRepository repository;

  GetUserOrders(this.repository);

  Future<List<PaymentDetailsModel>> call() {
    return repository.getUserOrders();
  }
}
