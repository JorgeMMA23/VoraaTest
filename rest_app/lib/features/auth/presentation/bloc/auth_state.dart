import 'package:rest_app/features/auth/domain/entities/user_entity.dart';

abstract class AuthState {
  final UserEntity? user;

  const AuthState({this.user});
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthAuthenticated extends AuthState {
  AuthAuthenticated({super.user});
}

class AuthUnauthenticated extends AuthState {}

class AuthFailure extends AuthState {
  final String message;

  AuthFailure(this.message);
}
