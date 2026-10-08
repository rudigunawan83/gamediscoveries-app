import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/models/paged_result.dart';
import '../../../core/network/providers/network_providers.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/models/game_summary.dart';

class HistoryEntry {
  const HistoryEntry({
    required this.game,
    required this.durationSeconds,
    this.playedAt,
  });

  factory HistoryEntry.fromJson(Map<String, dynamic> json) {
    return HistoryEntry(
      game: GameSummary.fromJson(
        json['game'] as Map<String, dynamic>? ?? const {},
      ),
      durationSeconds: parseInt(json['durationSeconds']),
      playedAt: parseDate(json['playedAt']),
    );
  }

  final GameSummary game;
  final int durationSeconds;
  final DateTime? playedAt;
}

/// Favorites and play history for the signed-in user.
class LibraryRepository {
  LibraryRepository(this._api);

  final ApiClient _api;

  Future<PagedResult<GameSummary>> getFavorites({int pageSize = 50}) {
    return _api.getPaged<GameSummary>(
      '/api/v1/users/me/favorites',
      queryParameters: <String, dynamic>{'page': 1, 'pageSize': pageSize},
      itemParser: (Map<String, dynamic> json) => GameSummary.fromJson(
        json['game'] as Map<String, dynamic>? ?? const {},
      ),
    );
  }

  Future<void> addFavorite(String gameId) {
    return _api.postAction(
      '/api/v1/users/me/favorites',
      body: <String, dynamic>{'gameId': gameId},
    );
  }

  Future<void> removeFavorite(String gameId) {
    return _api.deleteAction('/api/v1/users/me/favorites/$gameId');
  }

  Future<PagedResult<HistoryEntry>> getHistory({int pageSize = 24}) {
    return _api.getPaged<HistoryEntry>(
      '/api/v1/users/me/history',
      queryParameters: <String, dynamic>{'page': 1, 'pageSize': pageSize},
      itemParser: HistoryEntry.fromJson,
    );
  }

  Future<void> recordHistory(String gameId, {int durationSeconds = 0}) {
    return _api.postAction(
      '/api/v1/users/me/history',
      body: <String, dynamic>{
        'gameId': gameId,
        'durationSeconds': durationSeconds,
      },
    );
  }
}

final libraryRepositoryProvider = Provider<LibraryRepository>((Ref ref) {
  return LibraryRepository(ref.watch(apiClientProvider));
});
