import 'package:rest_app/features/waiter/data/datasources/waiter_remote_data_source.dart';
import 'package:rest_app/features/waiter/domain/repositories/waiter_repository.dart';

class WaiterRepositoryImpl implements WaiterRepository {
  final WaiterRemoteDataSource remoteDataSource;

  WaiterRepositoryImpl({required this.remoteDataSource});

  @override
  Future<void> updateToken({required String waiterId, required String token}) =>
      remoteDataSource.updateToken(waiterId: waiterId, token: token);

  @override
  Future<double> getTotalTips() => remoteDataSource.getTotalTips();
}
