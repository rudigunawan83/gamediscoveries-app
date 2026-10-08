import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/providers/network_providers.dart';
import '../../../core/storage/local_preferences.dart';

class GameSessionRepository {
  GameSessionRepository(this._api, this._prefs);

  final ApiClient _api;
  final LocalPreferences _prefs;

  String get _anonymousId => _prefs.anonymousId;

  /// Returns the server-issued session id.
  Future<String> start(String gameId, {required String platform}) {
    return _api.post<String>(
      '/api/v1/games/$gameId/sessions/start',
      body: <String, dynamic>{
        'anonymousId': _anonymousId,
        'source': 'mobile_app',
        'platform': platform,
        'deviceType': 'mobile',
      },
      parser: (Object? json) {
        final map = json as Map<String, dynamic>? ?? const {};
        return map['sessionId'] as String? ?? '';
      },
    );
  }

  Future<void> heartbeat(String sessionId, {required bool focused}) {
    return _api.postAction(
      '/api/v1/games/sessions/$sessionId/heartbeat',
      body: <String, dynamic>{
        'anonymousId': _anonymousId,
        'clientTimestamp': DateTime.now().toUtc().toIso8601String(),
        'visibilityState': focused ? 'visible' : 'hidden',
        'isFocused': focused,
      },
    );
  }

  Future<void> pause(String sessionId) => _lifecycle(sessionId, 'pause');

  Future<void> resume(String sessionId) => _lifecycle(sessionId, 'resume');

  Future<void> end(String sessionId) => _lifecycle(sessionId, 'end', 'exit');

  Future<void> _lifecycle(String sessionId, String action, [String? reason]) {
    return _api.postAction(
      '/api/v1/games/sessions/$sessionId/$action',
      body: <String, dynamic>{
        'anonymousId': _anonymousId,
        'reason': reason ?? 'app_lifecycle',
      },
    );
  }
}

final gameSessionRepositoryProvider = Provider<GameSessionRepository>((
  Ref ref,
) {
  return GameSessionRepository(
    ref.watch(apiClientProvider),
    ref.watch(localPreferencesProvider),
  );
});
