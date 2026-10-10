import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/app_routes.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/l10n/locale_resolution.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/widgets/hex_badge.dart';
import '../../../shared/widgets/section_header.dart';
import '../../../shared/widgets/stat_tile.dart';
import '../../../shared/widgets/state_views.dart';
import '../../../shared/widgets/xp_progress_bar.dart';
import '../../achievements/presentation/achievements_providers.dart';
import '../domain/progress_models.dart';
import 'progress_providers.dart';

class ProgressScreen extends ConsumerWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = ref.watch(myProgressProvider);
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.profileMyProgress)),
      body: progress.when(
        skipLoadingOnRefresh: true,
        data: (UserProgress? data) {
          if (data == null) {
            return SignInRequiredView(
              icon: Icons.trending_up_rounded,
              title: l10n.progressSignInTitle,
              message: l10n.progressSignInMessage,
            );
          }

          return RefreshIndicator(
            onRefresh: () {
              ref.invalidate(recentXpProvider);
              return ref.refresh(myProgressProvider.future);
            },
            child: _ProgressContent(data: data),
          );
        },
        loading: () => const LoadingView(),
        error: (Object error, StackTrace stackTrace) => ErrorView(
          error: error,
          onRetry: () => ref.invalidate(myProgressProvider),
        ),
      ),
    );
  }
}

class _ProgressContent extends ConsumerWidget {
  const _ProgressContent({required this.data});

  final UserProgress data;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    final level = data.level;
    final achievements = ref.watch(myAchievementsProvider).value;
    final xp = ref.watch(recentXpProvider);
    final l10n = context.l10n;

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
      children: <Widget>[
        Center(
          child: HexBadge(
            color: AppColors.gold,
            size: 120,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  l10n.progressLevelBadge,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: AppColors.onGold,
                  ),
                ),
                Text(
                  '${level.level}',
                  style: const TextStyle(
                    fontSize: 38,
                    height: 1,
                    fontWeight: FontWeight.w900,
                    color: AppColors.onGold,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        if (level.title.isNotEmpty)
          Text(
            level.title,
            textAlign: TextAlign.center,
            style: textTheme.titleMedium?.copyWith(
              color: AppColors.gold,
              fontWeight: FontWeight.w800,
            ),
          ),
        const SizedBox(height: 16),
        XpProgressBar(value: level.progress, height: 10),
        const SizedBox(height: 8),
        Row(
          children: <Widget>[
            Text(
              level.isMaxLevel
                  ? l10n.progressMaxLevelReached
                  : l10n.commonXpProgress(
                      level.currentLevelXp,
                      level.nextLevelXp,
                    ),
              style: textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const Spacer(),
            Text(
              l10n.progressTotalXp(level.totalXp),
              style: textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Row(
          children: <Widget>[
            Expanded(
              child: StatTile(
                icon: Icons.local_fire_department_rounded,
                color: AppColors.orange,
                value: l10n.progressStreakDays(data.stats.currentStreak),
                label: l10n.progressCurrentStreak,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: StatTile(
                icon: Icons.sports_esports_rounded,
                color: AppColors.blue,
                value: formatCompact(l10n, data.stats.uniqueGamesPlayed),
                label: l10n.progressGamesPlayedLabel,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: GestureDetector(
                onTap: () => context.push(AppRoutes.achievements),
                child: StatTile(
                  icon: Icons.emoji_events_rounded,
                  color: AppColors.gold,
                  value: achievements == null
                      ? '—'
                      : '${achievements.userUnlocked}',
                  label: l10n.profileAchievements,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 28),
        SectionHeader(title: l10n.progressRecentXp, padding: EdgeInsets.zero),
        const SizedBox(height: 12),
        xp.when(
          data: (List<XpTransaction> items) {
            if (items.isEmpty) {
              return Text(
                l10n.progressNoXp,
                style: textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
              );
            }
            return Column(
              children: <Widget>[for (final item in items) _XpRow(item: item)],
            );
          },
          loading: () => const LoadingView(),
          error: (Object error, StackTrace stackTrace) => ErrorView(
            error: error,
            onRetry: () => ref.invalidate(recentXpProvider),
          ),
        ),
      ],
    );
  }
}

class _XpRow extends StatelessWidget {
  const _XpRow({required this.item});

  final XpTransaction item;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final l10n = context.l10n;
    final positive = item.xpAmount >= 0;
    final label = item.description.isNotEmpty
        ? item.description
        : _humanize(l10n, item.ruleCode);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: <Widget>[
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.gold.withValues(alpha: 0.14),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.bolt_rounded,
              color: AppColors.gold,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                Text(
                  formatTimeAgo(l10n, item.createdAt),
                  style: textTheme.labelSmall?.copyWith(
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
          Text(
            positive
                ? l10n.commonXpReward(item.xpAmount)
                : l10n.commonXpAmount(item.xpAmount),
            style: TextStyle(
              color: positive ? AppColors.gold : AppColors.danger,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  static String _humanize(AppLocalizations l10n, String code) {
    if (code.isEmpty) return l10n.progressXpEarned;
    final words = code.toLowerCase().split('_');
    return words
        .map((String w) => w.isEmpty ? w : w[0].toUpperCase() + w.substring(1))
        .join(' ');
  }
}
