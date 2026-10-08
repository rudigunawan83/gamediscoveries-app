import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/models/paged_result.dart';
import '../../../../core/network/providers/network_providers.dart';
import '../../../../shared/models/game_summary.dart';
import '../../domain/models/game_category.dart';
import '../../domain/models/game_list_query.dart';
import '../../domain/models/home_discoveries.dart';
import '../datasources/discovery_remote_data_source.dart';

class DiscoveryRepository {
  DiscoveryRepository(this._remote);

  final DiscoveryRemoteDataSource _remote;

  Future<HomeDiscoveries> getHomeDiscoveries() {
    return _remote.getHomeDiscoveries();
  }

  Future<PagedResult<GameSummary>> listGames(GameListQuery query) {
    return _remote.listGames(query);
  }

  Future<List<GameCategory>> listCategories() => _remote.listCategories();

  Future<List<GameSummary>> getForYou() =>
      _remote.getRecommendations('for-you');

  Future<List<GameSummary>> getQuickPlay() =>
      _remote.getRecommendations('quick-play');

  Future<List<GameSummary>> getSimilar(String gameId) =>
      _remote.getRecommendations('similar/$gameId');
}

final discoveryRemoteDataSourceProvider = Provider<DiscoveryRemoteDataSource>((
  Ref ref,
) {
  return DiscoveryRemoteDataSource(ref.watch(apiClientProvider));
});

final discoveryRepositoryProvider = Provider<DiscoveryRepository>((Ref ref) {
  return DiscoveryRepository(ref.watch(discoveryRemoteDataSourceProvider));
});
