import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../shared/widgets/app_search_field.dart';
import '../../../../shared/widgets/gd_avatar.dart';
import '../../../../shared/widgets/xp_progress_bar.dart';
import '../../../auth/presentation/providers/auth_session_controller.dart';
import '../../../discovery/presentation/providers/discovery_providers.dart';
import '../../../favorites/presentation/library_providers.dart';
import '../../../notifications/presentation/notifications_providers.dart';
import '../../../progress/presentation/progress_providers.dart';
import '../widgets/home_discovery_sections.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  Future<void> _refresh(WidgetRef ref) async {
    ref
      ..invalidate(gameListProvider(mobileReadyShelfQuery))
      ..invalidate(homeDiscoveriesProvider)
      ..invalidate(forYouProvider)
      ..invalidate(myProgressProvider)
      ..invalidate(playHistoryProvider)
      ..invalidate(notificationsProvider);
    try {
      await ref.read(homeDiscoveriesProvider.future);
    } catch (_) {
      // The error state is rendered by HomeDiscoverySections.
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          onRefresh: () => _refresh(ref),
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: <Widget>[
              const SliverToBoxAdapter(child: _HomeHeader()),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
                  child: AppSearchField(
                    readOnly: true,
                    onTap: () => context.go(AppRoutes.discover),
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: _AdventureBanner()),
              const SliverToBoxAdapter(child: HomeDiscoverySections()),
            ],
          ),
        ),
      ),
    );
  }
}

class _HomeHeader extends ConsumerWidget {
  const _HomeHeader();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    final user = ref.watch(authSessionControllerProvider).value?.user;
    final progress = ref.watch(myProgressProvider).value;
    final unread = ref.watch(unreadNotificationsProvider);

    final name = progress?.userName.isNotEmpty == true
        ? progress!.userName
        : (user?.displayName.isNotEmpty == true ? user!.displayName : 'Player');
    final firstName = name.split(' ').first;
    final level = progress?.level;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 12, 14),
      child: Row(
        children: <Widget>[
          GestureDetector(
            onTap: () => context.go(AppRoutes.profile),
            child: GdAvatar(
              name: name,
              imageUrl: progress?.avatarUrl ?? user?.avatarUrl,
              size: 48,
              ringColor: AppColors.gold,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Hi, $firstName 👋',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                if (level == null)
                  GestureDetector(
                    onTap: () => context.push(AppRoutes.login),
                    child: Text(
                      'Sign in to earn XP & level up',
                      style: textTheme.bodySmall?.copyWith(
                        color: AppColors.gold,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  )
                else
                  GestureDetector(
                    onTap: () => context.push(AppRoutes.progress),
                    child: Row(
                      children: <Widget>[
                        Text(
                          'Level ${level.level}',
                          style: textTheme.labelMedium?.copyWith(
                            color: AppColors.gold,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: XpProgressBar(
                            value: level.progress,
                            height: 6,
                            semanticLabel: 'Level progress',
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          level.isMaxLevel
                              ? 'MAX'
                              : '${formatGrouped(level.currentLevelXp)} / '
                                    '${formatGrouped(level.nextLevelXp)} XP',
                          style: textTheme.labelSmall?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 4),
          IconButton(
            tooltip: 'Notifications',
            onPressed: () => context.push(AppRoutes.notifications),
            icon: Badge(
              isLabelVisible: unread > 0,
              label: Text(unread > 99 ? '99+' : '$unread'),
              backgroundColor: AppColors.danger,
              child: const Icon(Icons.notifications_none_rounded, size: 28),
            ),
          ),
        ],
      ),
    );
  }
}

class _AdventureBanner extends StatelessWidget {
  const _AdventureBanner();

  static const double _aspectRatio = 950 / 330;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      child: Semantics(
        button: true,
        label:
            'New Adventures Every Day. Explore the latest and trending games!',
        excludeSemantics: true,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Material(
            color: AppColors.surface,
            child: Ink.image(
              image: const AssetImage('assets/images/home_banner.jpg'),
              fit: BoxFit.cover,
              child: InkWell(
                onTap: () => context.go(AppRoutes.discover),
                child: const AspectRatio(aspectRatio: _aspectRatio),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
