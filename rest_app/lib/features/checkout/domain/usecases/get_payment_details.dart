import 'package:rest_app/features/checkout/domain/entities/payment_details_entity.dart';
import 'package:rest_app/features/checkout/domain/repositories/checkout_repository.dart';
import 'package:rest_app/features/menu/domain/entities/cart_item_entity.dart';

class GetPaymentDetails {
  final CheckoutRepository repository;

  GetPaymentDetails(this.repository);

  Future<PaymentDetailsEntity> call(List<CartItemEntity> items) =>
      repository.getPaymentDetails(items);
}
