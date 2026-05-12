import 'package:rest_app/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:rest_app/features/auth/domain/entities/user_entity.dart';
import 'package:rest_app/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl({required this.remoteDataSource});

  @override
  Future<UserEntity> signInWithGoogle({required String pushToken}) {
    return remoteDataSource.signInWithGoogle(pushToken: pushToken);
  }

  @override
  Future<void> signOut() {
    return remoteDataSource.signOut();
  }
}
