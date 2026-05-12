import 'package:bloc/bloc.dart';
import 'package:rest_app/features/auth/domain/usecases/sign_in_with_google.dart';
import 'package:rest_app/features/auth/domain/usecases/sign_out.dart';
import 'package:rest_app/features/auth/presentation/bloc/auth_event.dart';
import 'package:rest_app/features/auth/presentation/bloc/auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final SignInWithGoogle signInWithGoogle;
  final SignOut signOut;

  AuthBloc({required this.signInWithGoogle, required this.signOut})
    : super(AuthInitial()) {
    on<AuthSignInWithGoogleEvent>(_onSignInWithGoogle);
    on<AuthSignOutEvent>(_onSignOut);
  }

  Future<void> _onSignInWithGoogle(
    AuthSignInWithGoogleEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    try {
      final user = await signInWithGoogle(pushToken: event.pushToken);
      emit(AuthAuthenticated(user: user));
    } catch (error) {
      emit(AuthFailure(error.toString()));
    }
  }

  Future<void> _onSignOut(
    AuthSignOutEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    try {
      await signOut();
      emit(AuthUnauthenticated());
    } catch (error) {
      emit(AuthFailure(error.toString()));
    }
  }
}
