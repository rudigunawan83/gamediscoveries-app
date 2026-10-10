import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/l10n/app_language.dart';
import '../core/l10n/locale_resolution.dart';
import '../features/app_update/presentation/app_update_gate.dart';
import '../features/profile/presentation/language_sync.dart';
import 'router/app_router.dart';
import 'theme/app_theme.dart';

class GameDiscoveriesApp extends ConsumerWidget {
  const GameDiscoveriesApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(languageSyncProvider);
    return MaterialApp.router(
      title: 'Game Discoveries',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.dark,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      locale: ref.watch(appLanguageProvider).locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      localeListResolutionCallback:
          (List<Locale>? locales, Iterable<Locale> supported) =>
              resolveSupportedLocale(locales, supported: supported),
      routerConfig: ref.watch(appRouterProvider),
      builder: (BuildContext context, Widget? child) =>
          AppUpdateGate(child: child ?? const SizedBox.shrink()),
    );
  }
}
