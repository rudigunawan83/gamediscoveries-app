import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/achievements/presentation/achievements_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/community/presentation/community_screen.dart';
import '../../features/discovery/presentation/screens/discover_screen.dart';
import '../../features/favorites/presentation/favorites_screen.dart';
import '../../features/favorites/presentation/history_screen.dart';
import '../../features/game_detail/domain/game_detail.dart';
import '../../features/game_detail/presentation/game_detail_screen.dart';
import '../../features/game_player/presentation/game_player_screen.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/home/presentation/screens/main_shell.dart';
import '../../features/home/presentation/screens/play_screen.dart';
import '../../features/home/presentation/screens/splash_screen.dart';
import '../../features/leaderboard/presentation/leaderboard_screen.dart';
import '../../features/missions/presentation/missions_screen.dart';
import '../../features/notifications/presentation/notifications_screen.dart';
import '../../features/onboarding/presentation/onboarding_screen.dart';
import '../../features/profile/presentation/profile_screen.dart';
import '../../features/progress/presentation/progress_screen.dart';
import 'app_routes.dart';

final appRouterProvider = Provider<GoRouter>((Ref ref) {
  final router = GoRouter(
    initialLocation: AppRoutes.splash,
    routes: <RouteBase>[
      GoRoute(
        path: AppRoutes.splash,
        builder: (BuildContext c, GoRouterState s) => const SplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.onboarding,
        builder: (BuildContext c, GoRouterState s) => const OnboardingScreen(),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (BuildContext c, GoRouterState s) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.register,
        builder: (BuildContext c, GoRouterState s) => const RegisterScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder:
            (
              BuildContext context,
              GoRouterState state,
              StatefulNavigationShell shell,
            ) => MainShell(shell: shell),
        branches: <StatefulShellBranch>[
          _branch(AppRoutes.home, const HomeScreen()),
          _branch(AppRoutes.discover, const DiscoverScreen()),
          _branch(AppRoutes.play, const PlayScreen()),
          _branch(AppRoutes.missions, const MissionsScreen()),
          _branch(AppRoutes.profile, const ProfileScreen()),
        ],
      ),
      GoRoute(
        path: '/game/:slug',
        builder: (BuildContext context, GoRouterState state) =>
            GameDetailScreen(slug: state.pathParameters['slug'] ?? ''),
        routes: <RouteBase>[
          GoRoute(
            path: 'play',
            builder: (BuildContext context, GoRouterState state) =>
                GamePlayerScreen(
                  slug: state.pathParameters['slug'] ?? '',
                  initialGame: state.extra is GameDetail
                      ? state.extra! as GameDetail
                      : null,
                ),
          ),
        ],
      ),
      _page(AppRoutes.progress, const ProgressScreen()),
      _page(AppRoutes.achievements, const AchievementsScreen()),
      _page(AppRoutes.leaderboard, const LeaderboardScreen()),
      _page(AppRoutes.community, const CommunityScreen()),
      _page(AppRoutes.notifications, const NotificationsScreen()),
      _page(AppRoutes.favorites, const FavoritesScreen()),
      _page(AppRoutes.history, const HistoryScreen()),
    ],
  );

  ref.onDispose(router.dispose);
  return router;
});

StatefulShellBranch _branch(String path, Widget screen) {
  return StatefulShellBranch(
    routes: <RouteBase>[
      GoRoute(path: path, builder: (BuildContext c, GoRouterState s) => screen),
    ],
  );
}

GoRoute _page(String path, Widget screen) {
  return GoRoute(
    path: path,
    builder: (BuildContext c, GoRouterState s) => screen,
  );
}
