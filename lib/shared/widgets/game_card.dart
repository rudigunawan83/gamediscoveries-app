import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/router/app_routes.dart';
import '../../app/theme/app_colors.dart';
import '../models/game_summary.dart';

class GameCard extends StatelessWidget {
  const GameCard({required this.game, this.width = 148, this.onTap, super.key});

  static const double imageAspectRatio = 4 / 3;

  final GameSummary game;
  final double width;

  /// Defaults to opening the game detail page.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final category = game.category;

    return Semantics(
      button: true,
      label: game.title,
      child: SizedBox(
        width: width,
        child: InkWell(
          onTap: onTap ?? () => context.push(AppRoutes.game(game.slug)),
          borderRadius: BorderRadius.circular(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: AspectRatio(
                  aspectRatio: imageAspectRatio,
                  child: GameImage(url: game.cardImageUrl, logicalWidth: width),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                game.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (category != null && category.isNotEmpty) ...<Widget>[
                const SizedBox(height: 2),
                Text(
                  category,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class GameImage extends StatelessWidget {
  const GameImage({required this.url, required this.logicalWidth, super.key});

  final String? url;
  final double logicalWidth;

  @override
  Widget build(BuildContext context) {
    final imageUrl = url;
    if (imageUrl == null) {
      return const _ImagePlaceholder(icon: Icons.sports_esports_rounded);
    }

    final cacheWidth = (logicalWidth * MediaQuery.devicePixelRatioOf(context))
        .round();

    return CachedNetworkImage(
      imageUrl: imageUrl,
      fit: BoxFit.cover,
      memCacheWidth: cacheWidth,
      fadeInDuration: const Duration(milliseconds: 180),
      placeholder: (BuildContext context, String url) =>
          const _ImagePlaceholder(),
      errorWidget: (BuildContext context, String url, Object error) =>
          const _ImagePlaceholder(icon: Icons.broken_image_rounded),
    );
  }
}

class _ImagePlaceholder extends StatelessWidget {
  const _ImagePlaceholder({this.icon});

  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final placeholderIcon = icon;

    return ColoredBox(
      color: AppColors.surfaceAlt,
      child: placeholderIcon == null
          ? null
          : Center(child: Icon(placeholderIcon, color: Colors.white24)),
    );
  }
}
