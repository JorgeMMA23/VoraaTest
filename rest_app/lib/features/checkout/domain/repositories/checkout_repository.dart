import 'package:rest_app/features/checkout/domain/entities/order_summary_entity.dart';
import 'package:rest_app/features/checkout/domain/entities/payment_details_entity.dart';
import 'package:rest_app/features/checkout/domain/entities/promotion_entity.dart';
import 'package:rest_app/features/menu/domain/entities/cart_item_entity.dart';

abstract class CheckoutRepository {
  Future<PaymentDetailsEntity> getPaymentDetails(List<CartItemEntity> items);
  Future<PaymentDetailsEntity> requestBill({
    required String idOrder,
    String? couponId,
    required int tipPercentage,
  });
  Future<void> confirmPayment(
    String idOrder, {
    required double subtotal,
    required double discount,
    required double tip,
    required double total,
  });
  Future<List<PromotionEntity>> getAvailableCoupons();
  Future<OrderSummaryEntity> applyCoupon({
    required String promotionId,
    required double subtotal,
    required List<CartItemEntity> items,
  });
}
