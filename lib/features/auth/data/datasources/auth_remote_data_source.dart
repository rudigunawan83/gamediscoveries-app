import '../../../../core/network/api_client.dart';
import '../../domain/models/auth_user.dart';
import '../models/login_response.dart';

class AuthRemoteDataSource {
  AuthRemoteDataSource(this._apiClient);

  final ApiClient _apiClient;

  Future<LoginResponse> login({
    required String email,
    required String password,
  }) {
    return _apiClient.post<LoginResponse>(
      '/api/v1/auth/login',
      body: <String, dynamic>{'email': email, 'password': password},
      parser: (Object? json) {
        return LoginResponse.fromJson(
          json as Map<String, dynamic>? ?? const {},
        );
      },
    );
  }

  Future<LoginResponse> register({
    required String email,
    required String password,
    required String displayName,
  }) {
    return _apiClient.post<LoginResponse>(
      '/api/v1/auth/register',
      body: <String, dynamic>{
        'email': email,
        'password': password,
        'displayName': displayName,
      },
      parser: (Object? json) {
        return LoginResponse.fromJson(
          json as Map<String, dynamic>? ?? const {},
        );
      },
    );
  }

  Future<AuthUser> getCurrentUser() {
    return _apiClient.get<AuthUser>(
      '/api/v1/users/me',
      parser: (Object? json) {
        return AuthUser.fromJson(json as Map<String, dynamic>? ?? const {});
      },
    );
  }

  Future<Map<String, dynamic>> logout() {
    return _apiClient.post<Map<String, dynamic>>(
      '/api/v1/auth/logout',
      parser: (Object? json) {
        return json as Map<String, dynamic>? ?? const <String, dynamic>{};
      },
    );
  }
}
