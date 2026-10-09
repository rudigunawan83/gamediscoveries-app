import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/providers/network_providers.dart';
import '../domain/privacy_settings.dart';

class PrivacyRepository {
  PrivacyRepository(this._api);

  final ApiClient _api;

  Future<PrivacySettings> getPrivacy() {
    return _api.get<PrivacySettings>(
      '/api/v1/users/me/privacy',
      parser: (Object? json) =>
          PrivacySettings.fromJson(json as Map<String, dynamic>? ?? const {}),
    );
  }

  /// The API only changes the fields that are sent.
  Future<void> update(PrivacyOption option, bool value) {
    return _api.putAction(
      '/api/v1/users/me/privacy',
      body: <String, dynamic>{option.jsonKey: value},
    );
  }
}

final privacyRepositoryProvider = Provider<PrivacyRepository>((Ref ref) {
  return PrivacyRepository(ref.watch(apiClientProvider));
});
