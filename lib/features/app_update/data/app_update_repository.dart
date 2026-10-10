import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/providers/network_providers.dart';
import '../domain/app_release.dart';

class AppUpdateRepository {
  AppUpdateRepository(this._api);

  final ApiClient _api;

  Future<AppRelease> getRelease(String platform) {
    return _api.get<AppRelease>(
      '/api/v1/app/version',
      queryParameters: <String, dynamic>{'platform': platform},
      parser: (Object? json) =>
          AppRelease.fromJson(json as Map<String, dynamic>? ?? const {}),
    );
  }
}

final appUpdateRepositoryProvider = Provider<AppUpdateRepository>((Ref ref) {
  return AppUpdateRepository(ref.watch(apiClientProvider));
});
