import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';

import '../../../app/config/app_config.dart';
import '../../../app/router/app_routes.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/l10n/locale_resolution.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/models/game_summary.dart';
import '../../../shared/widgets/game_card.dart';
import '../../../shared/widgets/game_shelf.dart';
import '../../../shared/widgets/gd_avatar.dart';
import '../../../shared/widgets/pill_tabs.dart';
import '../../../shared/widgets/state_views.dart';
import '../../discovery/presentation/providers/discovery_providers.dart';
import '../../favorites/presentation/favorite_button.dart';
import '../../game_player/presentation/game_player_screen.dart';
import '../domain/game_detail.dart';
import 'game_detail_providers.dart';

const double _heroHeight = 280;
List<String> _tabs(AppLocalizations l10n) => <String>[
  l10n.gameTabAbout,
  l10n.gameTabHowToPlay,
  l10n.gameTabReviews,
  l10n.gameTabSimilar,
];

class GameDetailScreen extends ConsumerStatefulWidget {
  const GameDetailScreen({required this.slug, super.key});

  final String slug;

  @override
  ConsumerState<GameDetailScreen> createState() => _GameDetailScreenState();
}

class _GameDetailScreenState extends ConsumerState<GameDetailScreen> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    final detail = ref.watch(gameDetailProvider(widget.slug));

    return Scaffold(
      body: detail.when(
        data: (GameDetail game) => _content(context, game),
        loading: () => const _CenteredWithBack(child: LoadingView()),
        error: (Object error, StackTrace stackTrace) => _CenteredWithBack(
          child: ErrorView(
            error: error,
            onRetry: () => ref.invalidate(gameDetailProvider(widget.slug)),
          ),
        ),
      ),
    );
  }

  Widget _content(BuildContext context, GameDetail game) {
    final textTheme = Theme.of(context).textTheme;
    final l10n = context.l10n;
    final canPlay = game.playUrl != null;
    void play() {
      enterGameDisplayMode(landscape: game.isLandscape);
      context.push(AppRoutes.gamePlay(game.slug), extra: game);
    }

    return CustomScrollView(
      slivers: <Widget>[
        SliverAppBar(
          pinned: true,
          expandedHeight: _heroHeight,
          backgroundColor: AppColors.night,
          actions: <Widget>[
            IconButton(
              tooltip: l10n.commonShare,
              onPressed: () => _share(l10n, game),
              icon: const Icon(Icons.share_rounded),
            ),
          ],
          flexibleSpace: FlexibleSpaceBar(
            background: _Hero(game: game, onPlay: canPlay ? play : null),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  game.title,
                  style: textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: <Widget>[
                    if (game.category?.isNotEmpty ?? false)
                      _Chip(label: game.category!, color: AppColors.gold),
                    if (game.mobileReady)
                      _Chip(
                        label: l10n.commonMobileBadge,
                        color: AppColors.success,
                      ),
                    _Chip(
                      label: game.isLandscape
                          ? l10n.gameLandscape
                          : l10n.gamePortrait,
                      color: AppColors.blue,
                    ),
                    for (final tag in game.tags.take(3))
                      _Chip(label: tag, color: AppColors.purple),
                  ],
                ),
                const SizedBox(height: 12),
                _RatingRow(slug: game.slug, developer: game.developer),
                const SizedBox(height: 18),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: canPlay ? play : null,
                        icon: const Icon(Icons.play_arrow_rounded, size: 26),
                        label: Text(
                          canPlay ? l10n.gamePlayNow : l10n.gameNotAvailable,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    _SquareAction(child: FavoriteButton(gameId: game.id)),
                    const SizedBox(width: 10),
                    _SquareAction(
                      child: IconButton(
                        tooltip: l10n.commonShare,
                        onPressed: () => _share(l10n, game),
                        icon: const Icon(
                          Icons.share_outlined,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 22),
              ],
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: PillTabs(
            expanded: false,
            labels: _tabs(l10n),
            selectedIndex: _tab,
            onChanged: (int i) => setState(() => _tab = i),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
            child: switch (_tab) {
              0 => _TextSection(
                text: game.description,
                empty: l10n.gameNoDescription,
              ),
              1 => _TextSection(
                text: game.instructions,
                empty: l10n.gameDefaultInstructions,
              ),
              2 => _ReviewsSection(slug: game.slug),
              _ => _SimilarGrid(gameId: game.id),
            },
          ),
        ),
        if (_tab != 3)
          SliverToBoxAdapter(child: _SimilarShelf(gameId: game.id)),
        const SliverToBoxAdapter(child: SizedBox(height: 40)),
      ],
    );
  }

  Future<void> _share(AppLocalizations l10n, GameDetail game) {
    return SharePlus.instance.share(
      ShareParams(
        text: l10n.gameShareText(game.title, AppConfig.gameShareUrl(game.slug)),
        subject: game.title,
      ),
    );
  }
}

class _CenteredWithBack extends StatelessWidget {
  const _CenteredWithBack({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        AppBar(),
        Expanded(child: child),
      ],
    );
  }
}

class _Hero extends StatelessWidget {
  const _Hero({required this.game, required this.onPlay});

  final GameDetail game;
  final VoidCallback? onPlay;

