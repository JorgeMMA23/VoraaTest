abstract class AuthEvent {}

class AuthSignInWithGoogleEvent extends AuthEvent {
  final String pushToken;

  AuthSignInWithGoogleEvent({required this.pushToken});
}

class AuthSignOutEvent extends AuthEvent {}
