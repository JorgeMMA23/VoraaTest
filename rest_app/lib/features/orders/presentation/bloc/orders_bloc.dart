import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:rest_app/features/checkout/data/models/payment_details_model.dart';
import 'package:rest_app/features/orders/domain/usecases/get_user_orders.dart';
import 'package:rest_app/features/orders/domain/usecases/request_help.dart';

part 'orders_event.dart';
part 'orders_state.dart';

class OrdersBloc extends Bloc<OrdersEvent, OrdersState> {
  final GetUserOrders getUserOrders;
  final RequestHelp requestHelp;

  OrdersBloc({required this.getUserOrders, required this.requestHelp})
      : super(OrdersInitial()) {
    on<LoadUserOrdersEvent>(_onLoadUserOrders);
    on<RequestHelpEvent>(_onRequestHelp);
  }

  Future<void> _onLoadUserOrders(
    LoadUserOrdersEvent event,
    Emitter<OrdersState> emit,
  ) async {
    emit(OrdersLoading());

    try {
      final orders = await getUserOrders();
      if (orders.isEmpty) {
        emit(OrdersEmpty());
      } else {
        emit(OrdersLoaded(orders));
      }
    } catch (error) {
      emit(OrdersError(error.toString()));
    }
  }

  Future<void> _onRequestHelp(
    RequestHelpEvent event,
    Emitter<OrdersState> emit,
  ) async {
    if (state is OrdersHelpRequesting) return;

    emit(OrdersHelpRequesting());

    try {
      await requestHelp(event.orderId);
      emit(OrdersHelpRequested());
    } catch (e) {
      emit(OrdersHelpRequestFailure(e.toString()));
    }
  }
}
