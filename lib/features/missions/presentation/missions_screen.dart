import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/widgets/icon_tile.dart';
import '../../../shared/widgets/pill_tabs.dart';
import '../../../shared/widgets/state_views.dart';
import '../../../shared/widgets/xp_progress_bar.dart';
import '../domain/mission_models.dart';
import 'missions_providers.dart';

class MissionsScreen extends ConsumerStatefulWidget {
  const MissionsScreen({super.key});

  @override
  ConsumerState<MissionsScreen> createState() => _MissionsScreenState();
}

class _MissionsScreenState extends ConsumerState<MissionsScreen> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    final missions = ref.watch(myMissionsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Missions'), centerTitle: false),
      body: missions.when(
        skipLoadingOnRefresh: true,
        data: (MyMissions? data) {
          if (data == null) {
            return const SignInRequiredView(
              icon: Icons.flag_rounded,
              title: 'Daily & weekly missions',
              message:
                  'Sign in to get missions, earn bonus XP and keep your '
                  'streak alive.',
            );
          }
          return _content(data);
        },
        loading: () => const LoadingView(),
        error: (Object error, StackTrace stackTrace) => ErrorView(
          error: error,
          onRetry: () => ref.invalidate(myMissionsProvider),
        ),
      ),
    );
  }

  Widget _content(MyMissions data) {
    final daily = _tab == 0;
    final items = daily ? data.daily : data.weekly;
    final expiresAt = daily ? data.dailyExpiresAt : data.weeklyExpiresAt;

    return RefreshIndicator(
      onRefresh: () => ref.refresh(myMissionsProvider.future),
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(bottom: 32),
        children: <Widget>[
          PillTabs(
            labels: const <String>['Daily', 'Weekly'],
            selectedIndex: _tab,
            onChanged: (int i) => setState(() => _tab = i),
          ),
          const SizedBox(height: 16),
          _MissionsBanner(daily: daily, missions: items, expiresAt: expiresAt),
          const SizedBox(height: 16),
          if (items.isEmpty)
            const MessageView(
              icon: Icons.hourglass_empty_rounded,
              message: 'No missions right now. New ones arrive soon.',
            )
          else
            for (final mission in items)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                child: MissionCard(mission: mission),
              ),
        ],
      ),
    );
  }
}

class _MissionsBanner extends StatelessWidget {
  const _MissionsBanner({
    required this.daily,
    required this.missions,
    required this.expiresAt,
  });

  final bool daily;
  final List<Mission> missions;
  final DateTime? expiresAt;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final done = missions.where((Mission m) => m.isCompleted).length;
    final bonus = missions.fold<int>(
      0,
      (int sum, Mission m) => sum + m.rewardXp,
    );
    final remaining = formatRemaining(expiresAt);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          gradient: const LinearGradient(
            colors: <Color>[Color(0xFF3A2A0A), Color(0xFF1C1626)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          border: Border.all(color: AppColors.gold.withValues(alpha: 0.35)),
        ),
        child: Row(
          children: <Widget>[
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    daily
                        ? 'Complete Daily Missions'
                        : 'Complete Weekly Missions',
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Earn up to ${formatGrouped(bonus)} XP'
                    '${remaining.isEmpty ? '' : ' · $remaining'}',
                    style: textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: XpProgressBar(
                          value: missions.isEmpty ? 0 : done / missions.length,
                          semanticLabel: 'Missions completed',
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        '$done/${missions.length}',
                        style: const TextStyle(
                          color: AppColors.gold,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 14),
            const Icon(
              Icons.card_giftcard_rounded,
              color: AppColors.gold,
              size: 56,
            ),
          ],
        ),
      ),
    );
  }
}

class MissionCard extends StatelessWidget {
  const MissionCard({required this.mission, super.key});

  final Mission mission;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final (icon, color) = missionVisual(mission.requirementType);
    final completed = mission.isCompleted;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: completed
              ? AppColors.success.withValues(alpha: 0.4)
              : AppColors.line,
        ),
      ),
      child: Row(
        children: <Widget>[
          IconTile(icon: icon, color: color),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  mission.title,
                  style: textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                if (mission.description.isNotEmpty) ...<Widget>[
                  const SizedBox(height: 2),
                  Text(
                    mission.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
                const SizedBox(height: 8),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: XpProgressBar(
                        value: mission.ratio.clamp(0, 1).toDouble(),
                        height: 6,
                        color: completed ? AppColors.success : null,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${mission.progress.clamp(0, mission.target)}'
                      '/${mission.target}',
                      style: textTheme.labelSmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          completed
              ? const Icon(
                  Icons.check_circle_rounded,
                  color: AppColors.success,
                  size: 28,
                )
              : Text(
                  '+${formatGrouped(mission.rewardXp)} XP',
                  style: const TextStyle(
                    color: AppColors.gold,
                    fontWeight: FontWeight.w900,
                    fontSize: 13,
                  ),
                ),
        ],
      ),
    );
  }
}

(IconData, Color) missionVisual(String requirementType) {
  final t = requirementType.toUpperCase();
  if (t.contains('FAVORITE')) return (Icons.favorite_rounded, AppColors.pink);
  if (t.contains('REVIEW') || t.contains('RATE')) {
    return (Icons.star_rounded, AppColors.gold);
  }
  if (t.contains('COMMENT') || t.contains('POST') || t.contains('COMMUNITY')) {
    return (Icons.forum_rounded, AppColors.teal);
  }
  if (t.contains('STREAK') || t.contains('LOGIN')) {
    return (Icons.local_fire_department_rounded, AppColors.orange);
  }
  if (t.contains('UNIQUE') || t.contains('DISCOVER') || t.contains('NEW')) {
    return (Icons.explore_rounded, AppColors.purple);
  }
  if (t.contains('MINUTE') || t.contains('TIME') || t.contains('DURATION')) {
    return (Icons.timer_rounded, AppColors.blue);
  }
  if (t.contains('SHARE')) return (Icons.share_rounded, AppColors.success);
  return (Icons.sports_esports_rounded, AppColors.blue);
}
