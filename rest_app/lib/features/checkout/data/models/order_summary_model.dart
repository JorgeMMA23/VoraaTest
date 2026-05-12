import 'package:rest_app/features/checkout/domain/entities/order_summary_entity.dart';

class OrderSummaryModel extends OrderSummaryEntity {
  const OrderSummaryModel({
    required super.subtotal,
    required super.discount,
    required super.tipAmount,
    required super.total,
    required super.tipPercentage,
    super.appliedCouponCode,
  });

  factory OrderSummaryModel.fromJson(Map<String, dynamic> json) {
    return OrderSummaryModel(
      subtotal: (json['subtotal'] as num).toDouble(),
      discount: (json['discount'] as num?)?.toDouble() ?? 0.0,
      tipAmount: (json['tipAmount'] as num?)?.toDouble() ?? 0.0,
      total: (json['total'] as num).toDouble(),
      tipPercentage: json['tipPercentage'] as int? ?? 0,
      appliedCouponCode: json['appliedCouponCode'] as String?,
    );
  }
}
