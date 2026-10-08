import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/models/paged_result.dart';
import '../../../../shared/models/game_summary.dart';
import '../../../auth/presentation/providers/auth_session_controller.dart';
import '../../data/repositories/discovery_repository.dart';
import '../../domain/models/game_category.dart';
import '../../domain/models/game_list_query.dart';
import '../../domain/models/home_discoveries.dart';

final homeDiscoveriesProvider = FutureProvider<HomeDiscoveries>((Ref ref) {
  return ref.watch(discoveryRepositoryProvider).getHomeDiscoveries();
});

final gameListProvider =
    FutureProvider.family<PagedResult<GameSummary>, GameListQuery>((
      Ref ref,
      GameListQuery query,
    ) {
      return ref.watch(discoveryRepositoryProvider).listGames(query);
    });

final categoriesProvider = FutureProvider<List<GameCategory>>((Ref ref) {
  return ref.watch(discoveryRepositoryProvider).listCategories();
});

final forYouProvider = FutureProvider<List<GameSummary>>((Ref ref) async {
  await ref.watch(isSignedInProvider.future);
  return ref.watch(discoveryRepositoryProvider).getForYou();
});

final quickPlayProvider = FutureProvider<List<GameSummary>>((Ref ref) async {
  await ref.watch(isSignedInProvider.future);
  return ref.watch(discoveryRepositoryProvider).getQuickPlay();
});

final similarGamesProvider = FutureProvider.autoDispose
    .family<List<GameSummary>, String>((Ref ref, String gameId) {
      return ref.watch(discoveryRepositoryProvider).getSimilar(gameId);
    });

const GameListQuery mobileReadyShelfQuery = GameListQuery(
  pageSize: 12,
  mobileReady: true,
  sort: GameSort.newest,
);
