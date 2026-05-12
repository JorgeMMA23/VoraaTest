import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get_it/get_it.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:rest_app/core/network/dio_client.dart';
import 'package:rest_app/core/push/push_notification_service.dart';
import 'package:rest_app/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:rest_app/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:rest_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:rest_app/features/auth/domain/usecases/sign_in_with_google.dart';
import 'package:rest_app/features/auth/domain/usecases/sign_out.dart';
import 'package:rest_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:rest_app/features/checkout/data/datasources/checkout_remote_data_source.dart';
import 'package:rest_app/features/checkout/data/repositories/checkout_repository_impl.dart';
import 'package:rest_app/features/checkout/domain/repositories/checkout_repository.dart';
import 'package:rest_app/features/checkout/domain/usecases/apply_coupon.dart';
import 'package:rest_app/features/checkout/domain/usecases/confirm_payment.dart';
import 'package:rest_app/features/checkout/domain/usecases/get_available_coupons.dart';
import 'package:rest_app/features/checkout/domain/usecases/get_payment_details.dart';
import 'package:rest_app/features/checkout/domain/usecases/request_bill.dart';
import 'package:rest_app/features/checkout/presentation/bloc/checkout_bloc.dart';
import 'package:rest_app/features/waiter/data/datasources/waiter_remote_data_source.dart';
import 'package:rest_app/features/waiter/data/repositories/waiter_repository_impl.dart';
import 'package:rest_app/features/waiter/domain/repositories/waiter_repository.dart';
import 'package:rest_app/features/waiter/domain/usecases/get_waiter_tips.dart';
import 'package:rest_app/features/waiter/domain/usecases/update_waiter_token.dart';
import 'package:rest_app/features/waiter/presentation/bloc/waiter_bloc.dart';
import 'package:rest_app/features/menu/data/datasources/menu_remote_data_source.dart';
import 'package:rest_app/features/menu/data/repositories/menu_repository_impl.dart';
import 'package:rest_app/features/menu/domain/repositories/menu_repository.dart';
import 'package:rest_app/features/menu/domain/usecases/get_menu_items.dart';
import 'package:rest_app/features/menu/presentation/bloc/menu_bloc.dart';
import 'package:rest_app/features/orders/data/datasources/orders_remote_data_source.dart';
import 'package:rest_app/features/orders/data/repositories/orders_repository_impl.dart';
import 'package:rest_app/features/orders/domain/repositories/orders_repository.dart';
import 'package:rest_app/features/orders/domain/usecases/create_order.dart';
import 'package:rest_app/features/orders/domain/usecases/get_user_orders.dart';
import 'package:rest_app/features/orders/domain/usecases/request_help.dart';
import 'package:rest_app/features/orders/presentation/bloc/orders_bloc.dart';

final GetIt getIt = GetIt.instance;

class Injection {
  static const String baseUrl = 'http://192.168.1.4:3000';

