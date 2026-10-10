import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../storage/local_preferences.dart';

/// Language mode chosen in Account Settings. [code] matches the API values.
enum AppLanguage {
  system('SYSTEM'),
  english('en'),
  indonesian('id');

  const AppLanguage(this.code);

  final String code;

  /// Explicit app locale, or null to follow the device language.
  Locale? get locale => this == system ? null : Locale(code);

  static AppLanguage fromCode(String? code) => tryFromCode(code) ?? system;

  static AppLanguage? tryFromCode(String? code) {
    for (final language in values) {
      if (language.code == code) return language;
    }
    return null;
  }
}

class AppLanguageController extends Notifier<AppLanguage> {
  @override
  AppLanguage build() =>
      AppLanguage.fromCode(ref.watch(localPreferencesProvider).appLanguage);

  /// A choice made on this device; it is saved to the account when signed in.
  Future<void> select(AppLanguage language) async {
    final prefs = ref.read(localPreferencesProvider);
    await prefs.setAppLanguageNeedsSync(true);
    state = language;
    await prefs.setAppLanguage(language.code);
  }

  /// Applies the language already stored on the user's account.
  Future<void> adopt(AppLanguage language) async {
    final prefs = ref.read(localPreferencesProvider);
    await prefs.setAppLanguageNeedsSync(false);
    state = language;
    await prefs.setAppLanguage(language.code);
  }
}

final appLanguageProvider =
    NotifierProvider<AppLanguageController, AppLanguage>(
      AppLanguageController.new,
    );
