import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/app_routes.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/errors/error_messages.dart';
import '../../../core/l10n/locale_resolution.dart';
import '../../../shared/widgets/state_views.dart';
import '../../achievements/domain/achievement_models.dart';
import '../../achievements/presentation/achievements_providers.dart';
import '../../auth/domain/models/auth_session_state.dart';
import '../../auth/presentation/providers/auth_session_controller.dart';
import '../../progress/domain/progress_models.dart';
import '../../progress/presentation/progress_providers.dart';
import 'avatar_controller.dart';
import 'avatar_edit_sheet.dart';
import 'sign_out_dialog.dart';
import 'widgets/profile_header.dart';
import 'widgets/profile_hero_background.dart';
import 'widgets/profile_identity_card.dart';
import 'widgets/profile_menu_item.dart';
import 'widgets/profile_statistics_card.dart';
import 'widgets/profile_xp_progress.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(authSessionControllerProvider);

    return Scaffold(
      body: SafeArea(
        top: false,
        bottom: false,
        child: session.when(
          data: (AuthSessionState s) => s.isAuthenticated
              ? const _SignedInProfile()
              : const _GuestProfile(),
          loading: () => const _ProfileBody(children: <Widget>[LoadingView()]),
          error: (Object error, StackTrace stackTrace) => _ProfileBody(
            children: <Widget>[
              ErrorView(
                error: error,
                onRetry: () => ref.invalidate(authSessionControllerProvider),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Scrollable page shell. The header and [identity] sit on the full-bleed
/// hero artwork (drawn under the status bar); the rest is capped to a
/// readable width on tablets.
class _ProfileBody extends StatelessWidget {
  const _ProfileBody({required this.children, this.identity, this.onRefresh});

  static const double _maxContentWidth = 560;

  final Widget? identity;
  final List<Widget> children;
  final RefreshCallback? onRefresh;

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.paddingOf(context).top;
    final identityWidget = identity;

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final horizontal = math.max(
          20.0,
          (constraints.maxWidth - _maxContentWidth) / 2,
        );
        final list = ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.only(bottom: 32),
          children: <Widget>[
            Stack(
              children: <Widget>[
                const Positioned.fill(child: ProfileHeroBackground()),
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    horizontal,
                    topInset + 12,
                    horizontal,
                    24,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      ProfileHeader(
                        title: context.l10n.profileTitle,
                        onSettings: () =>
                            context.push(AppRoutes.accountSettings),
                      ),
                      if (identityWidget != null) ...<Widget>[
                        const SizedBox(height: 4),
                        identityWidget,
                      ],
                    ],
                  ),
                ),
              ],
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: horizontal),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: children,
              ),
            ),
          ],
        );
        final refresh = onRefresh;
        return refresh == null
            ? list
            : RefreshIndicator(onRefresh: refresh, child: list);
      },
    );
  }
}

class _SignedInProfile extends ConsumerWidget {
  const _SignedInProfile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final user = ref.watch(authSessionControllerProvider).value?.user;
    final progressAsync = ref.watch(myProgressProvider);
    final progress = progressAsync.value;
    final achievements = ref.watch(myAchievementsProvider).value;

    final name = progress?.userName.isNotEmpty == true
        ? progress!.userName
        : (user?.displayName.isNotEmpty == true
              ? user!.displayName
              : l10n.profileDefaultName);
    final progressError = progress == null ? progressAsync.error : null;
    // /users/me is the source of truth; progress can lag behind an upload.
    final avatarUrl = user?.avatarUrl;
    final username = user?.username;
    final handle = username != null && username.isNotEmpty
        ? '@$username'
        : user?.email;

    void retry() {
      ref.invalidate(myProgressProvider);
      ref.invalidate(myAchievementsProvider);
    }

    return _ProfileBody(
      onRefresh: () {
        ref.invalidate(myAchievementsProvider);
        return ref.refresh(myProgressProvider.future);
      },
      identity: ProfileIdentityCard(
        name: name,
        subtitle: handle,
        avatarUrl: avatarUrl,
        avatarBusy: ref.watch(avatarControllerProvider),
        onEditAvatar: () =>
            editAvatar(context, ref, hasAvatar: avatarUrl != null),
      ),
      children: <Widget>[
        if (progressError != null)
          _ProgressErrorCard(error: progressError, onRetry: retry)
        else ...<Widget>[
          ProfileXpProgress(level: progress?.level),
          const SizedBox(height: 20),
          ProfileStatisticsCard(stats: _stats(l10n, progress, achievements)),
        ],
        const SizedBox(height: 24),
        const _MainMenu(),
        const SizedBox(height: 24),
        _MoreSection(
          items: <_MoreItem>[
            _MoreItem(
              Icons.trending_up_rounded,
              AppColors.teal,
              l10n.profileMyProgress,
              AppRoutes.progress,
            ),
            _MoreItem(
              Icons.emoji_events_rounded,
              AppColors.gold,
              l10n.profileAchievements,
              AppRoutes.achievements,
            ),
            ..._communityItems(l10n),
          ],
        ),
        const SizedBox(height: 24),
        OutlinedButton.icon(
          onPressed: () => confirmAndSignOut(context, ref),
          icon: const Icon(Icons.logout_rounded, color: AppColors.danger),
          label: Text(
            l10n.commonSignOut,
            style: const TextStyle(color: AppColors.danger),
          ),
        ),
      ],
    );
  }

  /// Every value comes from the backend; `null` renders as a dash.
  static List<ProfileStat> _stats(
    AppLocalizations l10n,
    UserProgress? progress,
    AchievementList? achievements,
  ) {
    final stats = progress?.stats;
    return <ProfileStat>[
      ProfileStat(
        icon: const GradientIcon(
          Icons.local_fire_department_rounded,
          colors: <Color>[
            Color(0xFFFF4D2E),
            Color(0xFFFF8A1F),
            Color(0xFFFFC928),
          ],
        ),
        label: l10n.profileStatGames,
        semanticsLabel: l10n.profileStatSessionsSemantics,
        value: stats?.totalGameSessions,
      ),
      ProfileStat(
        icon: const GradientIcon(
          Icons.sports_esports_rounded,
          colors: <Color>[Color(0xFFFFE27A), AppColors.goldDeep],
        ),
        label: l10n.profileStatGames,
        semanticsLabel: l10n.profileStatUniqueGamesSemantics,
        value: stats?.uniqueGamesPlayed,
      ),
      ProfileStat(
        icon: const GradientIcon(
          Icons.emoji_events_rounded,
          colors: <Color>[Color(0xFFFFE27A), AppColors.goldDeep],
        ),
        label: l10n.profileAchievements,
        semanticsLabel: l10n.profileStatAchievementsSemantics,
        value: achievements?.userUnlocked,
        highlight: true,
      ),
      ProfileStat(
        icon: const _PointsIcon(),
        label: l10n.profileStatPoints,
        semanticsLabel: l10n.profileStatPointsSemantics,
        value: progress?.level.totalXp,
      ),
    ];
  }
}

