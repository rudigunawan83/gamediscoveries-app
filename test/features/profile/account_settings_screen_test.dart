import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gamediscoveries_mobile/core/l10n/app_language.dart';
import 'package:gamediscoveries_mobile/core/l10n/locale_resolution.dart';
import 'package:gamediscoveries_mobile/core/network/api_exception.dart';
import 'package:gamediscoveries_mobile/core/storage/local_preferences.dart';
import 'package:gamediscoveries_mobile/features/auth/domain/models/auth_session_state.dart';
import 'package:gamediscoveries_mobile/features/auth/domain/models/auth_user.dart';
import 'package:gamediscoveries_mobile/features/auth/presentation/providers/auth_session_controller.dart';
import 'package:gamediscoveries_mobile/features/profile/data/privacy_repository.dart';
import 'package:gamediscoveries_mobile/features/profile/data/profile_repository.dart';
import 'package:gamediscoveries_mobile/features/profile/domain/privacy_settings.dart';
import 'package:gamediscoveries_mobile/features/profile/presentation/account_settings_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _SignedIn extends AuthSessionController {
  @override
  Future<AuthSessionState> build() async =>
      const AuthSessionState.authenticated(
        AuthUser(
          id: 'u1',
          email: 'rudi@example.com',
          displayName: 'Rudi',
          username: 'rudi_gamer',
          roles: <String>[],
        ),
      );
}

class _Guest extends AuthSessionController {
  @override
  Future<AuthSessionState> build() async => const AuthSessionState.guest();
}

class _FakeProfileRepo implements ProfileRepository {
  _FakeProfileRepo({this.statusCode = 200});

  final int statusCode;
  String? displayName;
  String? username;

  @override
  Future<AuthUser> updateProfile({
    required String displayName,
    required String username,
  }) async {
    if (statusCode != 200) {
      throw ApiException(message: 'failed', statusCode: statusCode);
    }
    this.displayName = displayName;
    this.username = username;
    return AuthUser(
      id: 'u1',
      email: 'rudi@example.com',
      displayName: displayName,
      username: username,
      roles: const <String>[],
    );
  }
}

class _FakePrivacyRepo implements PrivacyRepository {
  _FakePrivacyRepo({this.fail = false});

  final bool fail;
  final List<(PrivacyOption, bool)> updates = <(PrivacyOption, bool)>[];

  @override
  Future<PrivacySettings> getPrivacy() async => PrivacySettings.fromJson(
    const <String, dynamic>{'showFavorites': true, 'showHistory': false},
  );

  @override
  Future<void> update(PrivacyOption option, bool value) async {
    if (fail) throw const ApiException(message: 'boom', statusCode: 503);
    updates.add((option, value));
  }
}

/// Same locale wiring as `GameDiscoveriesApp`.
Future<Widget> _app(
  _FakePrivacyRepo repo, {
  bool signedIn = true,
  Map<String, Object> prefs = const <String, Object>{},
  ProfileRepository? profile,
}) async {
  SharedPreferences.setMockInitialValues(prefs);
  final sharedPrefs = await SharedPreferences.getInstance();
  return ProviderScope(
    retry: (int retryCount, Object error) => null,
    overrides: [
      authSessionControllerProvider.overrideWith(
        signedIn ? _SignedIn.new : _Guest.new,
      ),
      privacyRepositoryProvider.overrideWithValue(repo),
      profileRepositoryProvider.overrideWithValue(
        profile ?? _FakeProfileRepo(),
      ),
      sharedPreferencesProvider.overrideWithValue(sharedPrefs),
    ],
    child: Consumer(
      builder: (BuildContext context, WidgetRef ref, Widget? child) =>
          MaterialApp(
            locale: ref.watch(appLanguageProvider).locale,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            localeListResolutionCallback:
                (List<Locale>? locales, Iterable<Locale> supported) =>
                    resolveSupportedLocale(locales, supported: supported),
            home: const AccountSettingsScreen(),
          ),
    ),
  );
}

SwitchListTile _switch(WidgetTester tester, String title) {
  return tester.widget<SwitchListTile>(
    find.ancestor(of: find.text(title), matching: find.byType(SwitchListTile)),
  );
}

RadioGroup<AppLanguage> _languageGroup(WidgetTester tester) => tester
    .widget<RadioGroup<AppLanguage>>(find.byType(RadioGroup<AppLanguage>));

