import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/app_routes.dart';
import '../../../core/l10n/locale_resolution.dart';
import '../../../shared/models/game_summary.dart';
import '../../../shared/widgets/game_list_tile.dart';
import '../../../shared/widgets/state_views.dart';
import 'favorite_button.dart';
import 'library_providers.dart';

class FavoritesScreen extends ConsumerWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favorites = ref.watch(favoriteGamesProvider);
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.profileMyFavorites)),
      body: favorites.when(
        skipLoadingOnRefresh: true,
        data: (List<GameSummary>? games) {
          if (games == null) {
            return SignInRequiredView(
              icon: Icons.favorite_rounded,
              title: l10n.favoritesSignInTitle,
              message: l10n.favoritesSignInMessage,
            );
          }
          if (games.isEmpty) {
            return MessageView(
              icon: Icons.favorite_border_rounded,
              title: l10n.favoritesEmptyTitle,
              message: l10n.favoritesEmptyMessage,
              actionLabel: l10n.favoritesDiscoverGames,
              onAction: () => context.go(AppRoutes.discover),
            );
          }

          return RefreshIndicator(
            onRefresh: () => ref.refresh(favoriteGamesProvider.future),
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
              itemCount: games.length,
              separatorBuilder: (BuildContext context, int index) =>
                  const SizedBox(height: 10),
              itemBuilder: (BuildContext context, int index) => GameListTile(
                game: games[index],
                trailing: FavoriteButton(gameId: games[index].id),
              ),
            ),
          );
        },
        loading: () => const LoadingView(),
        error: (Object error, StackTrace stackTrace) => ErrorView(
          error: error,
          onRetry: () => ref.invalidate(favoriteGamesProvider),
        ),
      ),
    );
  }
}
