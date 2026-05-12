part of 'waiter_bloc.dart';

abstract class WaiterState extends Equatable {
  const WaiterState();

  @override
  List<Object?> get props => [];
}

class WaiterInitial extends WaiterState {}

class WaiterTokenUpdating extends WaiterState {}

class WaiterTokenUpdated extends WaiterState {}

class WaiterTokenUpdateFailure extends WaiterState {}

class WaiterTipsLoaded extends WaiterState {
  final double totalTips;

  const WaiterTipsLoaded(this.totalTips);

  @override
  List<Object?> get props => [totalTips];
}

class WaiterTipsLoadFailure extends WaiterState {}
