import 'package:equatable/equatable.dart';
import 'package:rest_app/features/checkout/domain/entities/promotion_entity.dart';
import 'package:rest_app/features/orders/domain/entities/order_entity.dart';

class PaymentDetailsEntity extends Equatable {
  final String id;
  final double subtotal;
  final double discount;
  final double taxes;
  final double tip;
  final double total;
  final String status; // OrderStatus: pending, confirmed, preparing, ready, delivered, completed, cancelled
  final String paymentStatus; // 'pending' | 'paid' | 'refunded'
  final List<OrderItemEntity> items;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String currency;
  final PaymentCalculationsEntity? calculations;
  final AppliedPromotionEntity? appliedPromotion;

  const PaymentDetailsEntity({
    required this.id,
    required this.subtotal,
    this.discount = 0.0,
    this.taxes = 0.0,
    required this.tip,
    required this.total,
    required this.status,
    required this.paymentStatus,
    required this.items,
    required this.createdAt,
    required this.updatedAt,
    this.currency = 'MXN',
    this.calculations,
    this.appliedPromotion,
  });

  @override
  List<Object?> get props => [
        id,
        subtotal,
        discount,
        taxes,
        tip,
        total,
        status,
        paymentStatus,
        items,
        createdAt,
        updatedAt,
        currency,
        calculations,
        appliedPromotion,
      ];
}

class PaymentCalculationsEntity extends Equatable {
  final double subtotal;
  final double discount;
  final String selectedTip;
  final double total;
  final double totalWithoutTip;
  final Map<String, TipOptionEntity> tipOptions;

  const PaymentCalculationsEntity({
    required this.subtotal,
    required this.discount,
    required this.selectedTip,
    required this.total,
    required this.totalWithoutTip,
    required this.tipOptions,
  });

  @override
  List<Object?> get props => [
        subtotal,
        discount,
        selectedTip,
        total,
        totalWithoutTip,
        tipOptions,
      ];
}

class TipOptionEntity extends Equatable {
  final int percentage;
  final double tip;
  final double total;

  const TipOptionEntity({
    required this.percentage,
    required this.tip,
    required this.total,
  });

  @override
  List<Object?> get props => [percentage, tip, total];
}

class AppliedPromotionEntity extends Equatable {
  final PromotionEntity? promotion;
  final bool? applied;

  const AppliedPromotionEntity({this.promotion, this.applied});

  @override
  List<Object?> get props => [promotion, applied];
}
