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

  /// AdMob rewarded ad unit ids, used in release builds only. An empty id
  /// hides "Watch & Earn" on that platform.
  static const String admobRewardedAndroid = String.fromEnvironment(
    'ADMOB_REWARDED_ANDROID',
    defaultValue: 'ca-app-pub-7799318738010798/2479454480',
  );
  static const String admobRewardedIos = String.fromEnvironment(
    'ADMOB_REWARDED_IOS',
  );

  static String gameShareUrl(String slug) =>
      '$webBaseUrl/game/${Uri.encodeComponent(slug)}';

  static String communityPostShareUrl(String id) =>
      '$webBaseUrl/community/post/${Uri.encodeComponent(id)}';

  const AppConfig._();
}
