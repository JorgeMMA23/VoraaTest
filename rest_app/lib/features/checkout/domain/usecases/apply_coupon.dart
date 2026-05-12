import 'package:rest_app/features/checkout/domain/entities/order_summary_entity.dart';
import 'package:rest_app/features/checkout/domain/repositories/checkout_repository.dart';
import 'package:rest_app/features/menu/domain/entities/cart_item_entity.dart';

class ApplyCoupon {
  final CheckoutRepository repository;

  ApplyCoupon(this.repository);

  Future<OrderSummaryEntity> call({
    required String promotionId,
    required double subtotal,
    required List<CartItemEntity> items,
  }) =>
      repository.applyCoupon(
        promotionId: promotionId,
        subtotal: subtotal,
        items: items,
      );
}
