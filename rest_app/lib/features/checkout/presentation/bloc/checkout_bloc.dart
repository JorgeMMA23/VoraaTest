import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:rest_app/features/checkout/domain/entities/order_summary_entity.dart';
import 'package:rest_app/features/checkout/domain/entities/payment_details_entity.dart';
import 'package:rest_app/features/checkout/domain/entities/promotion_entity.dart';
import 'package:rest_app/features/checkout/domain/usecases/confirm_payment.dart';
import 'package:rest_app/features/checkout/domain/usecases/get_available_coupons.dart';
import 'package:rest_app/features/checkout/domain/usecases/get_payment_details.dart';
import 'package:rest_app/features/checkout/domain/usecases/request_bill.dart';
import 'package:rest_app/features/menu/domain/entities/cart_item_entity.dart';

part 'checkout_event.dart';
part 'checkout_state.dart';

class CheckoutBloc extends Bloc<CheckoutEvent, CheckoutState> {
  final GetPaymentDetails getPaymentDetails;
  final GetAvailableCoupons getAvailableCoupons;
  final RequestBill requestBill;
  final ConfirmPayment confirmPayment;

  CheckoutBloc({
    required this.getPaymentDetails,
    required this.getAvailableCoupons,
    required this.requestBill,
    required this.confirmPayment,
  }) : super(CheckoutInitial()) {
    on<LoadCheckoutEvent>(_onLoadCheckout);
    on<RequestBillEvent>(_onRequestBill);
    on<SelectCouponEvent>(_onSelectCoupon);
    on<RemoveCouponEvent>(_onRemoveCoupon);
    on<SelectTipEvent>(_onSelectTip);
    on<ConfirmPaymentEvent>(_onConfirmPayment);
  }

  Future<void> _onLoadCheckout(
    LoadCheckoutEvent event,
    Emitter<CheckoutState> emit,
  ) async {
    emit(CheckoutLoading());
    try {
      final paymentDetails = await getPaymentDetails(event.cartItems);

      emit(
        CheckoutOrderDetail(
          cartItems: event.cartItems,
          paymentDetails: paymentDetails,
          orderSummary: _buildInitialSummary(paymentDetails),
        ),
      );
    } catch (e) {
      print('Error al cargar checkout: $e');
      emit(CheckoutError(e.toString()));
    }
  }

  Future<void> _onRequestBill(
    RequestBillEvent event,
    Emitter<CheckoutState> emit,
  ) async {
    final state = this.state;
    if (state is! CheckoutOrderDetail) return;
    if (state.isRequestingBill) return;

    emit(
      CheckoutOrderDetail(
        cartItems: state.cartItems,
        paymentDetails: state.paymentDetails,
        orderSummary: state.orderSummary,
        isRequestingBill: true,
      ),
    );

    try {
      final coupons = await getAvailableCoupons();
      final PaymentDetailsEntity paymentDetails = await requestBill(
        idOrder: state.paymentDetails.id,
        tipPercentage: 0,
      );

      emit(
        CheckoutLoaded(
          cartItems: state.cartItems,
          paymentDetails: paymentDetails,
          coupons: coupons,
          tipPercentage: 0,
          orderSummary: paymentDetails.calculations,
        ),
      );
    } catch (e) {
      print('Error al solicitar la cuenta: $e');
      emit(CheckoutError(e.toString()));
    }
  }

  Future<void> _onSelectCoupon(
    SelectCouponEvent event,
    Emitter<CheckoutState> emit,
  ) async {
    final state = this.state;
    if (state is! CheckoutLoaded) return;
    if (state.isApplyingCoupon) return;

    emit(state.copyWith(isApplyingCoupon: true, clearCouponError: true));

    try {
      final paymentDetails = await requestBill(
        idOrder: state.paymentDetails.id,
        couponId: event.coupon.id,
        tipPercentage: state.tipPercentage,
      );

      emit(
        state.copyWith(
          paymentDetails: paymentDetails,
          selectedCoupon: event.coupon,
          orderSummary: paymentDetails.calculations,
          isApplyingCoupon: false,
        ),
      );
    } catch (e) {
      print('Error al aplicar el cupon: $e');
      emit(
        state.copyWith(
          isApplyingCoupon: false,
          couponError: 'No se pudo aplicar el cupón. Intenta nuevamente.',
        ),
      );
    }
  }

  Future<void> _onRemoveCoupon(
    RemoveCouponEvent event,
    Emitter<CheckoutState> emit,
  ) async {
    final state = this.state;
    if (state is! CheckoutLoaded) return;
    if (state.isApplyingCoupon) return;

    await _refreshBill(
      emit,
      state,
      clearCoupon: true,
      tipPercentage: state.tipPercentage,
    );
  }

  Future<void> _onSelectTip(
    SelectTipEvent event,
    Emitter<CheckoutState> emit,
  ) async {
    final state = this.state;
    if (state is! CheckoutLoaded) return;
    if (state.isApplyingCoupon) return;

    await _refreshBill(
      emit,
      state,
      coupon: state.selectedCoupon,
      tipPercentage: event.tipPercentage,
    );
  }

  Future<void> _onConfirmPayment(
    ConfirmPaymentEvent event,
    Emitter<CheckoutState> emit,
  ) async {
    final state = this.state;
    if (state is! CheckoutLoaded) return;
    if (state.isConfirmingPayment || state.isApplyingCoupon) return;

    emit(state.copyWith(isConfirmingPayment: true));

    try {
      await confirmPayment(state.paymentDetails.id, state.orderSummary);
      emit(
        CheckoutPaymentConfirmed(
          cartItems: state.cartItems,
          paymentDetails: state.paymentDetails,
          orderSummary: state.orderSummary,
        ),
      );
    } catch (e) {
      print("Error al confirmar el pago: $e");
      emit(
        state.copyWith(
          isConfirmingPayment: false,
          couponError: 'No se pudo confirmar el pago. Intenta nuevamente.',
          clearCouponError: false,
        ),
      );
    }
  }

  // Construye el resumen inicial sin cupón aplicado
  OrderSummaryEntity _buildInitialSummary(
    PaymentDetailsEntity details, {
    int tipPercentage = 0,
  }) {
    // Base = total sin propina (subtotal + impuestos)
    final tipAmount = details.subtotal * tipPercentage / 100;

    return OrderSummaryEntity(
      subtotal: details.subtotal,
      discount: details.discount,
      tipAmount: tipAmount,
      total: details.subtotal + tipAmount - details.discount,
      tipPercentage: tipPercentage,
    );
  }

  Future<void> _refreshBill(
    Emitter<CheckoutState> emit,
    CheckoutLoaded state, {
    PromotionEntity? coupon,
    bool clearCoupon = false,
    required int tipPercentage,
  }) async {
    emit(state.copyWith(isApplyingCoupon: true, clearCouponError: true));

    try {
      final paymentDetails = await requestBill(
        idOrder: state.paymentDetails.id,
        couponId: clearCoupon ? null : coupon?.id,
        tipPercentage: tipPercentage,
      );

      emit(
        state.copyWith(
          paymentDetails: paymentDetails,
          selectedCoupon: coupon,
          clearCoupon: clearCoupon,
          tipPercentage: tipPercentage,
          orderSummary: paymentDetails.calculations,
          isApplyingCoupon: false,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          isApplyingCoupon: false,
          couponError:
              'No se pudo actualizar la cuenta. Intenta nuevamente. $e',
        ),
      );
    }
  }
}
