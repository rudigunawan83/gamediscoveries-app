import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/providers/network_providers.dart';
import '../domain/progress_models.dart';

class ProgressRepository {
  ProgressRepository(this._api);

  final ApiClient _api;

  Future<UserProgress> getMyProgress() {
    return _api.get<UserProgress>(
      '/api/v1/me/progress',
      parser: (Object? json) =>
          UserProgress.fromJson(json as Map<String, dynamic>? ?? const {}),
    );
  }

  Future<List<XpTransaction>> getRecentXp({int pageSize = 10}) {
    return _api.get<List<XpTransaction>>(
      '/api/v1/me/xp/transactions',
      queryParameters: <String, dynamic>{'page': 1, 'pageSize': pageSize},
      parser: XpTransaction.listFrom,
    );
  }
}

final progressRepositoryProvider = Provider<ProgressRepository>((Ref ref) {
  return ProgressRepository(ref.watch(apiClientProvider));
});
