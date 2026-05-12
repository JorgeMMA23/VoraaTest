import 'package:firebase_auth/firebase_auth.dart';
import 'package:rest_app/features/auth/domain/entities/user_entity.dart';

class AppUserModel extends UserEntity {
  const AppUserModel({
    required super.uid,
    required super.email,
    required super.name,
    required super.photoUrl,
  });

  factory AppUserModel.fromFirebaseUser(User user) {
    return AppUserModel(
      uid: user.uid,
      email: user.email ?? '',
      name: user.displayName ?? 'Usuario de Google',
      photoUrl: user.photoURL ?? '',
    );
  }

  factory AppUserModel.fromJson(Map<String, dynamic> json) {
    return AppUserModel(
      uid: json['uid'] as String,
      email: json['email'] as String,
      name: json['name'] as String,
      photoUrl: json['photoUrl'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'uid': uid,
    'email': email,
    'name': name,
    'photoUrl': photoUrl,
  };
}
