import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/providers/network_providers.dart';
import '../../../core/utils/json_parsing.dart';
import '../domain/leaderboard_models.dart';

class LeaderboardRepository {
  LeaderboardRepository(this._api);

  final ApiClient _api;

  Future<List<LeaderboardSummary>> listLeaderboards() {
    return _api.get<List<LeaderboardSummary>>(
      '/api/v1/leaderboards',
      parser: (Object? json) =>
          parseJsonList(json, LeaderboardSummary.fromJson),
    );
  }

  Future<LeaderboardDetail> getLeaderboard(String code, {int limit = 50}) {
    return _api.get<LeaderboardDetail>(
      '/api/v1/leaderboards/${Uri.encodeComponent(code)}',
      queryParameters: <String, dynamic>{'limit': limit},
      parser: (Object? json) =>
          LeaderboardDetail.fromJson(json as Map<String, dynamic>? ?? const {}),
    );
  }
}

final leaderboardRepositoryProvider = Provider<LeaderboardRepository>((
  Ref ref,
) {
  return LeaderboardRepository(ref.watch(apiClientProvider));
});
