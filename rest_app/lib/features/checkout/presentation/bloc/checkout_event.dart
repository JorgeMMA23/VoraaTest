part of 'checkout_bloc.dart';

abstract class CheckoutEvent extends Equatable {
  const CheckoutEvent();

  @override
  List<Object?> get props => [];
}

/// Carga inicial: obtiene detalles de pago y cupones disponibles en paralelo
class LoadCheckoutEvent extends CheckoutEvent {
  final List<CartItemEntity> cartItems;

  const LoadCheckoutEvent(this.cartItems);

  @override
  List<Object?> get props => [cartItems];
}

/// Aplica un cupón al pedido y recalcula los montos vía backend
class SelectCouponEvent extends CheckoutEvent {
  final PromotionEntity coupon;

  const SelectCouponEvent(this.coupon);

  @override
  List<Object?> get props => [coupon];
}

/// Elimina el cupón seleccionado y restaura los montos originales
class RemoveCouponEvent extends CheckoutEvent {
  const RemoveCouponEvent();
}

/// Selecciona el porcentaje de propina (0, 10, 15 o 20)
class SelectTipEvent extends CheckoutEvent {
  final int tipPercentage;

  const SelectTipEvent(this.tipPercentage);

  @override
  List<Object?> get props => [tipPercentage];
}

/// Solicita la cuenta (transición de estado de detalle a pago)
class RequestBillEvent extends CheckoutEvent {
  const RequestBillEvent();
}

/// Confirma el pago del pedido
class ConfirmPaymentEvent extends CheckoutEvent {
  const ConfirmPaymentEvent();
}
