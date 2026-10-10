import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

final sharedPreferencesProvider = Provider<SharedPreferences>((Ref ref) {
  throw UnimplementedError('sharedPreferencesProvider must be overridden.');
});

final localPreferencesProvider = Provider<LocalPreferences>((Ref ref) {
  return LocalPreferences(ref.watch(sharedPreferencesProvider));
});

class LocalPreferences {
  LocalPreferences(this._prefs);

  static const String _onboardingDoneKey = 'onboarding.done';
  static const String _anonymousIdKey = 'analytics.anonymousId';
  static const String _savedCommunityPostsKey = 'community.savedPosts';
  static const String _skippedUpdateBuildKey = 'appUpdate.skippedBuild';
  static const String _appLanguageKey = 'app.language';
  static const String _appLanguageNeedsSyncKey = 'app.language.needsSync';

  final SharedPreferences _prefs;

  bool get onboardingDone => _prefs.getBool(_onboardingDoneKey) ?? false;

  Future<void> markOnboardingDone() {
    return _prefs.setBool(_onboardingDoneKey, true);
  }

  String get anonymousId {
    final existing = _prefs.getString(_anonymousIdKey);
    if (existing != null && existing.isNotEmpty) return existing;

    final created = const Uuid().v4();
    _prefs.setString(_anonymousIdKey, created);
    return created;
  }

  /// JSON snapshots of bookmarked community posts, newest first.
  List<String> get savedCommunityPosts =>
      _prefs.getStringList(_savedCommunityPostsKey) ?? const <String>[];

  Future<void> setSavedCommunityPosts(List<String> posts) {
    return _prefs.setStringList(_savedCommunityPostsKey, posts);
  }

  /// Newest optional update build the user chose "Later" for.
  int get skippedUpdateBuild => _prefs.getInt(_skippedUpdateBuildKey) ?? 0;

  Future<void> setSkippedUpdateBuild(int build) {
    return _prefs.setInt(_skippedUpdateBuildKey, build);
  }

  /// `SYSTEM`, `en` or `id`; null until the user picks a language.
  String? get appLanguage => _prefs.getString(_appLanguageKey);

  Future<void> setAppLanguage(String code) {
    return _prefs.setString(_appLanguageKey, code);
  }

  /// True while a locally chosen language has not been saved to the account.
  /// Choices stored before account sync existed count as unsaved.
  bool get appLanguageNeedsSync =>
      _prefs.getBool(_appLanguageNeedsSyncKey) ?? (appLanguage != null);

  Future<void> setAppLanguageNeedsSync(bool value) {
    return _prefs.setBool(_appLanguageNeedsSyncKey, value);
  }
}
