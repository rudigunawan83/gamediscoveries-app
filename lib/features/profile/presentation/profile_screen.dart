import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/app_routes.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/widgets/gd_avatar.dart';
import '../../../shared/widgets/state_views.dart';
import '../../../shared/widgets/xp_progress_bar.dart';
import '../../achievements/presentation/achievements_providers.dart';
import '../../auth/domain/models/auth_session_state.dart';
import '../../auth/presentation/providers/auth_session_controller.dart';
import '../../progress/presentation/progress_providers.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(authSessionControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Profile'), centerTitle: false),
      body: session.when(
        data: (AuthSessionState s) => s.isAuthenticated
            ? const _SignedInProfile()
            : const _GuestProfile(),
        loading: () => const LoadingView(),
        error: (Object error, StackTrace stackTrace) => ErrorView(
          error: error,
          onRetry: () => ref.invalidate(authSessionControllerProvider),
        ),
      ),
    );
  }
}

class _SignedInProfile extends ConsumerWidget {
  const _SignedInProfile();

  Future<void> _confirmLogout(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Sign out?'),
        content: const Text('Your progress stays saved on your account.'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text(
              'Sign Out',
              style: TextStyle(color: AppColors.danger),
            ),
          ),
        ],
      ),
    );
    if (confirmed ?? false) {
      await ref.read(authSessionControllerProvider.notifier).logout();
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    final user = ref.watch(authSessionControllerProvider).value?.user;
    final progress = ref.watch(myProgressProvider).value;
    final achievements = ref.watch(myAchievementsProvider).value;

    final name = progress?.userName.isNotEmpty == true
        ? progress!.userName
        : (user?.displayName.isNotEmpty == true ? user!.displayName : 'Player');
    final level = progress?.level;
    final stats = progress?.stats;

    return RefreshIndicator(
      onRefresh: () {
        ref.invalidate(myAchievementsProvider);
        return ref.refresh(myProgressProvider.future);
      },
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: <Widget>[
          Center(
            child: GdAvatar(
              name: name,
              imageUrl: progress?.avatarUrl ?? user?.avatarUrl,
              size: 96,
              ringColor: AppColors.gold,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            name,
            textAlign: TextAlign.center,
            style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
          ),
          if (user != null)
            Text(
              user.email,
              textAlign: TextAlign.center,
              style: textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          if (level != null) ...<Widget>[
            const SizedBox(height: 16),
            Row(
              children: <Widget>[
                Text(
                  'Level ${level.level}',
                  style: const TextStyle(
                    color: AppColors.gold,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const Spacer(),
                Text(
                  level.isMaxLevel
                      ? 'MAX'
                      : '${formatGrouped(level.currentLevelXp)} / '
                            '${formatGrouped(level.nextLevelXp)} XP',
                  style: textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            XpProgressBar(value: level.progress, height: 8),
          ],
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              children: <Widget>[
                _Stat(
                  value: stats == null
                      ? '—'
                      : formatCompact(stats.uniqueGamesPlayed),
                  label: 'Games',
                ),
                _Stat(
                  value: stats == null ? '—' : formatCompact(stats.favorites),
                  label: 'Favorites',
                ),
                _Stat(
                  value: stats == null ? '—' : '${stats.currentStreak}d',
                  label: 'Streak',
                ),
                _Stat(
                  value: achievements == null
                      ? '—'
                      : '${achievements.userUnlocked}',
                  label: 'Badges',
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _MenuGroup(
            items: <_MenuItem>[
              _MenuItem(
                Icons.favorite_rounded,
                AppColors.pink,
                'My Favorites',
                AppRoutes.favorites,
              ),
              _MenuItem(
                Icons.history_rounded,
                AppColors.blue,
                'Play History',
                AppRoutes.history,
              ),
              _MenuItem(
                Icons.trending_up_rounded,
                AppColors.success,
                'My Progress',
                AppRoutes.progress,
              ),
              _MenuItem(
                Icons.emoji_events_rounded,
                AppColors.gold,
                'Achievements',
                AppRoutes.achievements,
              ),
            ],
          ),
          const SizedBox(height: 14),
          const _MenuGroup(items: _communityItems),
          const SizedBox(height: 20),
          OutlinedButton.icon(
            onPressed: () => _confirmLogout(context, ref),
            icon: const Icon(Icons.logout_rounded, color: AppColors.danger),
            label: const Text(
              'Sign Out',
              style: TextStyle(color: AppColors.danger),
            ),
          ),
        ],
      ),
    );
  }
}

class _GuestProfile extends StatelessWidget {
  const _GuestProfile();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
      children: <Widget>[
        const Center(
          child: GdAvatar(name: 'Guest', size: 96, ringColor: AppColors.line),
        ),
        const SizedBox(height: 12),
        Text(
          'Guest Player',
          textAlign: TextAlign.center,
          style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 4),
        Text(
          'Create an account to save XP, streaks, favorites and achievements.',
          textAlign: TextAlign.center,
          style: textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: () => context.push(AppRoutes.register),
          child: const Text('Create Account'),
        ),
        const SizedBox(height: 10),
        OutlinedButton(
          onPressed: () => context.push(AppRoutes.login),
          child: const Text('Sign In'),
        ),
        const SizedBox(height: 24),
        const _MenuGroup(items: _communityItems),
      ],
    );
  }
}

const List<_MenuItem> _communityItems = <_MenuItem>[
  _MenuItem(
    Icons.leaderboard_rounded,
    AppColors.purple,
    'Leaderboard',
    AppRoutes.leaderboard,
  ),
  _MenuItem(
    Icons.forum_rounded,
    AppColors.teal,
    'Community',
    AppRoutes.community,
  ),
  _MenuItem(
    Icons.notifications_rounded,
    AppColors.orange,
    'Notifications',
    AppRoutes.notifications,
  ),
];

class _Stat extends StatelessWidget {
  const _Stat({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: <Widget>[
          Text(
            value,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _MenuItem {
  const _MenuItem(this.icon, this.color, this.label, this.route);

  final IconData icon;
  final Color color;
  final String label;
  final String route;
}

class _MenuGroup extends StatelessWidget {
  const _MenuGroup({required this.items});

  final List<_MenuItem> items;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: <Widget>[
          for (var i = 0; i < items.length; i++) ...<Widget>[
            if (i > 0)
              const Divider(height: 1, indent: 64, color: AppColors.line),
            ListTile(
              onTap: () => context.push(items[i].route),
              leading: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: items[i].color.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Icon(items[i].icon, color: items[i].color, size: 20),
              ),
              title: Text(
                items[i].label,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              trailing: const Icon(
                Icons.chevron_right_rounded,
                color: AppColors.textMuted,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
