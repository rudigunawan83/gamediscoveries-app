class AppRoutes {
  static const String splash = '/splash';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String register = '/register';

  static const String home = '/home';
  static const String discover = '/discover';
  static const String play = '/play';
  static const String missions = '/missions';
  static const String profile = '/profile';

  static const String progress = '/progress';
  static const String achievements = '/achievements';
  static const String leaderboard = '/leaderboard';
  static const String community = '/community';
  static const String notifications = '/notifications';
  static const String favorites = '/favorites';
  static const String history = '/history';

  static String game(String slug) => '/game/${Uri.encodeComponent(slug)}';

  static String gamePlay(String slug) =>
      '/game/${Uri.encodeComponent(slug)}/play';

  const AppRoutes._();
}
