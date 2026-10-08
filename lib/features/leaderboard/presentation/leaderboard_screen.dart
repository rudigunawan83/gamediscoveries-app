import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/app_routes.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/widgets/gd_avatar.dart';
import '../../../shared/widgets/pill_tabs.dart';
import '../../../shared/widgets/state_views.dart';
import '../../auth/presentation/providers/auth_session_controller.dart';
import '../domain/leaderboard_models.dart';
import 'leaderboard_providers.dart';

class LeaderboardScreen extends ConsumerStatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  ConsumerState<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends ConsumerState<LeaderboardScreen> {
  LeaderboardScope _scope = LeaderboardScope.global;

  @override
  Widget build(BuildContext context) {
    final detail = ref.watch(leaderboardDetailProvider(_scope));
    final signedIn = ref.watch(isSignedInProvider).value ?? false;

    return Scaffold(
      appBar: AppBar(title: const Text('Leaderboard')),
      body: Column(
        children: <Widget>[
          PillTabs(
            labels: <String>[for (final s in LeaderboardScope.values) s.label],
            selectedIndex: _scope.index,
            onChanged: (int i) =>
                setState(() => _scope = LeaderboardScope.values[i]),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: detail.when(
              skipLoadingOnRefresh: true,
              data: (LeaderboardDetail? data) {
                if (data == null || data.items.isEmpty) {
                  return const MessageView(
                    icon: Icons.leaderboard_rounded,
                    title: 'No rankings yet',
                    message: 'Play games to be the first on the board!',
                  );
                }
                return RefreshIndicator(
                  onRefresh: () =>
                      ref.refresh(leaderboardDetailProvider(_scope).future),
                  child: _Board(data: data),
                );
              },
              loading: () => const LoadingView(),
              error: (Object error, StackTrace stackTrace) => ErrorView(
                error: error,
                onRetry: () =>
                    ref.invalidate(leaderboardDetailProvider(_scope)),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _MyRankBar(me: detail.value?.me, signedIn: signedIn),
    );
  }
}

class _Board extends StatelessWidget {
  const _Board({required this.data});

  final LeaderboardDetail data;

  @override
  Widget build(BuildContext context) {
    final podium = data.items.take(3).toList(growable: false);
    final rest = data.items.skip(3).toList(growable: false);
    final remaining = formatRemaining(data.periodEndsAt);

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      children: <Widget>[
        if (remaining.isNotEmpty)
          Center(
            child: Text(
              'Season ends in ${remaining.replaceAll(' left', '')}',
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
              ),
            ),
          ),
        const SizedBox(height: 12),
        _Podium(entries: podium),
        const SizedBox(height: 20),
        for (final entry in rest)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _RankRow(
              entry: entry,
              highlighted: entry.userId == data.me?.userId,
            ),
          ),
      ],
    );
  }
}

class _Podium extends StatelessWidget {
  const _Podium({required this.entries});

  final List<LeaderboardEntry> entries;

  @override
  Widget build(BuildContext context) {
    LeaderboardEntry? at(int i) => i < entries.length ? entries[i] : null;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: <Widget>[
        Expanded(child: _PodiumSpot(entry: at(1), place: 2, height: 96)),
        Expanded(child: _PodiumSpot(entry: at(0), place: 1, height: 128)),
        Expanded(child: _PodiumSpot(entry: at(2), place: 3, height: 78)),
      ],
    );
  }
}

class _PodiumSpot extends StatelessWidget {
  const _PodiumSpot({
    required this.entry,
    required this.place,
    required this.height,
  });

  final LeaderboardEntry? entry;
  final int place;
  final double height;

  Color get _color => switch (place) {
    1 => AppColors.gold,
    2 => AppColors.silver,
    _ => AppColors.bronze,
  };

  @override
  Widget build(BuildContext context) {
    final e = entry;
    if (e == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Column(
        children: <Widget>[
          if (place == 1)
            const Icon(
              Icons.workspace_premium_rounded,
              color: AppColors.gold,
              size: 30,
            ),
          GdAvatar(
            name: e.name,
            imageUrl: e.avatarUrl,
            size: place == 1 ? 72 : 58,
            ringColor: _color,
          ),
          const SizedBox(height: 6),
          Text(
            e.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
          ),
          Text(
            '${formatCompact(e.score)} XP',
            style: TextStyle(
              color: _color,
              fontWeight: FontWeight.w800,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            height: height,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: <Color>[
                  _color.withValues(alpha: 0.55),
                  _color.withValues(alpha: 0.08),
                ],
              ),
            ),
            alignment: Alignment.topCenter,
            padding: const EdgeInsets.only(top: 10),
            child: Text(
              '$place',
              style: const TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.w900,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RankRow extends StatelessWidget {
  const _RankRow({required this.entry, this.highlighted = false});

  final LeaderboardEntry entry;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    final change = entry.rankChange;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: highlighted
            ? AppColors.gold.withValues(alpha: 0.12)
            : AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: highlighted ? AppColors.gold : Colors.transparent,
        ),
      ),
      child: Row(
        children: <Widget>[
          SizedBox(
            width: 34,
            child: Text(
              '#${entry.rank}',
              style: const TextStyle(
                fontWeight: FontWeight.w900,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          GdAvatar(name: entry.name, imageUrl: entry.avatarUrl, size: 38),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  highlighted ? 'You' : entry.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                Text(
                  '${entry.gamesPlayed} games played',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          if (change != null && change != 0) ...<Widget>[
            Icon(
              change > 0
                  ? Icons.arrow_drop_up_rounded
                  : Icons.arrow_drop_down_rounded,
              color: change > 0 ? AppColors.success : AppColors.danger,
            ),
            const SizedBox(width: 4),
          ],
          Text(
            '${formatGrouped(entry.score)} XP',
            style: const TextStyle(
              color: AppColors.gold,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _MyRankBar extends StatelessWidget {
  const _MyRankBar({required this.me, required this.signedIn});

  final LeaderboardEntry? me;
  final bool signedIn;

  @override
  Widget build(BuildContext context) {
    final entry = me;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.line)),
      ),
      child: SafeArea(
        top: false,
        child: entry != null
            ? _RankRow(entry: entry, highlighted: true)
            : Row(
                children: <Widget>[
                  const Icon(
                    Icons.person_pin_circle_rounded,
                    color: AppColors.gold,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      signedIn
                          ? 'Play a game to get ranked.'
                          : 'Sign in to see your rank.',
                      style: const TextStyle(color: AppColors.textSecondary),
                    ),
                  ),
                  if (!signedIn)
                    TextButton(
                      onPressed: () => context.push(AppRoutes.login),
                      child: const Text('Sign In'),
                    ),
                ],
              ),
      ),
    );
  }
}
