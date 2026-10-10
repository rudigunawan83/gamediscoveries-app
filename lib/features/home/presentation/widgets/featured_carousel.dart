import 'package:flutter/material.dart';

import 'package:go_router/go_router.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/l10n/locale_resolution.dart';
import '../../../../shared/models/game_summary.dart';
import '../../../../shared/widgets/game_card.dart';

const double _carouselHeight = 200;
const double _viewportFraction = 0.88;
const int _maxFeaturedItems = 8;

class FeaturedCarousel extends StatefulWidget {
  const FeaturedCarousel({required this.games, this.onGameTap, super.key});

  final List<GameSummary> games;
  final ValueChanged<GameSummary>? onGameTap;

  @override
  State<FeaturedCarousel> createState() => _FeaturedCarouselState();
}

class _FeaturedCarouselState extends State<FeaturedCarousel> {
  final PageController _controller = PageController(
    viewportFraction: _viewportFraction,
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.games.isEmpty) {
      return const SizedBox.shrink();
    }

    final items = widget.games.take(_maxFeaturedItems).toList(growable: false);
    final cardWidth = MediaQuery.sizeOf(context).width * _viewportFraction;

    return SizedBox(
      height: _carouselHeight,
      child: PageView.builder(
        controller: _controller,
        padEnds: false,
        itemCount: items.length,
        itemBuilder: (BuildContext context, int index) {
          final game = items[index];
          final onTap = widget.onGameTap;

          return Padding(
            padding: EdgeInsets.only(
              left: index == 0 ? 20 : 6,
              right: index == items.length - 1 ? 20 : 6,
            ),
            child: _FeaturedCard(
              game: game,
              width: cardWidth,
              onTap: onTap == null
                  ? () => context.push(AppRoutes.game(game.slug))
                  : () => onTap(game),
            ),
          );
        },
      ),
    );
  }
}

class _FeaturedCard extends StatelessWidget {
  const _FeaturedCard({required this.game, required this.width, this.onTap});

  final GameSummary game;
  final double width;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final category = game.category;

    return Semantics(
      button: onTap != null,
      label: context.l10n.homeFeaturedSemantics(game.title),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Material(
          color: AppColors.surface,
          child: InkWell(
            onTap: onTap,
            child: Stack(
              fit: StackFit.expand,
              children: <Widget>[
                GameImage(url: game.heroImageUrl, logicalWidth: width),
                const DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: <Color>[Colors.transparent, Color(0xE6090910)],
                      stops: <double>[0.35, 1],
                    ),
                  ),
                ),
                Positioned(
                  left: 16,
                  right: 16,
                  bottom: 16,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          gradient: AppColors.goldGradient,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          context.l10n.homeFeaturedBadge,
                          style: textTheme.labelSmall?.copyWith(
                            color: AppColors.onGold,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        game.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      if (category != null && category.isNotEmpty)
                        Text(
                          category,
                          style: textTheme.bodySmall?.copyWith(
                            color: Colors.white70,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
