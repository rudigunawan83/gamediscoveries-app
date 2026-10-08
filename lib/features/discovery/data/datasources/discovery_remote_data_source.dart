import '../../../../core/network/api_client.dart';
import '../../../../core/network/models/paged_result.dart';
import '../../../../core/utils/json_parsing.dart';
import '../../../../shared/models/game_summary.dart';
import '../../domain/models/game_category.dart';
import '../../domain/models/game_list_query.dart';
import '../../domain/models/home_discoveries.dart';

class DiscoveryRemoteDataSource {
  DiscoveryRemoteDataSource(this._apiClient);

  final ApiClient _apiClient;

  Future<HomeDiscoveries> getHomeDiscoveries() {
    return _apiClient.get<HomeDiscoveries>(
      '/api/v1/discoveries/home',
      parser: (Object? json) {
        return HomeDiscoveries.fromJson(
          json as Map<String, dynamic>? ?? const <String, dynamic>{},
        );
      },
    );
  }

  Future<PagedResult<GameSummary>> listGames(GameListQuery query) {
    return _apiClient.getPaged<GameSummary>(
      '/api/v1/games',
      queryParameters: query.toQueryParameters(),
      itemParser: GameSummary.fromJson,
    );
  }

  Future<List<GameCategory>> listCategories() {
    return _apiClient.get<List<GameCategory>>(
      '/api/v1/categories',
      parser: (Object? json) => parseJsonList(json, GameCategory.fromJson),
    );
  }

  /// [path] is a recommendation path segment such as `for-you`,
  /// `quick-play` or `similar/{gameId}`.
  Future<List<GameSummary>> getRecommendations(String path) {
    return _apiClient.get<List<GameSummary>>(
      '/api/v1/recommendations/$path',
      parser: (Object? json) {
        final map = json as Map<String, dynamic>? ?? const {};
        return parseJsonList(map['items'], _recommendedGame);
      },
    );
  }

  static GameSummary _recommendedGame(Map<String, dynamic> item) {
    final game = item['game'] as Map<String, dynamic>? ?? const {};
    return GameSummary.fromJson(game);
  }
}
