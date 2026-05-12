import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:rest_app/features/waiter/domain/usecases/get_waiter_tips.dart';
import 'package:rest_app/features/waiter/domain/usecases/update_waiter_token.dart';

part 'waiter_event.dart';
part 'waiter_state.dart';

class WaiterBloc extends Bloc<WaiterEvent, WaiterState> {
  final UpdateWaiterToken updateWaiterToken;
  final GetWaiterTips getWaiterTips;

  WaiterBloc({required this.updateWaiterToken, required this.getWaiterTips})
      : super(WaiterInitial()) {
    on<UpdateWaiterTokenEvent>(_onUpdateToken);
    on<LoadWaiterTipsEvent>(_onLoadTips);
  }

  Future<void> _onUpdateToken(
    UpdateWaiterTokenEvent event,
    Emitter<WaiterState> emit,
  ) async {
    if (state is WaiterTokenUpdating) return;

    emit(WaiterTokenUpdating());

    try {
      await updateWaiterToken(waiterId: event.waiterId, token: event.token);
      emit(WaiterTokenUpdated());
    } catch (_) {
      emit(WaiterTokenUpdateFailure());
    }
  }

  Future<void> _onLoadTips(
    LoadWaiterTipsEvent event,
    Emitter<WaiterState> emit,
  ) async {
    try {
      final totalTips = await getWaiterTips();
      emit(WaiterTipsLoaded(totalTips));
    } catch (_) {
      emit(WaiterTipsLoadFailure());
    }
  }
}
