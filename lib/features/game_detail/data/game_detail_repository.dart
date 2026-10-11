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

  /// Creates the viewer's review, or replaces the one they already wrote.
  Future<GameReview> upsertReview(
    String slug, {
    required int rating,
    required String content,
  }) {
    return _api.post<GameReview>(
      '/api/v1/games/${Uri.encodeComponent(slug)}/reviews',
      body: <String, dynamic>{'rating': rating, 'content': content},
      parser: (Object? json) =>
          GameReview.fromJson(json as Map<String, dynamic>? ?? const {}),
    );
  }
}

final gameDetailRepositoryProvider = Provider<GameDetailRepository>((Ref ref) {
  return GameDetailRepository(ref.watch(apiClientProvider));
});
