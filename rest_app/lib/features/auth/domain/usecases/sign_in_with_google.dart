import 'package:rest_app/features/auth/domain/entities/user_entity.dart';
import 'package:rest_app/features/auth/domain/repositories/auth_repository.dart';

class SignInWithGoogle {
  final AuthRepository repository;

  SignInWithGoogle(this.repository);

  Future<UserEntity> call({required String pushToken}) {
    return repository.signInWithGoogle(pushToken: pushToken);
  }
}