class _GuestProfile extends StatelessWidget {
  const _GuestProfile();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final l10n = context.l10n;

    return _ProfileBody(
      identity: ProfileIdentityCard(
        name: l10n.profileGuestName,
        highlighted: false,
      ),
      children: <Widget>[
        Text(
          l10n.profileGuestPrompt,
          textAlign: TextAlign.center,
          style: textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: () => context.push(AppRoutes.register),
          child: Text(l10n.authCreateAccount),
        ),
        const SizedBox(height: 10),
        OutlinedButton(
          onPressed: () => context.push(AppRoutes.login),
          child: Text(l10n.commonSignIn),
        ),
        const SizedBox(height: 24),
        const _MainMenu(),
        const SizedBox(height: 24),
        _MoreSection(items: _communityItems(l10n)),
      ],
    );
  }
}

class _MainMenu extends StatelessWidget {
  const _MainMenu();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 10,
      children: <Widget>[
        ProfileMenuItem(
          icon: Icons.favorite_rounded,
          label: l10n.profileMyFavorites,
          accent: AppColors.gold,
          onTap: () => context.push(AppRoutes.favorites),
        ),
        ProfileMenuItem(
          icon: Icons.history_rounded,
          label: l10n.profilePlayHistory,
          accent: AppColors.purple,
          onTap: () => context.push(AppRoutes.history),
        ),
        ProfileMenuItem(
          icon: Icons.chat_outlined,
          label: l10n.profileMyReviews,
          accent: AppColors.blue,
          onTap: () => context.push(AppRoutes.myReviews),
        ),
        ProfileMenuItem(
          icon: Icons.settings_rounded,
          label: l10n.settingsTitle,
          accent: AppColors.success,
          onTap: () => context.push(AppRoutes.accountSettings),
        ),
        ProfileMenuItem(
          icon: Icons.help_outline_rounded,
          label: l10n.profileHelpSupport,
          accent: AppColors.danger,
          onTap: () => context.push(AppRoutes.help),
        ),
      ],
    );
  }
}

List<_MoreItem> _communityItems(AppLocalizations l10n) => <_MoreItem>[
  _MoreItem(
    Icons.leaderboard_rounded,
    AppColors.purple,
    l10n.profileLeaderboard,
    AppRoutes.leaderboard,
  ),
  _MoreItem(
    Icons.forum_rounded,
    AppColors.teal,
    l10n.profileCommunity,
    AppRoutes.community,
  ),
  _MoreItem(
    Icons.notifications_rounded,
    AppColors.orange,
    l10n.profileNotifications,
    AppRoutes.notifications,
  ),
];

class _MoreItem {
  const _MoreItem(this.icon, this.accent, this.label, this.route);

  final IconData icon;
  final Color accent;
  final String label;
  final String route;
}

class _MoreSection extends StatelessWidget {
  const _MoreSection({required this.items});

  final List<_MoreItem> items;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 10,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(left: 4),
          child: Semantics(
            header: true,
            child: Text(
              context.l10n.profileMore,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
        for (final item in items)
          ProfileMenuItem(
            icon: item.icon,
            label: item.label,
            accent: item.accent,
            prominent: false,
            onTap: () => context.push(item.route),
          ),
      ],
    );
  }
}

class _ProgressErrorCard extends StatelessWidget {
  const _ProgressErrorCard({required this.error, required this.onRetry});

  final Object error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 8, 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.danger.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Icon(Icons.wifi_off_rounded, color: AppColors.danger),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  friendlyErrorMessage(context.l10n, error),
                  style: const TextStyle(color: AppColors.textSecondary),
                ),
              ),
            ],
          ),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: onRetry,
              child: Text(context.l10n.commonRetry),
            ),
          ),
        ],
      ),
    );
  }
}

class _PointsIcon extends StatelessWidget {
  const _PointsIcon();

  @override
  Widget build(BuildContext context) {
    return const Stack(
      alignment: Alignment.center,
      children: <Widget>[
        GradientIcon(
          Icons.hexagon_rounded,
          colors: <Color>[Color(0xFFC084FC), Color(0xFF6D28D9)],
          size: 36,
        ),
        Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 15),
      ],
    );
  }
}
