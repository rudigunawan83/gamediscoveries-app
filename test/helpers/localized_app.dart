import 'package:flutter/material.dart';
import 'package:gamediscoveries_mobile/core/l10n/locale_resolution.dart';

/// `MaterialApp` with the app's localization setup for widget tests.
MaterialApp localizedApp({
  required Widget home,
  Locale locale = const Locale('en'),
}) {
  return MaterialApp(
    locale: locale,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: home,
  );
}

/// `MaterialApp.router` with the app's localization setup for widget tests.
MaterialApp localizedRouterApp(
  RouterConfig<Object> router, {
  Locale locale = const Locale('en'),
}) {
  return MaterialApp.router(
    locale: locale,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    routerConfig: router,
  );
}
