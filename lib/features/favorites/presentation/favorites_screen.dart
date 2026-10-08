import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/app_routes.dart';
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

    return Scaffold(
      appBar: AppBar(title: const Text('My Favorites')),
      body: favorites.when(
        skipLoadingOnRefresh: true,
        data: (List<GameSummary>? games) {
          if (games == null) {
            return const SignInRequiredView(
              icon: Icons.favorite_rounded,
              title: 'Save your favorites',
              message: 'Sign in to keep a list of games you love.',
            );
          }
          if (games.isEmpty) {
            return MessageView(
              icon: Icons.favorite_border_rounded,
              title: 'No favorites yet',
              message: 'Tap the heart on any game to save it here.',
              actionLabel: 'Discover Games',
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
