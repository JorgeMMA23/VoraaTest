import 'package:rest_app/features/auth/data/models/app_user_model.dart';

class AuthResponseModel {
  final AppUserModel user;
  final String? token;

  AuthResponseModel({required this.user, this.token});

  factory AuthResponseModel.fromJson(Map<String, dynamic> json) {
    return AuthResponseModel(
      user: AppUserModel.fromJson(json['user'] as Map<String, dynamic>),
      token: json['token'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {'user': user.toJson(), 'token': token};
}
