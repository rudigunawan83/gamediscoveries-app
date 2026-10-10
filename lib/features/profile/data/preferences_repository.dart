import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/app_language.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/providers/network_providers.dart';
import '../../auth/domain/models/auth_user.dart';

class PreferencesRepository {
  PreferencesRepository(this._api);

  final ApiClient _api;

  /// Returns the updated current user.
  Future<AuthUser> updateLanguage(AppLanguage language) {
    return _api.put<AuthUser>(
      '/api/v1/users/me/preferences',
      body: <String, dynamic>{'preferredLanguage': language.code},
      parser: (Object? json) =>
          AuthUser.fromJson(json as Map<String, dynamic>? ?? const {}),
    );
  }
}

final preferencesRepositoryProvider = Provider<PreferencesRepository>((
  Ref ref,
) {
  return PreferencesRepository(ref.watch(apiClientProvider));
});
