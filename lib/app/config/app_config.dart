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

  /// AdMob rewarded ad unit ids. Empty in release unless passed with
  /// --dart-define, which hides "Watch & Earn".
  static const String admobRewardedAndroid = String.fromEnvironment(
    'ADMOB_REWARDED_ANDROID',
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
