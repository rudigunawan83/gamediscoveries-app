class AppConfig {
  static const String appName = 'GameDiscoveries';
  static const String environment = String.fromEnvironment(
    'APP_ENV',
    defaultValue: 'development',
  );
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://api.gamediscoveries.com',
  );
  static const String webBaseUrl = String.fromEnvironment(
    'WEB_BASE_URL',
    defaultValue: 'https://www.gamediscoveries.com',
  );

  static String gameShareUrl(String slug) =>
      '$webBaseUrl/game/${Uri.encodeComponent(slug)}';

  static String communityPostShareUrl(String id) =>
      '$webBaseUrl/community/post/${Uri.encodeComponent(id)}';

  const AppConfig._();
}
