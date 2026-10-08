import '../../domain/models/auth_user.dart';

class LoginResponse {
  const LoginResponse({
    required this.accessToken,
    required this.expiresIn,
    required this.user,
    this.refreshToken,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      accessToken: json['accessToken'] as String? ?? '',
      expiresIn: (json['expiresIn'] as num?)?.toInt() ?? 0,
      refreshToken: json['refreshToken'] as String?,
      user: AuthUser.fromJson(
        json['user'] as Map<String, dynamic>? ?? const {},
      ),
    );
  }

  final String accessToken;
  final int expiresIn;
  final String? refreshToken;
  final AuthUser user;
}
