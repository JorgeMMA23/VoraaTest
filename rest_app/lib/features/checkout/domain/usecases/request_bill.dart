import 'package:rest_app/features/checkout/domain/entities/payment_details_entity.dart';
import 'package:rest_app/features/checkout/domain/repositories/checkout_repository.dart';

class RequestBill {
  final CheckoutRepository repository;

  RequestBill(this.repository);

  Future<PaymentDetailsEntity> call({
    required String idOrder,
    String? couponId,
    required int tipPercentage,
  }) =>
      repository.requestBill(
        idOrder: idOrder,
        couponId: couponId,
        tipPercentage: tipPercentage,
      );
}
