part of 'orders_bloc.dart';

abstract class OrdersEvent {}

class LoadUserOrdersEvent extends OrdersEvent {}

class RequestHelpEvent extends OrdersEvent {
  final String orderId;

  RequestHelpEvent(this.orderId);
}
