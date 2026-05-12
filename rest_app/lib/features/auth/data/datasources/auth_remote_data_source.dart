import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:rest_app/features/auth/data/models/app_user_model.dart';

abstract class AuthRemoteDataSource {
  Future<AppUserModel> signInWithGoogle({required String pushToken});
  Future<void> signOut();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final FirebaseAuth firebaseAuth;
  final GoogleSignIn googleSignIn;
  final Dio dio;

  AuthRemoteDataSourceImpl({
    required this.firebaseAuth,
    required this.googleSignIn,
    required this.dio,
  });

  @override
  Future<AppUserModel> signInWithGoogle({required String pushToken}) async {
    final googleUser = await googleSignIn.signIn();
    if (googleUser == null) {
      throw Exception('Inicio de sesión cancelado por el usuario.');
    }

    final googleAuth = await googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final UserCredential userCredential = await firebaseAuth
        .signInWithCredential(credential);
    final User? firebaseUser = userCredential.user;

    print("Email: ${userCredential.user?.email}");
    print("Name: ${userCredential.user?.displayName}");

    if (firebaseUser == null) {
      throw Exception('No se pudo obtener el usuario desde Firebase.');
    }

    // Convertir el usuario de Firebase a modelo de la app
    final appUser = AppUserModel.fromFirebaseUser(firebaseUser);

    // Realizar petición HTTP al servidor con el usuario y push token
    try {
      await _syncUserWithServer(appUser, firebaseUser, pushToken);
    } catch (e) {
      // Log del error pero continuar con la autenticación local
      print('Error al sincronizar usuario con servidor: $e');
    }

    return appUser;
  }

  Future<void> _syncUserWithServer(
    AppUserModel user,
    User firebaseUser,
    String pushToken,
  ) async {
    print({
      'user': {
        'uid': firebaseUser.uid,
        'email': firebaseUser.email,
        'name': firebaseUser.displayName,
        'photoUrl': firebaseUser.photoURL,
      },
      'token': pushToken,
    });
    try {
      final response = await dio.post(
        '/api/auth/me',
        data: {
          'user': {
            'uid': firebaseUser.uid,
            'email': firebaseUser.email,
            'name': firebaseUser.displayName,
            'photoUrl': firebaseUser.photoURL,
          },
          'token': pushToken,
        },
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Error al sincronizar usuario: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> signOut() async {
    await googleSignIn.signOut();
    await firebaseAuth.signOut();
  }
}
