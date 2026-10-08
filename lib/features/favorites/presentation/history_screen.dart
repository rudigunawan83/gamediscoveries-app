import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/app_routes.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/widgets/game_list_tile.dart';
import '../../../shared/widgets/state_views.dart';
import '../data/library_repository.dart';
import 'library_providers.dart';

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final history = ref.watch(playHistoryProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Play History')),
      body: history.when(
        skipLoadingOnRefresh: true,
        data: (List<HistoryEntry>? entries) {
          if (entries == null) {
            return const SignInRequiredView(
              icon: Icons.history_rounded,
              title: 'Your play history',
              message: 'Sign in to pick up right where you left off.',
            );
          }
          if (entries.isEmpty) {
            return MessageView(
              icon: Icons.history_toggle_off_rounded,
              title: 'Nothing played yet',
              message: 'Games you play will show up here.',
              actionLabel: 'Find a Game',
              onAction: () => context.go(AppRoutes.discover),
            );
          }

          return RefreshIndicator(
            onRefresh: () => ref.refresh(playHistoryProvider.future),
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
              itemCount: entries.length,
              separatorBuilder: (BuildContext context, int index) =>
                  const SizedBox(height: 10),
              itemBuilder: (BuildContext context, int index) {
                final entry = entries[index];
                return GameListTile(
                  game: entry.game,
                  subtitle: _subtitle(entry),
                );
              },
            ),
          );
        },
        loading: () => const LoadingView(),
        error: (Object error, StackTrace stackTrace) => ErrorView(
          error: error,
          onRetry: () => ref.invalidate(playHistoryProvider),
        ),
      ),
    );
  }

  static String _subtitle(HistoryEntry entry) {
    final played = formatTimeAgo(entry.playedAt);
    final minutes = entry.durationSeconds ~/ 60;
    if (minutes <= 0) return played;
    return '$played · ${minutes}m played';
  }
}
