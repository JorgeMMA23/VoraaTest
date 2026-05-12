import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:rest_app/core/di/injection.dart';
import 'package:rest_app/core/push/push_notification_service.dart';
import 'package:rest_app/core/routing/app_router.dart';
import 'package:rest_app/firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await injection.init();
  await getIt<PushNotificationService>().init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Restaurant App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      routerConfig: AppRouter.router,
    );
  }
}
