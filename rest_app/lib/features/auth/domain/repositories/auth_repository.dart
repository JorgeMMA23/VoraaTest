import 'package:rest_app/features/auth/domain/entities/user_entity.dart';

abstract class AuthRepository {
  Future<UserEntity> signInWithGoogle({required String pushToken});
  Future<void> signOut();
}
