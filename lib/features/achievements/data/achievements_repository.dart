import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/providers/network_providers.dart';
import '../domain/achievement_models.dart';

class AchievementsRepository {
  AchievementsRepository(this._api);

  final ApiClient _api;

  Future<AchievementList> getMyAchievements() {
    return _api.get<AchievementList>(
      '/api/v1/me/achievements',
      parser: (Object? json) =>
          AchievementList.fromJson(json as Map<String, dynamic>? ?? const {}),
    );
  }
}

final achievementsRepositoryProvider = Provider<AchievementsRepository>((
  Ref ref,
) {
  return AchievementsRepository(ref.watch(apiClientProvider));
});
