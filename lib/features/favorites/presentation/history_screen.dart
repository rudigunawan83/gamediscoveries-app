import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/app_routes.dart';
import '../../../core/l10n/locale_resolution.dart';
import '../../../shared/widgets/game_list_tile.dart';
import '../../../shared/widgets/state_views.dart';
import '../data/library_repository.dart';
import 'continue_playing_section.dart';
import 'library_providers.dart';

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final history = ref.watch(playHistoryProvider);
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.profilePlayHistory)),
      body: history.when(
        skipLoadingOnRefresh: true,
        data: (List<HistoryEntry>? entries) {
          if (entries == null) {
            return SignInRequiredView(
              icon: Icons.history_rounded,
              title: l10n.historySignInTitle,
              message: l10n.historySignInMessage,
            );
          }
          if (entries.isEmpty) {
            return MessageView(
              icon: Icons.history_toggle_off_rounded,
              title: l10n.historyEmptyTitle,
              message: l10n.historyEmptyMessage,
              actionLabel: l10n.commonFindGame,
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
                  subtitle: _subtitle(l10n, entry),
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

  static String _subtitle(AppLocalizations l10n, HistoryEntry entry) {
    final details = ContinuePlayingCard.details(l10n, entry);
    final plays = entry.playCount;
    if (plays <= 1) return details;
    return '$details · ${l10n.historyPlayCount(plays)}';
  }
}
