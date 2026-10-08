import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/models/game_summary.dart';
import '../../auth/presentation/providers/auth_session_controller.dart';
import '../data/library_repository.dart';

/// `null` means the visitor is a guest.
final favoriteGamesProvider = FutureProvider.autoDispose<List<GameSummary>?>((
  Ref ref,
) async {
  if (!await ref.watch(isSignedInProvider.future)) return null;
  final page = await ref.watch(libraryRepositoryProvider).getFavorites();
  return page.items;
});

/// `null` means the visitor is a guest.
final playHistoryProvider = FutureProvider<List<HistoryEntry>?>((
  Ref ref,
) async {
  if (!await ref.watch(isSignedInProvider.future)) return null;
  final page = await ref.watch(libraryRepositoryProvider).getHistory();
  return page.items;
});

enum FavoriteToggleResult { added, removed, signInRequired }

/// Favorite game ids of the signed-in user, used to render heart states.
class FavoriteIdsController extends AsyncNotifier<Set<String>> {
  @override
  Future<Set<String>> build() async {
    if (!await ref.watch(isSignedInProvider.future)) return <String>{};
    final page = await ref.read(libraryRepositoryProvider).getFavorites();
    return page.items.map((GameSummary g) => g.id).toSet();
  }

  Future<FavoriteToggleResult> toggle(String gameId) async {
    if (!await ref.read(isSignedInProvider.future)) {
      return FavoriteToggleResult.signInRequired;
    }

    final current = state.value ?? <String>{};
    final wasFavorite = current.contains(gameId);
    final next = Set<String>.of(current);
    wasFavorite ? next.remove(gameId) : next.add(gameId);
    state = AsyncData<Set<String>>(next);

    final repo = ref.read(libraryRepositoryProvider);
    try {
      if (wasFavorite) {
        await repo.removeFavorite(gameId);
      } else {
        await repo.addFavorite(gameId);
      }
    } catch (_) {
      state = AsyncData<Set<String>>(current);
      rethrow;
    }

    ref.invalidate(favoriteGamesProvider);
    return wasFavorite
        ? FavoriteToggleResult.removed
        : FavoriteToggleResult.added;
  }
}

final favoriteIdsProvider =
    AsyncNotifierProvider<FavoriteIdsController, Set<String>>(
      FavoriteIdsController.new,
    );
