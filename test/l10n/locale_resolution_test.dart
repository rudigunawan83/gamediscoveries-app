import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gamediscoveries_mobile/core/l10n/app_language.dart';
import 'package:gamediscoveries_mobile/core/l10n/locale_resolution.dart';

void main() {
  group('resolveSupportedLocale', () {
    test('uses English for an English device', () {
      expect(
        resolveSupportedLocale(const <Locale>[Locale('en', 'US')]),
        const Locale('en'),
      );
    });

    test('uses Indonesian for an Indonesian device', () {
      expect(
        resolveSupportedLocale(const <Locale>[Locale('id', 'ID')]),
        const Locale('id'),
      );
    });

    test('maps the legacy Android code "in" to Indonesian', () {
      expect(
        resolveSupportedLocale(const <Locale>[Locale('in', 'ID')]),
        const Locale('id'),
      );
    });

    test('falls back to English for unsupported languages', () {
      expect(
        resolveSupportedLocale(const <Locale>[Locale('ja', 'JP')]),
        const Locale('en'),
      );
      expect(resolveSupportedLocale(null), const Locale('en'));
    });

    test('picks the first supported language from the preference list', () {
      expect(
        resolveSupportedLocale(const <Locale>[
          Locale('ja'),
          Locale('id', 'ID'),
          Locale('en'),
        ]),
        const Locale('id'),
      );
    });
  });

  group('AppLanguage', () {
    test('maps API codes and treats unknown values as system', () {
      expect(AppLanguage.fromCode('en'), AppLanguage.english);
      expect(AppLanguage.fromCode('id'), AppLanguage.indonesian);
      expect(AppLanguage.fromCode('SYSTEM'), AppLanguage.system);
      expect(AppLanguage.fromCode('fr'), AppLanguage.system);
      expect(AppLanguage.fromCode(null), AppLanguage.system);
      expect(AppLanguage.system.locale, isNull);
      expect(AppLanguage.indonesian.locale, const Locale('id'));
    });
  });

  group('generated messages', () {
    test('pluralize and format numbers per locale', () async {
      final en = await AppLocalizations.delegate.load(const Locale('en'));
      final id = await AppLocalizations.delegate.load(const Locale('id'));

      expect(en.progressGamesPlayed(1), '1 game played');
      expect(en.progressGamesPlayed(2), '2 games played');
      expect(id.progressGamesPlayed(2), '2 game dimainkan');
      expect(en.timeHoursAgo(2), '2h ago');
      expect(id.timeHoursAgo(2), '2 jam lalu');
      expect(en.progressTotalXp(12500), 'Total 12,500 XP');
      expect(id.progressTotalXp(12500), 'Total 12.500 XP');
      expect(id.profileWelcome('Rudi'), 'Selamat datang, Rudi');
    });
  });
}
