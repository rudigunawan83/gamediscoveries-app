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
  static const String communitySaved = '/community/saved';
  static const String notifications = '/notifications';
  static const String favorites = '/favorites';
  static const String history = '/history';
  static const String accountSettings = '/settings';
  static const String help = '/help';
  static const String myReviews = '/my-reviews';

  static String game(String slug) => '/game/${Uri.encodeComponent(slug)}';

  static String communityPost(String id) =>
      '/community/posts/${Uri.encodeComponent(id)}';

  static String gamePlay(String slug) =>
      '/game/${Uri.encodeComponent(slug)}/play';

  const AppRoutes._();
}
