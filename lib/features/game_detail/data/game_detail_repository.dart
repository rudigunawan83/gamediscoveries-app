import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/providers/network_providers.dart';
import '../domain/game_detail.dart';

class GameDetailRepository {
  GameDetailRepository(this._api);

  final ApiClient _api;

  Future<GameDetail> getBySlug(String slug) {
    return _api.get<GameDetail>(
      '/api/v1/games/${Uri.encodeComponent(slug)}',
      parser: (Object? json) =>
          GameDetail.fromJson(json as Map<String, dynamic>? ?? const {}),
    );
  }

  Future<ReviewSummary> getReviewSummary(String slug) {
    return _api.get<ReviewSummary>(
      '/api/v1/games/${Uri.encodeComponent(slug)}/reviews',
      parser: (Object? json) =>
          ReviewSummary.fromJson(json as Map<String, dynamic>? ?? const {}),
    );
  }
}

final gameDetailRepositoryProvider = Provider<GameDetailRepository>((Ref ref) {
  return GameDetailRepository(ref.watch(apiClientProvider));
});
