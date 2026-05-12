import 'package:equatable/equatable.dart';

class OrderSummaryEntity extends Equatable {
  final double subtotal;
  final double discount;

  final double tipAmount;
  final double total;
  final int tipPercentage; // 0, 10, 15, 20
  final String? appliedCouponCode;

  const OrderSummaryEntity({
    required this.subtotal,
    required this.discount,

    required this.tipAmount,
    required this.total,
    required this.tipPercentage,
    this.appliedCouponCode,
  });

  @override
  List<Object?> get props => [
    subtotal,
    discount,

    tipAmount,
    total,
    tipPercentage,
    appliedCouponCode,
  ];
}
