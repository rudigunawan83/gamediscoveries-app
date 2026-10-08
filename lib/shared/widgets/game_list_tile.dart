import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/router/app_routes.dart';
import '../../app/theme/app_colors.dart';
import '../models/game_summary.dart';
import 'game_card.dart';

const double _thumbWidth = 84;

class GameListTile extends StatelessWidget {
  const GameListTile({
    required this.game,
    this.subtitle,
    this.trailing,
    this.onTap,
    super.key,
  });

  final GameSummary game;

  /// Defaults to the game category.
  final String? subtitle;
  final Widget? trailing;

  /// Defaults to opening the game detail page.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final caption = subtitle ?? game.category;
    final trailingWidget = trailing;

    return Material(
      color: AppColors.card,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap ?? () => context.push(AppRoutes.game(game.slug)),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            children: <Widget>[
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: SizedBox(
                  width: _thumbWidth,
                  height: _thumbWidth * 0.75,
                  child: GameImage(
                    url: game.cardImageUrl,
                    logicalWidth: _thumbWidth,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      game.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    if (caption != null && caption.isNotEmpty) ...<Widget>[
                      const SizedBox(height: 3),
                      Text(
                        caption,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                    if (game.mobileReady) ...<Widget>[
                      const SizedBox(height: 6),
                      const _Badge(label: 'Mobile', color: AppColors.success),
                    ],
                  ],
                ),
              ),
              ?trailingWidget,
            ],
          ),
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
