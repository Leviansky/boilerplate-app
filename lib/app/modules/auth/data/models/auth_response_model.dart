import 'user_model.dart';

class AuthResponseModel {
  final String accessToken;
  final String refreshToken;
  final int expiresIn;
  final UserModel user;

  const AuthResponseModel({
    required this.accessToken,
    required this.refreshToken,
    required this.expiresIn,
    required this.user,
  });

  factory AuthResponseModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const AuthResponseModel(
        accessToken: '',
        refreshToken: '',
        expiresIn: 0,
        user: UserModel(
          id: '',
          name: '',
          email: '',
          phoneNumber: '',
          isPinConfigured: false,
          isBiometricConfigured: false,
        ),
      );
    }

    return AuthResponseModel(
      accessToken: json['access_token']?.toString() ?? '',
      refreshToken: json['refresh_token']?.toString() ?? '',
      expiresIn: int.tryParse(json['expires_in']?.toString() ?? '0') ?? 0,
      user: UserModel.fromJson(json['user'] as Map<String, dynamic>?),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'access_token': accessToken,
      'refresh_token': refreshToken,
      'expires_in': expiresIn,
      'user': user.toJson(),
    };
  }
}
