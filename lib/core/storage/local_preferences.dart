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
}