  Future<void> init() async {
    if (getIt.isRegistered<Dio>()) return;

    getIt.registerLazySingleton<DioClient>(() => DioClient(baseUrl: baseUrl));
    getIt.registerLazySingleton<Dio>(() => getIt<DioClient>().dio);

    getIt.registerLazySingleton<FirebaseAuth>(() => FirebaseAuth.instance);
    getIt.registerLazySingleton<GoogleSignIn>(() => GoogleSignIn());
    getIt.registerLazySingleton<FirebaseMessaging>(
      () => FirebaseMessaging.instance,
    );
    getIt.registerLazySingleton<PushNotificationService>(
      () => PushNotificationService(getIt<FirebaseMessaging>()),
    );

    getIt.registerLazySingleton<AuthRemoteDataSource>(
      () => AuthRemoteDataSourceImpl(
        firebaseAuth: getIt<FirebaseAuth>(),
        googleSignIn: getIt<GoogleSignIn>(),
        dio: getIt<Dio>(),
      ),
    );

    getIt.registerLazySingleton<AuthRepository>(
      () => AuthRepositoryImpl(remoteDataSource: getIt<AuthRemoteDataSource>()),
    );

    getIt.registerLazySingleton<SignInWithGoogle>(
      () => SignInWithGoogle(getIt<AuthRepository>()),
    );

    getIt.registerLazySingleton<SignOut>(
      () => SignOut(getIt<AuthRepository>()),
    );

    getIt.registerLazySingleton<OrdersRemoteDataSource>(
      () => OrdersRemoteDataSourceImpl(dio: getIt<Dio>()),
    );

    getIt.registerLazySingleton<OrdersRepository>(
      () => OrdersRepositoryImpl(
        remoteDataSource: getIt<OrdersRemoteDataSource>(),
      ),
    );

    getIt.registerLazySingleton<GetUserOrders>(
      () => GetUserOrders(getIt<OrdersRepository>()),
    );

    getIt.registerLazySingleton<CreateOrder>(
      () => CreateOrder(getIt<OrdersRepository>()),
    );

    getIt.registerLazySingleton<RequestHelp>(
      () => RequestHelp(getIt<OrdersRepository>()),
    );

    getIt.registerFactory<OrdersBloc>(
      () => OrdersBloc(
        getUserOrders: getIt<GetUserOrders>(),
        requestHelp: getIt<RequestHelp>(),
      ),
    );

    getIt.registerLazySingleton<MenuRemoteDataSource>(
      () => MenuRemoteDataSourceImpl(dio: getIt<Dio>()),
    );

    getIt.registerLazySingleton<MenuRepository>(
      () => MenuRepositoryImpl(remoteDataSource: getIt<MenuRemoteDataSource>()),
    );

    getIt.registerLazySingleton<GetMenuItems>(
      () => GetMenuItems(getIt<MenuRepository>()),
    );

    getIt.registerFactory<MenuBloc>(
      () => MenuBloc(getMenuItems: getIt<GetMenuItems>()),
    );

    // Auth Bloc
    getIt.registerLazySingleton<AuthBloc>(
      () => AuthBloc(
        signInWithGoogle: getIt<SignInWithGoogle>(),
        signOut: getIt<SignOut>(),
      ),
    );

    // Checkout feature
    getIt.registerLazySingleton<CheckoutRemoteDataSource>(
      () => CheckoutRemoteDataSourceImpl(dio: getIt<Dio>()),
    );

    getIt.registerLazySingleton<CheckoutRepository>(
      () => CheckoutRepositoryImpl(
        remoteDataSource: getIt<CheckoutRemoteDataSource>(),
      ),
    );

    getIt.registerLazySingleton<GetPaymentDetails>(
      () => GetPaymentDetails(getIt<CheckoutRepository>()),
    );

    getIt.registerLazySingleton<GetAvailableCoupons>(
      () => GetAvailableCoupons(getIt<CheckoutRepository>()),
    );

    getIt.registerLazySingleton<ApplyCoupon>(
      () => ApplyCoupon(getIt<CheckoutRepository>()),
    );

    getIt.registerLazySingleton<RequestBill>(
      () => RequestBill(getIt<CheckoutRepository>()),
    );

    getIt.registerLazySingleton<ConfirmPayment>(
      () => ConfirmPayment(getIt<CheckoutRepository>()),
    );

    getIt.registerFactory<CheckoutBloc>(
      () => CheckoutBloc(
        getPaymentDetails: getIt<GetPaymentDetails>(),
        getAvailableCoupons: getIt<GetAvailableCoupons>(),
        requestBill: getIt<RequestBill>(),
        confirmPayment: getIt<ConfirmPayment>(),
      ),
    );

    // Waiter feature
    getIt.registerLazySingleton<WaiterRemoteDataSource>(
      () => WaiterRemoteDataSourceImpl(dio: getIt<Dio>()),
    );

    getIt.registerLazySingleton<WaiterRepository>(
      () => WaiterRepositoryImpl(remoteDataSource: getIt<WaiterRemoteDataSource>()),
    );

    getIt.registerLazySingleton<UpdateWaiterToken>(
      () => UpdateWaiterToken(getIt<WaiterRepository>()),
    );

    getIt.registerLazySingleton<GetWaiterTips>(
      () => GetWaiterTips(getIt<WaiterRepository>()),
    );

    getIt.registerFactory<WaiterBloc>(
      () => WaiterBloc(
        updateWaiterToken: getIt<UpdateWaiterToken>(),
        getWaiterTips: getIt<GetWaiterTips>(),
      ),
    );
  }
}

final injection = Injection();
