import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:rest_app/core/di/injection.dart';
import 'package:rest_app/core/push/push_notification_service.dart';
import 'package:rest_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:rest_app/features/auth/presentation/bloc/auth_event.dart';
import 'package:rest_app/features/auth/presentation/bloc/auth_state.dart';
import 'package:rest_app/features/waiter/presentation/bloc/waiter_bloc.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  late final AuthBloc _authBloc;
  late final WaiterBloc _waiterBloc;
  String? _pushToken;

  @override
  void initState() {
    super.initState();
    _authBloc = getIt<AuthBloc>();
    _waiterBloc = getIt<WaiterBloc>();
    _loadPushToken();
    _waiterBloc.stream.listen((state) {
      if (!mounted) return;
      if (state is WaiterTokenUpdated || state is WaiterTokenUpdateFailure) {
        context.push('/waiter');
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _loadPushToken() async {
    final service = getIt<PushNotificationService>();
    final token = service.token;
    setState(() {
      _pushToken = token;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<AuthState>(
        stream: _authBloc.stream,
        initialData: _authBloc.state,
        builder: (context, snapshot) {
          final state = snapshot.data;

          // Navegar automáticamente al perfil cuando esté autenticado
          if (state is AuthAuthenticated) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              context.go('/profile', extra: state.user);
            });
          }

          return switch (state) {
            AuthLoading() => _buildLoadingState(),
            AuthFailure() => _buildFailureState(state),
            _ => _buildUnauthenticatedState(),
          };
        },
      ),
    );
  }

  Widget _buildLoadingState() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.blue.shade400, Colors.blue.shade700],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              strokeWidth: 3,
            ),
            const SizedBox(height: 24),
            Text(
              'Iniciando sesión...',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUnauthenticatedState() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.blue.shade400, Colors.blue.shade700],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Logo Section
              Column(
                children: [
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white24,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.white.withOpacity(0.2),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.restaurant_menu,
                      size: 60,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 32),
                  Text(
                    'Bienvenido',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 32,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Tu restaurante favorito',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.white70,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 60),
              // Description Card
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white.withOpacity(0.2)),
                  //backdropFilter: null,
                ),
                padding: const EdgeInsets.all(20),
                child: Text(
                  'Inicia sesión con tu cuenta de Google para acceder a las mejores ofertas y pedidos',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.white,
                    height: 1.6,
                  ),
                ),
              ),
              const SizedBox(height: 40),
              // Login Button
              _buildLoginButton(),
              const SizedBox(height: 14),
              _buildWaiterButton(),
              const Spacer(),
              // Push Token Info
              if (_pushToken != null)
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white30),
                  ),
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Push Token',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: Colors.white70,
                          fontSize: 11,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _pushToken!,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.white,
                          fontSize: 10,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                )
              else
                Text(
                  'Inicializando notificaciones push...',
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: Colors.white70),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWaiterButton() {
    return StreamBuilder<WaiterState>(
      stream: _waiterBloc.stream,
      initialData: _waiterBloc.state,
      builder: (context, snapshot) {
        final isLoading = snapshot.data is WaiterTokenUpdating;
        return OutlinedButton.icon(
          onPressed: isLoading ? null : _onWaiterButtonTap,
          icon: isLoading
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white70),
                  ),
                )
              : const Icon(Icons.room_service_outlined),
          label: Text(isLoading ? 'Actualizando...' : 'Acceder como mesero'),
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.white,
            side: const BorderSide(color: Colors.white70),
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        );
      },
    );
  }

  void _onWaiterButtonTap() {
    const waiterId = 'f7a2635b-c3b5-475f-a880-2b53bd9211d8';
    final token = _pushToken ?? getIt<PushNotificationService>().token;
    if (token != null) {
      _waiterBloc.add(UpdateWaiterTokenEvent(waiterId: waiterId, token: token));
    } else {
      context.push('/waiter');
    }
  }

  Widget _buildLoginButton() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [Colors.white, Colors.grey.shade100]),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            if (_pushToken != null) {
              _authBloc.add(AuthSignInWithGoogleEvent(pushToken: _pushToken!));
            }
          },
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 18.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/google_logo.png',
                  height: 24,
                  width: 24,
                  errorBuilder: (context, error, stackTrace) {
                    return Icon(
                      Icons.account_circle,
                      size: 24,
                      color: Colors.blue.shade600,
                    );
                  },
                ),
                const SizedBox(width: 16),
                Text(
                  'Iniciar sesión con Google',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: Colors.blue.shade600,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFailureState(AuthFailure state) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.blue.shade400, Colors.blue.shade700],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Error Icon
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.red.shade400.withOpacity(0.2),
                ),
                child: Icon(
                  Icons.error_outline,
                  size: 50,
                  color: Colors.red.shade300,
                ),
              ),
              const SizedBox(height: 32),
              // Error Title
              Text(
                'Error de autenticación',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              // Error Message
              Container(
                decoration: BoxDecoration(
                  color: Colors.red.shade400.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.red.shade300.withOpacity(0.5),
                  ),
                ),
                padding: const EdgeInsets.all(16),
                child: Text(
                  state.message,
                  textAlign: TextAlign.center,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: Colors.white),
                ),
              ),
              const SizedBox(height: 32),
              // Retry Button
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.white, Colors.grey.shade100],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      if (_pushToken != null) {
                        _authBloc.add(
                          AuthSignInWithGoogleEvent(pushToken: _pushToken!),
                        );
                      }
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.refresh, color: Colors.blue),
                          const SizedBox(width: 12),
                          Text(
                            'Intentar de nuevo',
                            style: Theme.of(context).textTheme.labelLarge
                                ?.copyWith(
                                  color: Colors.blue.shade600,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
