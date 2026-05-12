import 'package:rest_app/features/checkout/domain/entities/payment_details_entity.dart';
import 'package:rest_app/features/checkout/domain/repositories/checkout_repository.dart';

class ConfirmPayment {
  final CheckoutRepository repository;

  ConfirmPayment(this.repository);

  Future<void> call(String idOrder, PaymentCalculationsEntity? summary) {
    final tipKey = (summary?.selectedTip ?? '0').replaceAll('%', '');
    final tip = summary?.tipOptions[tipKey]?.tip ?? 0.0;

    return repository.confirmPayment(
      idOrder,
      subtotal: summary?.subtotal ?? 0.0,
      discount: summary?.discount ?? 0.0,
      tip: tip,
      total: summary?.total ?? 0.0,
    );
  }
}