  @override
  Widget build(BuildContext context) {
    final play = onPlay;

    return Stack(
      fit: StackFit.expand,
      children: <Widget>[
        GameImage(
          url: game.heroImageUrl,
          logicalWidth: MediaQuery.sizeOf(context).width,
        ),
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: <Color>[
                Color(0x990B0B10),
                Colors.transparent,
                AppColors.night,
              ],
              stops: <double>[0, 0.4, 1],
            ),
          ),
        ),
        if (play != null)
          Center(
            child: Semantics(
              button: true,
              label: context.l10n.gamePlaySemantics(game.title),
              child: GestureDetector(
                onTap: play,
                child: Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.black.withValues(alpha: 0.45),
                    border: Border.all(color: AppColors.gold, width: 2.5),
                  ),
                  child: const Icon(
                    Icons.play_arrow_rounded,
                    size: 44,
                    color: AppColors.gold,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _RatingRow extends ConsumerWidget {
  const _RatingRow({required this.slug, this.developer});

  final String slug;
  final String? developer;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reviews = ref.watch(gameReviewsProvider(slug)).value;
    final style = Theme.of(
      context,
    ).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary);
    final dev = developer;
    final l10n = context.l10n;

    return Row(
      children: <Widget>[
        const Icon(Icons.star_rounded, color: AppColors.gold, size: 20),
        const SizedBox(width: 4),
        Text(
          reviews == null || reviews.reviewCount == 0
              ? l10n.gameNoRatings
              : reviews.averageRating.toStringAsFixed(1),
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
        if (reviews != null && reviews.reviewCount > 0) ...<Widget>[
          const SizedBox(width: 4),
          Text(l10n.gameReviewCount(reviews.reviewCount), style: style),
        ],
        if (dev != null && dev.isNotEmpty) ...<Widget>[
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              l10n.gameByDeveloper(dev),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: style,
            ),
          ),
        ],
      ],
    );
  }
}

class _SquareAction extends StatelessWidget {
  const _SquareAction({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        color: AppColors.surfaceAlt,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.line),
      ),
      child: Center(child: child),
    );
  }
}

class _TextSection extends StatelessWidget {
  const _TextSection({required this.text, required this.empty});

  final String? text;
  final String empty;

  @override
  Widget build(BuildContext context) {
    final value = text?.trim() ?? '';

    return Text(
      value.isEmpty ? empty : value,
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
        color: AppColors.textSecondary,
        height: 1.55,
      ),
    );
  }
}

class _ReviewsSection extends ConsumerWidget {
  const _ReviewsSection({required this.slug});

  final String slug;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reviews = ref.watch(gameReviewsProvider(slug));

    return reviews.when(
      data: (ReviewSummary data) {
        if (data.items.isEmpty) {
          return _TextSection(text: null, empty: context.l10n.gameNoReviews);
        }

        return Column(
          children: <Widget>[
            for (final review in data.items.take(10))
              Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: _ReviewTile(review: review),
              ),
          ],
        );
      },
      loading: () => const LoadingView(),
      error: (Object error, StackTrace stackTrace) => ErrorView(
        error: error,
        onRetry: () => ref.invalidate(gameReviewsProvider(slug)),
      ),
    );
  }
}

class _ReviewTile extends StatelessWidget {
  const _ReviewTile({required this.review});

  final GameReview review;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              GdAvatar(
                name: review.author.name,
                imageUrl: review.author.avatarUrl,
                size: 32,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  review.author.name,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
              for (var i = 0; i < 5; i++)
                Icon(
                  i < review.rating
                      ? Icons.star_rounded
                      : Icons.star_outline_rounded,
                  size: 16,
                  color: AppColors.gold,
                ),
            ],
          ),
          if (review.content.isNotEmpty) ...<Widget>[
            const SizedBox(height: 8),
            Text(
              review.content,
              style: textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
          const SizedBox(height: 6),
          Text(
            formatTimeAgo(context.l10n, review.createdAt),
            style: textTheme.labelSmall?.copyWith(color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }
}

class _SimilarShelf extends ConsumerWidget {
  const _SimilarShelf({required this.gameId});

  final String gameId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final games = ref.watch(similarGamesProvider(gameId)).value;
    if (games == null || games.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: 28),
      child: GameShelf(title: context.l10n.gameSimilarGames, games: games),
    );
  }
}

class _SimilarGrid extends ConsumerWidget {
  const _SimilarGrid({required this.gameId});

  final String gameId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final games = ref.watch(similarGamesProvider(gameId));

    return games.when(
      data: (List<GameSummary> items) {
        if (items.isEmpty) {
          return _TextSection(text: null, empty: context.l10n.gameNoSimilar);
        }

        return LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            final width = (constraints.maxWidth - 12) / 2;
            return Wrap(
              spacing: 12,
              runSpacing: 14,
              children: <Widget>[
                for (final game in items) GameCard(game: game, width: width),
              ],
            );
          },
        );
      },
      loading: () => const LoadingView(),
      error: (Object error, StackTrace stackTrace) => ErrorView(
        error: error,
        onRetry: () => ref.invalidate(similarGamesProvider(gameId)),
      ),
    );
  }
}
