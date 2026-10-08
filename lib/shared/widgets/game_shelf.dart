import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../models/game_summary.dart';
import 'game_card.dart';
import 'section_header.dart';

const double _shelfCardWidth = 148;
const double _shelfSpacing = 12;
const double _shelfHeight = 160;
const EdgeInsets _shelfPadding = EdgeInsets.symmetric(horizontal: 20);

class GameShelf extends StatelessWidget {
  const GameShelf({
    required this.title,
    required this.games,
    this.onSeeAll,
    this.onGameTap,
    super.key,
  });

  final String title;
  final List<GameSummary> games;
  final VoidCallback? onSeeAll;
  final ValueChanged<GameSummary>? onGameTap;

  @override
  Widget build(BuildContext context) {
    if (games.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        SectionHeader(title: title, onSeeAll: onSeeAll),
        const SizedBox(height: 12),
        SizedBox(
          height: _shelfHeight,
          child: ListView.separated(
            padding: _shelfPadding,
            scrollDirection: Axis.horizontal,
            itemCount: games.length,
            separatorBuilder: (BuildContext context, int index) =>
                const SizedBox(width: _shelfSpacing),
            itemBuilder: (BuildContext context, int index) {
              final game = games[index];
              final onTap = onGameTap;

              return GameCard(
                game: game,
                width: _shelfCardWidth,
                onTap: onTap == null ? null : () => onTap(game),
              );
            },
          ),
        ),
      ],
    );
  }
}

class GameShelfSkeleton extends StatelessWidget {
  const GameShelfSkeleton({super.key});

  static const int _placeholderCount = 4;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const Padding(
          padding: _shelfPadding,
          child: SkeletonBox(width: 140, height: 20),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: _shelfHeight,
          child: ListView.separated(
            padding: _shelfPadding,
            scrollDirection: Axis.horizontal,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _placeholderCount,
            separatorBuilder: (BuildContext context, int index) =>
                const SizedBox(width: _shelfSpacing),
            itemBuilder: (BuildContext context, int index) {
              return const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  SkeletonBox(
                    width: _shelfCardWidth,
                    height: _shelfCardWidth / GameCard.imageAspectRatio,
                    radius: 18,
                  ),
                  SizedBox(height: 8),
                  SkeletonBox(width: 110, height: 14),
                  SizedBox(height: 6),
                  SkeletonBox(width: 70, height: 12),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}

class SkeletonBox extends StatelessWidget {
  const SkeletonBox({
    required this.width,
    required this.height,
    this.radius = 8,
    super.key,
  });

  final double width;
  final double height;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.surfaceAlt,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}
