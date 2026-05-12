import 'package:rest_app/features/checkout/data/datasources/checkout_remote_data_source.dart';
import 'package:rest_app/features/checkout/domain/entities/order_summary_entity.dart';
import 'package:rest_app/features/checkout/domain/entities/payment_details_entity.dart';
import 'package:rest_app/features/checkout/domain/entities/promotion_entity.dart';
import 'package:rest_app/features/checkout/domain/repositories/checkout_repository.dart';
import 'package:rest_app/features/menu/domain/entities/cart_item_entity.dart';

class CheckoutRepositoryImpl implements CheckoutRepository {
  final CheckoutRemoteDataSource remoteDataSource;

  CheckoutRepositoryImpl({required this.remoteDataSource});

  @override
  Future<PaymentDetailsEntity> getPaymentDetails(List<CartItemEntity> items) =>
      remoteDataSource.getPaymentDetails(items);

  @override
  Future<PaymentDetailsEntity> requestBill({
    required String idOrder,
    String? couponId,
    required int tipPercentage,
  }) => remoteDataSource.requestBill(
    idOrder: idOrder,
    couponId: couponId,
    tipPercentage: tipPercentage,
  );

  @override
  Future<void> confirmPayment(
    String idOrder, {
    required double subtotal,
    required double discount,
    required double tip,
    required double total,
  }) =>
      remoteDataSource.confirmPayment(
        idOrder,
        subtotal: subtotal,
        discount: discount,
        tip: tip,
        total: total,
      );

  @override
  Future<List<PromotionEntity>> getAvailableCoupons() =>
      remoteDataSource.getAvailableCoupons();

  @override
  Future<OrderSummaryEntity> applyCoupon({
    required String promotionId,
    required double subtotal,
    required List<CartItemEntity> items,
  }) => remoteDataSource.applyCoupon(
    promotionId: promotionId,
    subtotal: subtotal,
    items: items,
  );
}
