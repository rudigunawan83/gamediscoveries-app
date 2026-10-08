import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/presentation/providers/auth_session_controller.dart';
import '../data/leaderboard_repository.dart';
import '../domain/leaderboard_models.dart';

final leaderboardsProvider = FutureProvider<List<LeaderboardSummary>>((
  Ref ref,
) {
  return ref.watch(leaderboardRepositoryProvider).listLeaderboards();
});

/// `null` means no leaderboard is configured for the scope.
final leaderboardDetailProvider = FutureProvider.autoDispose
    .family<LeaderboardDetail?, LeaderboardScope>((
      Ref ref,
      LeaderboardScope scope,
    ) async {
      await ref.watch(isSignedInProvider.future);
      final boards = await ref.watch(leaderboardsProvider.future);
      final match = boards.where(
        (LeaderboardSummary b) => b.type == scope.type,
      );
      if (match.isEmpty) return null;

      return ref
          .watch(leaderboardRepositoryProvider)
          .getLeaderboard(match.first.code);
    });
