import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gamediscoveries_mobile/core/l10n/app_language.dart';
import 'package:gamediscoveries_mobile/core/network/api_exception.dart';
import 'package:gamediscoveries_mobile/core/storage/local_preferences.dart';
import 'package:gamediscoveries_mobile/features/auth/domain/models/auth_session_state.dart';
import 'package:gamediscoveries_mobile/features/auth/domain/models/auth_user.dart';
import 'package:gamediscoveries_mobile/features/auth/presentation/providers/auth_session_controller.dart';
import 'package:gamediscoveries_mobile/features/profile/data/preferences_repository.dart';
import 'package:gamediscoveries_mobile/features/profile/presentation/language_sync.dart';
import 'package:shared_preferences/shared_preferences.dart';

AuthUser _user({String? language, String id = 'u1'}) => AuthUser(
  id: id,
  email: 'rudi@example.com',
  displayName: 'Rudi',
  roles: const <String>[],
  preferredLanguage: language,
);

class _Session extends AuthSessionController {
  _Session(this._initial);

  final AuthSessionState _initial;

  @override
  Future<AuthSessionState> build() async => _initial;

  void signIn(AuthUser user) =>
      state = AsyncData<AuthSessionState>(AuthSessionState.authenticated(user));
}

class _FakeRepo implements PreferencesRepository {
  bool fail = false;
  final List<AppLanguage> sent = <AppLanguage>[];

  @override
  Future<AuthUser> updateLanguage(AppLanguage language) async {
    if (fail) {
      throw const ApiException(message: 'offline', type: 'connectionError');
    }
    sent.add(language);
    return _user(language: language.code);
  }
}

Future<(ProviderContainer, _FakeRepo, SharedPreferences)> _setUp({
  AuthSessionState session = const AuthSessionState.guest(),
  Map<String, Object> prefs = const <String, Object>{},
}) async {
  SharedPreferences.setMockInitialValues(prefs);
  final sharedPrefs = await SharedPreferences.getInstance();
  final repo = _FakeRepo();
  final container = ProviderContainer(
    overrides: [
      sharedPreferencesProvider.overrideWithValue(sharedPrefs),
      authSessionControllerProvider.overrideWith(() => _Session(session)),
      preferencesRepositoryProvider.overrideWithValue(repo),
    ],
  );
  addTearDown(container.dispose);
  container.listen<void>(languageSyncProvider, (_, _) {});
  await container.read(authSessionControllerProvider.future);
  await _settle();
  return (container, repo, sharedPrefs);
}

Future<void> _settle() => Future<void>.delayed(Duration.zero);

_Session _session(ProviderContainer c) =>
    c.read(authSessionControllerProvider.notifier) as _Session;

void main() {
  test('a restored session applies the account language', () async {
    final (container, repo, prefs) = await _setUp(
      session: AuthSessionState.authenticated(_user(language: 'id')),
    );

    expect(container.read(appLanguageProvider), AppLanguage.indonesian);
    expect(prefs.getString('app.language'), 'id');
    expect(repo.sent, isEmpty);
  });

  test('a choice made as a guest is uploaded on sign-in', () async {
    final (container, repo, prefs) = await _setUp();

    await container
        .read(appLanguageProvider.notifier)
        .select(AppLanguage.indonesian);
    await _settle();
    expect(repo.sent, isEmpty);

    _session(container).signIn(_user(language: 'en'));
    await _settle();

    expect(repo.sent, <AppLanguage>[AppLanguage.indonesian]);
    expect(container.read(appLanguageProvider), AppLanguage.indonesian);
    expect(prefs.getBool('app.language.needsSync'), isFalse);
    expect(
      container
          .read(authSessionControllerProvider)
          .value
          ?.user
          ?.preferredLanguage,
      'id',
    );
  });

  test('changes while signed in are uploaded right away', () async {
    final (container, repo, _) = await _setUp(
      session: AuthSessionState.authenticated(_user(language: 'SYSTEM')),
    );

    await container
        .read(appLanguageProvider.notifier)
        .select(AppLanguage.english);
    await _settle();

    expect(repo.sent, <AppLanguage>[AppLanguage.english]);
  });

  test('a failed upload is retried on the next sign-in', () async {
    final (container, repo, prefs) = await _setUp(
      session: AuthSessionState.authenticated(_user(language: 'en')),
    );
    repo.fail = true;

    await container
        .read(appLanguageProvider.notifier)
        .select(AppLanguage.indonesian);
    await _settle();
    expect(prefs.getBool('app.language.needsSync'), isTrue);

    repo.fail = false;
    _session(container).signIn(_user(id: 'u2', language: 'en'));
    await _settle();

    expect(repo.sent, <AppLanguage>[AppLanguage.indonesian]);
    expect(container.read(appLanguageProvider), AppLanguage.indonesian);
  });

  test('switching back to SYSTEM is saved too', () async {
    final (container, repo, _) = await _setUp(
      session: AuthSessionState.authenticated(_user(language: 'id')),
    );
    expect(container.read(appLanguageProvider), AppLanguage.indonesian);

    await container
        .read(appLanguageProvider.notifier)
        .select(AppLanguage.system);
    await _settle();

    expect(repo.sent, <AppLanguage>[AppLanguage.system]);
    expect(container.read(appLanguageProvider), AppLanguage.system);
  });

  test('older API without the field keeps the local language', () async {
    final (container, repo, _) = await _setUp(
      session: AuthSessionState.authenticated(_user()),
      prefs: const <String, Object>{
        'app.language': 'en',
        'app.language.needsSync': false,
      },
    );

    expect(container.read(appLanguageProvider), AppLanguage.english);
    expect(repo.sent, isEmpty);
  });
}
