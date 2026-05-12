import 'package:rest_app/features/waiter/domain/repositories/waiter_repository.dart';

class GetWaiterTips {
  final WaiterRepository repository;

  GetWaiterTips(this.repository);

  Future<double> call() => repository.getTotalTips();
}
