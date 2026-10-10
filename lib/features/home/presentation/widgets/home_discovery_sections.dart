import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../core/l10n/locale_resolution.dart';
import '../../../../shared/models/game_summary.dart';
import '../../../../shared/widgets/game_shelf.dart';
import '../../../../shared/widgets/state_views.dart';
import '../../../discovery/domain/models/home_discoveries.dart';
import '../../../discovery/presentation/providers/discovery_providers.dart';
import '../../../ad_rewards/presentation/watch_ad_reward_card.dart';
import '../../../favorites/presentation/continue_playing_section.dart';
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
          return MessageView(
            icon: Icons.videogame_asset_off_rounded,
            message: context.l10n.homeEmpty,
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
    final l10n = context.l10n;

    final shelves = <Widget>[
      _RecommendedShelf(fallback: data.trending),
      FeaturedCarousel(games: data.featured),
      GameShelf(
        title: l10n.homeShelfTrending,
        games: data.trending,
        onSeeAll: seeAll,
      ),
      const _MobileReadyShelf(),
      GameShelf(
        title: l10n.homeShelfPopular,
        games: data.popular,
        onSeeAll: seeAll,
      ),
      GameShelf(
        title: l10n.homeShelfNewReleases,
        games: data.latest,
        onSeeAll: seeAll,
      ),
      GameShelf(title: l10n.homeShelfHot, games: data.hotGames),
      GameShelf(title: l10n.homeShelfMostPlayed, games: data.mostPlayed),
      GameShelf(title: l10n.homeShelfBest, games: data.bestGames),
      GameShelf(title: l10n.homeShelfMultiplayer, games: data.multiplayer),
      GameShelf(title: l10n.homeShelfExclusive, games: data.exclusiveGames),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const ContinuePlayingSection(trailingGap: _sectionGap),
        const WatchAdRewardCard(trailingGap: _sectionGap),
        for (final shelf in shelves) ...<Widget>[
          shelf,
          const SizedBox(height: _sectionGap),
        ],
      ],
    );
  }
}

class _RecommendedShelf extends ConsumerWidget {
  const _RecommendedShelf({required this.fallback});

  final List<GameSummary> fallback;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final games = ref.watch(forYouProvider).value;

    return GameShelf(
      title: context.l10n.homeShelfRecommended,
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
        title: context.l10n.homeShelfMobile,
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