Future<void> _scrollTo(WidgetTester tester, Finder finder) async {
  await tester.scrollUntilVisible(
    finder,
    200,
    scrollable: find.byType(Scrollable).first,
  );
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('shows account details and current privacy values', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(await _app(_FakePrivacyRepo()));
    await tester.pumpAndSettle();

    expect(find.text('rudi_gamer'), findsOneWidget);
    expect(find.text('Save profile'), findsOneWidget);
    expect(find.text('rudi@example.com'), findsOneWidget);
    await _scrollTo(tester, find.text('Show play history'));
    expect(_switch(tester, 'Show favorites').value, isTrue);
    expect(_switch(tester, 'Show play history').value, isFalse);
  });

  testWidgets('saves a privacy toggle', (WidgetTester tester) async {
    final repo = _FakePrivacyRepo();
    await tester.pumpWidget(await _app(repo));
    await tester.pumpAndSettle();

    await _scrollTo(tester, find.text('Show favorites'));
    await tester.tap(find.text('Show favorites'));
    await tester.pumpAndSettle();

    expect(repo.updates, <(PrivacyOption, bool)>[
      (PrivacyOption.showFavorites, false),
    ]);
    expect(_switch(tester, 'Show favorites').value, isFalse);
  });

  testWidgets('rolls back the toggle and explains when saving fails', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(await _app(_FakePrivacyRepo(fail: true)));
    await tester.pumpAndSettle();

    await _scrollTo(tester, find.text('Show favorites'));
    await tester.tap(find.text('Show favorites'));
    await tester.pumpAndSettle();

    expect(_switch(tester, 'Show favorites').value, isTrue);
    expect(
      find.text('Our servers are having trouble. Please try again later.'),
      findsOneWidget,
    );
  });

  testWidgets('saves a new display name and username', (
    WidgetTester tester,
  ) async {
    final profile = _FakeProfileRepo();
    await tester.pumpWidget(await _app(_FakePrivacyRepo(), profile: profile));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).at(0), 'Rudi Baru');
    await tester.enterText(find.byType(TextFormField).at(1), 'Rudi-Baru');
    await tester.pump();
    await _scrollTo(tester, find.text('Save profile'));
    await tester.tap(find.text('Save profile'));
    await tester.pumpAndSettle();

    expect(profile.displayName, 'Rudi Baru');
    expect(profile.username, 'rudi-baru');
    expect(find.text('Profile updated'), findsOneWidget);
  });

  testWidgets('keeps an invalid name and a taken username on screen', (
    WidgetTester tester,
  ) async {
    final profile = _FakeProfileRepo(statusCode: 409);
    await tester.pumpWidget(await _app(_FakePrivacyRepo(), profile: profile));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).at(0), 'A');
    await tester.pump();
    await _scrollTo(tester, find.text('Save profile'));
    await tester.tap(find.text('Save profile'));
    await tester.pumpAndSettle();

    expect(find.text('Use 2–40 characters.'), findsOneWidget);
    expect(profile.displayName, isNull);

    await tester.enterText(find.byType(TextFormField).at(0), 'Rudi Baru');
    await tester.enterText(find.byType(TextFormField).at(1), 'ada');
    await tester.pump();
    await _scrollTo(tester, find.text('Save profile'));
    await tester.tap(find.text('Save profile'));
    await tester.pumpAndSettle();

    expect(find.text('That username is already taken.'), findsOneWidget);
    expect(profile.displayName, isNull);
  });

  group('language', () {
    testWidgets('follows an English device by default', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(await _app(_FakePrivacyRepo()));
      await tester.pumpAndSettle();

      expect(find.text('Account Settings'), findsOneWidget);
      expect(_languageGroup(tester).groupValue, AppLanguage.system);
    });

    testWidgets('follows an Indonesian device in system mode', (
      WidgetTester tester,
    ) async {
      tester.platformDispatcher.localesTestValue = const <Locale>[
        Locale('id', 'ID'),
      ];
      addTearDown(tester.platformDispatcher.clearLocalesTestValue);

      await tester.pumpWidget(await _app(_FakePrivacyRepo()));
      await tester.pumpAndSettle();

      expect(find.text('Pengaturan Akun'), findsOneWidget);
      expect(find.text('Default sistem'), findsOneWidget);
    });

    testWidgets('falls back to English for an unsupported device language', (
      WidgetTester tester,
    ) async {
      tester.platformDispatcher.localesTestValue = const <Locale>[
        Locale('ja', 'JP'),
      ];
      addTearDown(tester.platformDispatcher.clearLocalesTestValue);

      await tester.pumpWidget(await _app(_FakePrivacyRepo()));
      await tester.pumpAndSettle();

      expect(find.text('Account Settings'), findsOneWidget);
    });

    testWidgets('an explicit English choice overrides an Indonesian device', (
      WidgetTester tester,
    ) async {
      tester.platformDispatcher.localesTestValue = const <Locale>[
        Locale('id', 'ID'),
      ];
      addTearDown(tester.platformDispatcher.clearLocalesTestValue);

      await tester.pumpWidget(
        await _app(
          _FakePrivacyRepo(),
          prefs: const <String, Object>{'app.language': 'en'},
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Account Settings'), findsOneWidget);
      expect(_languageGroup(tester).groupValue, AppLanguage.english);
    });

    testWidgets(
      'switching applies immediately, keeps screen state and persists',
      (WidgetTester tester) async {
        await tester.pumpWidget(await _app(_FakePrivacyRepo()));
        await tester.pumpAndSettle();

        await _scrollTo(tester, find.text('Show favorites'));
        await tester.tap(find.text('Show favorites'));
        await tester.pumpAndSettle();

        await _scrollTo(tester, find.text('Bahasa Indonesia'));
        await tester.tap(find.text('Bahasa Indonesia'));
        await tester.pumpAndSettle();

        expect(find.text('Pengaturan Akun'), findsOneWidget);
        expect(find.text('Bahasa diperbarui'), findsOneWidget);
        expect(_languageGroup(tester).groupValue, AppLanguage.indonesian);
        expect(find.text('Privasi'), findsOneWidget);
        expect(_switch(tester, 'Tampilkan favorit').value, isFalse);

        final prefs = await SharedPreferences.getInstance();
        expect(prefs.getString('app.language'), 'id');
      },
    );

    testWidgets('a saved choice is restored after restart', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        await _app(
          _FakePrivacyRepo(),
          prefs: const <String, Object>{'app.language': 'id'},
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Pengaturan Akun'), findsOneWidget);
      expect(_languageGroup(tester).groupValue, AppLanguage.indonesian);
    });

    testWidgets('guests can change the language too', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(await _app(_FakePrivacyRepo(), signedIn: false));
      await tester.pumpAndSettle();

      await _scrollTo(tester, find.text('Bahasa Indonesia'));
      await tester.tap(find.text('Bahasa Indonesia'));
      await tester.pumpAndSettle();

      expect(find.text('Pengaturan Akun'), findsOneWidget);
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('app.language'), 'id');
    });
  });
}
