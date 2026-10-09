import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/app_routes.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/widgets/game_card.dart';
import '../../../shared/widgets/game_shelf.dart';
import '../../../shared/widgets/section_header.dart';
import '../data/library_repository.dart';
import 'library_providers.dart';

/// The last game played on any platform with one-tap Continue, followed by
/// the rest of the history. Refreshes when the app returns to the foreground
/// so games played on the web show up.
class ContinuePlayingSection extends ConsumerStatefulWidget {
  const ContinuePlayingSection({this.trailingGap = 0, super.key});

  /// Space added below the section, only when it is visible.
  final double trailingGap;

  @override
  ConsumerState<ContinuePlayingSection> createState() =>
      _ContinuePlayingSectionState();
}

class _ContinuePlayingSectionState
    extends ConsumerState<ContinuePlayingSection> {
  late final AppLifecycleListener _lifecycle;

  @override
  void initState() {
    super.initState();
    _lifecycle = AppLifecycleListener(
      onResume: () => ref.invalidate(playHistoryProvider),
    );
  }

  @override
  void dispose() {
    _lifecycle.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final history = ref.watch(playHistoryProvider).value;
    if (history == null || history.isEmpty) return const SizedBox.shrink();

    final seen = <String>{};
    final entries = <HistoryEntry>[
      for (final e in history)
        if (seen.add(e.game.id)) e,
    ];
    final rest = entries.skip(1).map((HistoryEntry e) => e.game).toList();

    return Padding(
      padding: EdgeInsets.only(bottom: widget.trailingGap),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          SectionHeader(
            title: 'Continue Playing',
            onSeeAll: () => context.push(AppRoutes.history),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: ContinuePlayingCard(entry: entries.first),
          ),
          if (rest.isNotEmpty) ...<Widget>[
            const SizedBox(height: 20),
            GameShelf(title: 'Recently Played', games: rest),
          ],
        ],
      ),
    );
  }
}

/// "Last played on Web · 2h ago · 1h 5m total" with a Continue button that
/// opens the player directly.
class ContinuePlayingCard extends StatelessWidget {
  const ContinuePlayingCard({required this.entry, super.key});

  final HistoryEntry entry;

  static String details(HistoryEntry entry) {
    final platform = entry.platformLabel;
    final parts = <String>[
      if (platform != null) 'on $platform',
      formatTimeAgo(entry.playedAt),
      if (entry.playTimeSeconds > 0)
        '${formatPlayTime(entry.playTimeSeconds)} total',
    ].where((String p) => p.isNotEmpty);
    return parts.join(' · ');
  }

  static IconData platformIcon(String? platform) =>
      switch (platform?.toUpperCase()) {
        'WEB' => Icons.language_rounded,
        'ANDROID' => Icons.android_rounded,
        'IOS' => Icons.phone_iphone_rounded,
        _ => Icons.history_rounded,
      };

  @override
  Widget build(BuildContext context) {
    final game = entry.game;
    final textTheme = Theme.of(context).textTheme;
    final radius = BorderRadius.circular(20);
    void play() => context.push(AppRoutes.gamePlay(game.slug));

    return Material(
      color: AppColors.card,
      borderRadius: radius,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.push(AppRoutes.game(game.slug)),
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: radius,
            border: Border.all(color: AppColors.gold.withValues(alpha: 0.35)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: <Widget>[
                ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: SizedBox.square(
                    dimension: 76,
                    child: GameImage(url: game.cardImageUrl, logicalWidth: 76),
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
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: <Widget>[
                          Icon(
                            platformIcon(entry.lastPlatform),
                            size: 14,
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              details(entry),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: textTheme.bodySmall?.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                FilledButton.icon(
                  onPressed: play,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.gold,
                    foregroundColor: AppColors.onGold,
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    visualDensity: VisualDensity.compact,
                  ),
                  icon: const Icon(Icons.play_arrow_rounded),
                  label: const Text(
                    'Continue',
                    style: TextStyle(fontWeight: FontWeight.w800),
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
