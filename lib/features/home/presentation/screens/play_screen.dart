import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../shared/models/game_summary.dart';
import '../../../../shared/widgets/game_list_tile.dart';
import '../../../../shared/widgets/game_shelf.dart';
import '../../../../shared/widgets/section_header.dart';
import '../../../../shared/widgets/state_views.dart';
import '../../../discovery/presentation/providers/discovery_providers.dart';
import '../../../favorites/data/library_repository.dart';
import '../../../favorites/presentation/library_providers.dart';

class PlayScreen extends ConsumerWidget {
  const PlayScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final quickPlay = ref.watch(quickPlayProvider);
    final history = ref.watch(playHistoryProvider).value;
    final recent = _uniqueGames(history ?? const <HistoryEntry>[]);

    return Scaffold(
      appBar: AppBar(title: const Text('Play'), centerTitle: false),
      body: RefreshIndicator(
        onRefresh: () {
          ref.invalidate(playHistoryProvider);
          return ref.refresh(quickPlayProvider.future);
        },
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.only(bottom: 32),
          children: <Widget>[
            if (recent.isNotEmpty) ...<Widget>[
              GameShelf(
                title: 'Continue Playing',
                games: recent,
                onSeeAll: () => context.push(AppRoutes.history),
              ),
              const SizedBox(height: 24),
            ],
            const SectionHeader(title: 'Quick Play'),
            const SizedBox(height: 12),
            quickPlay.when(
              data: (List<GameSummary> games) {
                if (games.isEmpty) {
                  return const MessageView(
                    icon: Icons.sports_esports_outlined,
                    message: 'No quick play picks right now.',
                  );
                }
                return Column(
                  children: <Widget>[
                    for (final game in games)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
                        child: GameListTile(
                          game: game,
                          trailing: _PlayButton(slug: game.slug),
                        ),
                      ),
                  ],
                );
              },
              loading: () => const LoadingView(),
              error: (Object error, StackTrace stackTrace) => ErrorView(
                error: error,
                onRetry: () => ref.invalidate(quickPlayProvider),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static List<GameSummary> _uniqueGames(List<HistoryEntry> entries) {
    final seen = <String>{};
    return <GameSummary>[
      for (final e in entries)
        if (seen.add(e.game.id)) e.game,
    ];
  }
}

class _PlayButton extends StatelessWidget {
  const _PlayButton({required this.slug});

  final String slug;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 8),
      child: Material(
        color: AppColors.gold,
        shape: const CircleBorder(),
        child: IconButton(
          tooltip: 'Play now',
          onPressed: () => context.push(AppRoutes.gamePlay(slug)),
          icon: const Icon(Icons.play_arrow_rounded, color: AppColors.onGold),
        ),
      ),
    );
  }
}
