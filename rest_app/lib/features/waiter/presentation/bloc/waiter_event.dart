part of 'waiter_bloc.dart';

abstract class WaiterEvent extends Equatable {
  const WaiterEvent();

  @override
  List<Object?> get props => [];
}

class UpdateWaiterTokenEvent extends WaiterEvent {
  final String waiterId;
  final String token;

  const UpdateWaiterTokenEvent({required this.waiterId, required this.token});

  @override
  List<Object?> get props => [waiterId, token];
}

class LoadWaiterTipsEvent extends WaiterEvent {
  const LoadWaiterTipsEvent();
}
