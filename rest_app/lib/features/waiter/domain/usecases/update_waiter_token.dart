import 'package:rest_app/features/waiter/domain/repositories/waiter_repository.dart';

class UpdateWaiterToken {
  final WaiterRepository repository;

  UpdateWaiterToken(this.repository);

  Future<void> call({required String waiterId, required String token}) =>
      repository.updateToken(waiterId: waiterId, token: token);
}
