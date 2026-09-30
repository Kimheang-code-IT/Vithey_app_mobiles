import 'package:aub_connect_app/data/models/auth_token_model.dart';
import 'package:aub_connect_app/data/models/user_model.dart';

class AuthResultModel {
  const AuthResultModel({
    required this.user,
    required this.tokens,
  });

  final UserModel user;
  final AuthTokenModel tokens;

  factory AuthResultModel.fromJson(Map<String, dynamic> json) {
    return AuthResultModel(
      user: UserModel.fromJson(json['user'] as Map<String, dynamic>? ?? {}),
      tokens: AuthTokenModel.fromJson(json['tokens'] as Map<String, dynamic>? ?? {}),
    );
  }
}
