import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../core/network/providers/network_providers.dart';
import '../../../../core/storage/auth_token_storage.dart';
import '../../domain/models/auth_session_state.dart';
import '../datasources/auth_remote_data_source.dart';

class AuthRepository {
  AuthRepository({required this._remote, required this._tokenStorage});

  final AuthRemoteDataSource _remote;
  final AuthTokenStorage _tokenStorage;

  Future<AuthSessionState> restoreSession() async {
    final accessToken = await _tokenStorage.readAccessToken();
    if (accessToken == null || accessToken.isEmpty) {
      return const AuthSessionState.guest();
    }

    try {
      final user = await _remote.getCurrentUser();
      return AuthSessionState.authenticated(user);
    } on ApiException catch (error) {
      if (error.isUnauthorized) {
        await _tokenStorage.clear();
        return const AuthSessionState.guest();
      }

      rethrow;
    }
  }

  Future<AuthSessionState> login({
    required String email,
    required String password,
  }) async {
    final response = await _remote.login(email: email, password: password);
    await _tokenStorage.save(
      accessToken: response.accessToken,
      refreshToken: response.refreshToken,
    );

    return AuthSessionState.authenticated(response.user);
  }

  Future<AuthSessionState> register({
    required String email,
    required String password,
    required String displayName,
  }) async {
    final response = await _remote.register(
      email: email,
      password: password,
      displayName: displayName,
    );

    await _tokenStorage.save(
      accessToken: response.accessToken,
      refreshToken: response.refreshToken,
    );

    return AuthSessionState.authenticated(response.user);
  }

  Future<void> logout() async {
    try {
      await _remote.logout();
    } finally {
      await _tokenStorage.clear();
    }
  }
}

final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((Ref ref) {
  return AuthRemoteDataSource(ref.watch(apiClientProvider));
});

final authRepositoryProvider = Provider<AuthRepository>((Ref ref) {
  return AuthRepository(
    remote: ref.watch(authRemoteDataSourceProvider),
    tokenStorage: ref.watch(authTokenStorageProvider),
  );
});
