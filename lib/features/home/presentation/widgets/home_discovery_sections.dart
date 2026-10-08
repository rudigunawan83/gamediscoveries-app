import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../shared/models/game_summary.dart';
import '../../../../shared/widgets/game_shelf.dart';
import '../../../../shared/widgets/state_views.dart';
import '../../../discovery/domain/models/home_discoveries.dart';
import '../../../discovery/presentation/providers/discovery_providers.dart';
import '../../../favorites/data/library_repository.dart';
import '../../../favorites/presentation/library_providers.dart';
import 'featured_carousel.dart';

const double _sectionGap = 28;
const int _skeletonShelfCount = 3;

class HomeDiscoverySections extends ConsumerWidget {
  const HomeDiscoverySections({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final home = ref.watch(homeDiscoveriesProvider);

    return home.when(
      skipLoadingOnRefresh: true,
      data: (HomeDiscoveries data) {
        if (data.isEmpty) {
          return const MessageView(
            icon: Icons.videogame_asset_off_rounded,
            message: 'No games to show yet. Check back soon.',
          );
        }

        return _HomeContent(data: data);
      },
      loading: () => const _HomeSkeleton(),
      error: (Object error, StackTrace stackTrace) => ErrorView(
        error: error,
        onRetry: () => ref.invalidate(homeDiscoveriesProvider),
      ),
    );
  }
}

class _HomeContent extends StatelessWidget {
  const _HomeContent({required this.data});

  final HomeDiscoveries data;

  @override
  Widget build(BuildContext context) {
    void seeAll() => context.go(AppRoutes.discover);

    final shelves = <Widget>[
      const _ContinuePlayingShelf(),
      _RecommendedShelf(fallback: data.trending),
      FeaturedCarousel(games: data.featured),
      GameShelf(title: 'Trending Now', games: data.trending, onSeeAll: seeAll),
      const _MobileReadyShelf(),
      GameShelf(title: 'Popular', games: data.popular, onSeeAll: seeAll),
      GameShelf(title: 'New Releases', games: data.latest, onSeeAll: seeAll),
      GameShelf(title: 'Hot Games', games: data.hotGames),
      GameShelf(title: 'Most Played', games: data.mostPlayed),
      GameShelf(title: 'Best Games', games: data.bestGames),
      GameShelf(title: 'Multiplayer', games: data.multiplayer),
      GameShelf(title: 'Exclusive', games: data.exclusiveGames),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        for (final shelf in shelves) ...<Widget>[
          shelf,
          const SizedBox(height: _sectionGap),
        ],
      ],
    );
  }
}

class _ContinuePlayingShelf extends ConsumerWidget {
  const _ContinuePlayingShelf();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final history = ref.watch(playHistoryProvider).value;
    if (history == null || history.isEmpty) return const SizedBox.shrink();

    return GameShelf(
      title: 'Continue Playing',
      games: _uniqueGames(history),
      onSeeAll: () => context.push(AppRoutes.history),
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

class _RecommendedShelf extends ConsumerWidget {
  const _RecommendedShelf({required this.fallback});

  final List<GameSummary> fallback;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final games = ref.watch(forYouProvider).value;

    return GameShelf(
      title: 'Recommended For You',
      games: games == null || games.isEmpty ? fallback : games,
      onSeeAll: () => context.go(AppRoutes.discover),
    );
  }
}

class _MobileReadyShelf extends ConsumerWidget {
  const _MobileReadyShelf();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final games = ref.watch(gameListProvider(mobileReadyShelfQuery));

    return games.when(
      skipLoadingOnRefresh: true,
      data: (result) => GameShelf(
        title: 'Made for Mobile',
        games: result.items,
        onSeeAll: () => context.go(AppRoutes.discover),
      ),
      loading: () => const GameShelfSkeleton(),
      error: (Object error, StackTrace stackTrace) => const SizedBox.shrink(),
    );
  }
}

class _HomeSkeleton extends StatelessWidget {
  const _HomeSkeleton();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        for (var i = 0; i < _skeletonShelfCount; i++) ...<Widget>[
          const SizedBox(height: _sectionGap),
          const GameShelfSkeleton(),
        ],
      ],
    );
  }
}
