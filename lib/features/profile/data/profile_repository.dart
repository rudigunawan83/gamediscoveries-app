import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/providers/network_providers.dart';
import '../../auth/domain/models/auth_user.dart';

class ProfileRepository {
  ProfileRepository(this._api);

  final ApiClient _api;

  /// Returns the updated current user.
  Future<AuthUser> updateProfile({
    required String displayName,
    required String username,
  }) {
    return _api.put<AuthUser>(
      '/api/v1/users/me/profile',
      body: <String, dynamic>{
        'displayName': displayName.trim(),
        'username': username.trim().toLowerCase(),
      },
      parser: (Object? json) =>
          AuthUser.fromJson(json as Map<String, dynamic>? ?? const {}),
    );
  }
}

final profileRepositoryProvider = Provider<ProfileRepository>((Ref ref) {
  return ProfileRepository(ref.watch(apiClientProvider));
});
