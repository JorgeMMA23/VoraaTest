part of 'orders_bloc.dart';

abstract class OrdersState extends Equatable {
  @override
  List<Object?> get props => [];
}

class OrdersInitial extends OrdersState {}

class OrdersLoading extends OrdersState {}

class OrdersLoaded extends OrdersState {
  final List<PaymentDetailsModel> orders;

  OrdersLoaded(this.orders);

  @override
  List<Object?> get props => [orders];
}

class OrdersEmpty extends OrdersState {}

class OrdersError extends OrdersState {
  final String message;

  OrdersError(this.message);

  @override
  List<Object?> get props => [message];
}

class OrdersHelpRequesting extends OrdersState {}

class OrdersHelpRequested extends OrdersState {}

class OrdersHelpRequestFailure extends OrdersState {
  final String message;

  OrdersHelpRequestFailure(this.message);

  @override
  List<Object?> get props => [message];
}
