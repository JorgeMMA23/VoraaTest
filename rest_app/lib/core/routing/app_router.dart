import 'package:go_router/go_router.dart';
import 'package:rest_app/core/di/injection.dart';
import 'package:rest_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:rest_app/features/auth/presentation/pages/login_page.dart';
import 'package:rest_app/features/auth/presentation/pages/user_profile_page.dart';
import 'package:rest_app/features/checkout/presentation/pages/checkout_page.dart';
import 'package:rest_app/features/incidents/presentation/pages/incident_generation_page.dart';
import 'package:rest_app/features/menu/domain/entities/cart_item_entity.dart';
import 'package:rest_app/features/menu/presentation/pages/menu_page.dart';
import 'package:rest_app/features/menu/presentation/pages/menu_scanner_page.dart';
import 'package:rest_app/features/orders/domain/entities/order_entity.dart';
import 'package:rest_app/features/orders/presentation/pages/order_detail_page.dart';
import 'package:rest_app/features/orders/presentation/pages/orders_page.dart';
import 'package:rest_app/features/waiter/presentation/pages/waiter_dashboard_page.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(path: '/', builder: (context, state) => const LoginPage()),
      GoRoute(
        path: '/waiter',
        builder: (context, state) => const WaiterDashboardPage(),
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) {
          final user = getIt<AuthBloc>().state.user;
          if (user == null) {
            // Si no hay usuario, redirigir al login
            return const LoginPage();
          }
          return UserProfilePage(user: user);
        },
      ),
      GoRoute(
        path: '/menu',
        builder: (context, state) => const MenuScannerPage(),
      ),
      GoRoute(
        path: '/menu/list',
        builder: (context, state) {
          final menuToken = state.extra as String?;
          return MenuPage(menuToken: menuToken);
        },
      ),
      GoRoute(
        path: '/checkout',
        builder: (context, state) {
          final cartItems = state.extra as List<CartItemEntity>?;
          if (cartItems == null || cartItems.isEmpty) {
            return const LoginPage();
          }
          return CheckoutPage(cartItems: cartItems);
        },
      ),
      GoRoute(path: '/orders', builder: (context, state) => const OrdersPage()),
      GoRoute(
        path: '/incidents/create',
        builder: (context, state) {
          final orderId = state.extra as String?;
          if (orderId == null || orderId.isEmpty) {
            return const OrdersPage();
          }
          return IncidentGenerationPage(orderId: orderId);
        },
      ),
      GoRoute(
        path: '/order-detail',
        builder: (context, state) {
          final order = state.extra as OrderEntity?;
          if (order == null) {
            return const LoginPage();
          }
          return OrderDetailPage(order: order);
        },
      ),
    ],
  );
}
