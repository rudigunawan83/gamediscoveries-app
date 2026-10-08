import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/widgets/hex_badge.dart';
import '../../../shared/widgets/pill_tabs.dart';
import '../../../shared/widgets/state_views.dart';
import '../../../shared/widgets/xp_progress_bar.dart';
import '../domain/achievement_models.dart';
import 'achievements_providers.dart';

class AchievementsScreen extends ConsumerStatefulWidget {
  const AchievementsScreen({super.key});

  @override
  ConsumerState<AchievementsScreen> createState() => _AchievementsScreenState();
}

class _AchievementsScreenState extends ConsumerState<AchievementsScreen> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    final achievements = ref.watch(myAchievementsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Achievements')),
      body: achievements.when(
        skipLoadingOnRefresh: true,
        data: (AchievementList? data) {
          if (data == null) {
            return const SignInRequiredView(
              icon: Icons.emoji_events_rounded,
              title: 'Unlock achievements',
              message: 'Sign in to collect badges as you play and explore.',
            );
          }
          return _content(data);
        },
        loading: () => const LoadingView(),
        error: (Object error, StackTrace stackTrace) => ErrorView(
          error: error,
          onRetry: () => ref.invalidate(myAchievementsProvider),
        ),
      ),
    );
  }

  Widget _content(AchievementList data) {
    final categories = data.categories;
    final tab = _tab > categories.length ? 0 : _tab;
    final items = tab == 0
        ? data.items
        : data.items
              .where((Achievement a) => a.category == categories[tab - 1])
              .toList(growable: false);
    final textTheme = Theme.of(context).textTheme;
    final total = data.totalDefinitions;

    return RefreshIndicator(
      onRefresh: () => ref.refresh(myAchievementsProvider.future),
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: <Widget>[
          SliverToBoxAdapter(
            child: PillTabs(
              expanded: false,
              labels: <String>['All', ...categories.map(humanizeCode)],
              selectedIndex: tab,
              onChanged: (int i) => setState(() => _tab = i),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text.rich(
                    TextSpan(
                      children: <TextSpan>[
                        TextSpan(
                          text: '${data.userUnlocked}',
                          style: const TextStyle(color: AppColors.gold),
                        ),
                        TextSpan(text: ' / $total Unlocked'),
                      ],
                    ),
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 10),
                  XpProgressBar(
                    value: total == 0 ? 0 : data.userUnlocked / total,
                    semanticLabel: 'Achievements unlocked',
                  ),
                ],
              ),
            ),
          ),
          if (items.isEmpty)
            const SliverFillRemaining(
              hasScrollBody: false,
              child: MessageView(
                icon: Icons.emoji_events_outlined,
                message: 'No achievements in this category yet.',
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
              sliver: SliverGrid.builder(
                itemCount: items.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 12,
                  childAspectRatio: 0.72,
                ),
                itemBuilder: (BuildContext context, int index) =>
                    _AchievementTile(achievement: items[index]),
              ),
            ),
        ],
      ),
    );
  }
}

class _AchievementTile extends StatelessWidget {
  const _AchievementTile({required this.achievement});

  final Achievement achievement;

  @override
  Widget build(BuildContext context) {
    final a = achievement;
    final hidden = a.hidden;

    return Semantics(
      button: true,
      label: hidden ? 'Secret achievement' : a.title,
      excludeSemantics: true,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _showDetails(context, a),
        child: Column(
          children: <Widget>[
            HexBadge(
              color: achievementColor(a.difficulty),
              icon: achievementIcon(a.category),
              size: 76,
              locked: !a.isUnlocked,
            ),
            const SizedBox(height: 8),
            Text(
              hidden ? '???' : a.title,
              maxLines: 2,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: a.isUnlocked
                    ? AppColors.textPrimary
                    : AppColors.textSecondary,
              ),
            ),
            if (!a.isUnlocked && !hidden && a.targetValue > 0) ...<Widget>[
              const SizedBox(height: 6),
              XpProgressBar(
                value: (a.progressValue / a.targetValue).clamp(0, 1).toDouble(),
                height: 4,
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showDetails(BuildContext context, Achievement a) {
    final hidden = a.hidden;

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.surface,
      showDragHandle: true,
      builder: (BuildContext context) {
        final textTheme = Theme.of(context).textTheme;

        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                HexBadge(
                  color: achievementColor(a.difficulty),
                  icon: achievementIcon(a.category),
                  size: 96,
                  locked: !a.isUnlocked,
                ),
                const SizedBox(height: 14),
                Text(
                  hidden ? 'Secret Achievement' : a.title,
                  textAlign: TextAlign.center,
                  style: textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  hidden ? 'Keep playing to discover this one.' : a.description,
                  textAlign: TextAlign.center,
                  style: textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  a.isUnlocked
                      ? 'Unlocked ${formatTimeAgo(a.unlockedAt)}'
                      : hidden
                      ? 'Locked'
                      : 'Progress ${a.progressValue}/${a.targetValue}',
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                if (a.rewardXp > 0) ...<Widget>[
                  const SizedBox(height: 4),
                  Text(
                    '+${formatGrouped(a.rewardXp)} XP',
                    style: const TextStyle(
                      color: AppColors.gold,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

Color achievementColor(String difficulty) {
  return switch (difficulty.toUpperCase()) {
    'BRONZE' || 'EASY' || 'COMMON' => AppColors.bronze,
    'SILVER' || 'MEDIUM' || 'UNCOMMON' => AppColors.silver,
    'GOLD' || 'HARD' || 'RARE' => AppColors.gold,
    'PLATINUM' || 'EPIC' => AppColors.teal,
    'LEGENDARY' || 'DIAMOND' => AppColors.purple,
    _ => AppColors.blue,
  };
}

IconData achievementIcon(String category) {
  final c = category.toUpperCase();
  if (c.contains('SOCIAL') || c.contains('COMMUNITY')) {
    return Icons.groups_rounded;
  }
  if (c.contains('EXPLOR') || c.contains('DISCOVER')) {
    return Icons.explore_rounded;
  }
  if (c.contains('STREAK')) return Icons.local_fire_department_rounded;
  if (c.contains('COLLECT') || c.contains('FAVORITE')) {
    return Icons.favorite_rounded;
  }
  if (c.contains('LEVEL') || c.contains('XP')) return Icons.bolt_rounded;
  if (c.contains('PLAY') || c.contains('GAME')) {
    return Icons.sports_esports_rounded;
  }
  return Icons.emoji_events_rounded;
}

String humanizeCode(String code) {
  return code
      .toLowerCase()
      .split(RegExp('[_\\s]+'))
      .where((String w) => w.isNotEmpty)
      .map((String w) => w[0].toUpperCase() + w.substring(1))
      .join(' ');
}
