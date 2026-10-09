import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/providers/network_providers.dart';
import '../../auth/domain/models/auth_user.dart';

class AvatarRepository {
  AvatarRepository(this._api);

  static const String _path = '/api/v1/users/me/avatar';

  final ApiClient _api;

  /// The server validates, crops and re-encodes the image; returns the
  /// updated current user.
  Future<AuthUser> upload(List<int> bytes, {required String fileName}) {
    return _api.post<AuthUser>(
      _path,
      body: FormData.fromMap(<String, dynamic>{
        'file': MultipartFile.fromBytes(bytes, filename: fileName),
      }),
      parser: _parseUser,
    );
  }

  Future<AuthUser> remove() {
    return _api.delete<AuthUser>(_path, parser: _parseUser);
  }

  static AuthUser _parseUser(Object? json) =>
      AuthUser.fromJson(json as Map<String, dynamic>? ?? const {});
}

final avatarRepositoryProvider = Provider<AvatarRepository>((Ref ref) {
  return AvatarRepository(ref.watch(apiClientProvider));
});
