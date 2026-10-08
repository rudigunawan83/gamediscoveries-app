import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/providers/network_providers.dart';
import '../domain/mission_models.dart';

class MissionsRepository {
  MissionsRepository(this._api);

  final ApiClient _api;

  Future<MyMissions> getMyMissions() {
    return _api.get<MyMissions>(
      '/api/v1/me/missions',
      parser: (Object? json) =>
          MyMissions.fromJson(json as Map<String, dynamic>? ?? const {}),
    );
  }
}

final missionsRepositoryProvider = Provider<MissionsRepository>((Ref ref) {
  return MissionsRepository(ref.watch(apiClientProvider));
});
