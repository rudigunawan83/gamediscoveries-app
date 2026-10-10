import 'package:flutter/widgets.dart';

import '../../l10n/app_localizations.dart';

export '../../l10n/app_localizations.dart';

const Locale fallbackLocale = Locale('en');

/// Older Android/Java runtimes report Indonesian as `in`.
const Map<String, String> _legacyLanguageCodes = <String, String>{'in': 'id'};

/// First device locale the app supports, otherwise English.
Locale resolveSupportedLocale(
  Iterable<Locale>? deviceLocales, {
  Iterable<Locale> supported = AppLocalizations.supportedLocales,
}) {
  final codes = supported.map((Locale l) => l.languageCode).toSet();
  for (final locale in deviceLocales ?? const <Locale>[]) {
    final code =
        _legacyLanguageCodes[locale.languageCode] ?? locale.languageCode;
    if (codes.contains(code)) return Locale(code);
  }
  return fallbackLocale;
}

extension AppLocalizationsContext on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}
