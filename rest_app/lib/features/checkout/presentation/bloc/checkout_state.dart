part of 'checkout_bloc.dart';

abstract class CheckoutState extends Equatable {
  const CheckoutState();

  @override
  List<Object?> get props => [];
}

class CheckoutInitial extends CheckoutState {}

class CheckoutLoading extends CheckoutState {}

class CheckoutLoaded extends CheckoutState {
  final List<CartItemEntity> cartItems;
  final PaymentDetailsEntity paymentDetails;
  final List<PromotionEntity> coupons;
  final PromotionEntity? selectedCoupon;
  final int tipPercentage;
  final PaymentCalculationsEntity? orderSummary;
  final bool isApplyingCoupon;
  final bool isConfirmingPayment;
  final String? couponError;

  const CheckoutLoaded({
    required this.cartItems,
    required this.paymentDetails,
    required this.coupons,
    this.selectedCoupon,
    required this.tipPercentage,
    this.orderSummary,
    this.isApplyingCoupon = false,
    this.isConfirmingPayment = false,
    this.couponError,
  });

  CheckoutLoaded copyWith({
    List<CartItemEntity>? cartItems,
    PaymentDetailsEntity? paymentDetails,
    List<PromotionEntity>? coupons,
    PromotionEntity? selectedCoupon,
    bool clearCoupon = false,
    int? tipPercentage,
    PaymentCalculationsEntity? orderSummary,
    bool? isApplyingCoupon,
    bool? isConfirmingPayment,
    String? couponError,
    bool clearCouponError = true,
  }) {
    return CheckoutLoaded(
      cartItems: cartItems ?? this.cartItems,
      paymentDetails: paymentDetails ?? this.paymentDetails,
      coupons: coupons ?? this.coupons,
      selectedCoupon: clearCoupon
          ? null
          : (selectedCoupon ?? this.selectedCoupon),
      tipPercentage: tipPercentage ?? this.tipPercentage,
      orderSummary: orderSummary ?? this.orderSummary,
      isApplyingCoupon: isApplyingCoupon ?? this.isApplyingCoupon,
      isConfirmingPayment: isConfirmingPayment ?? this.isConfirmingPayment,
      couponError: clearCouponError ? null : (couponError ?? this.couponError),
    );
  }

  @override
  List<Object?> get props => [
    cartItems,
    paymentDetails,
    coupons,
    selectedCoupon,
    tipPercentage,
    orderSummary,
    isApplyingCoupon,
    isConfirmingPayment,
    couponError,
  ];
}

class CheckoutError extends CheckoutState {
  final String message;

  const CheckoutError(this.message);

  @override
  List<Object?> get props => [message];
}

class CheckoutOrderDetail extends CheckoutState {
  final List<CartItemEntity> cartItems;
  final PaymentDetailsEntity paymentDetails;
  final OrderSummaryEntity orderSummary;
  final bool isRequestingBill;

  const CheckoutOrderDetail({
    required this.cartItems,
    required this.paymentDetails,
    required this.orderSummary,
    this.isRequestingBill = false,
  });

  @override
  List<Object?> get props => [
    cartItems,
    paymentDetails,
    orderSummary,
    isRequestingBill,
  ];
}

class CheckoutPaymentConfirmed extends CheckoutState {
  final List<CartItemEntity> cartItems;
  final PaymentDetailsEntity paymentDetails;
  final PaymentCalculationsEntity? orderSummary;

  const CheckoutPaymentConfirmed({
    required this.cartItems,
    required this.paymentDetails,
    required this.orderSummary,
  });

  @override
  List<Object?> get props => [cartItems, paymentDetails, orderSummary];
}
