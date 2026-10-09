import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gamediscoveries_mobile/core/network/api_exception.dart';
import 'package:gamediscoveries_mobile/features/auth/domain/models/auth_session_state.dart';
import 'package:gamediscoveries_mobile/features/auth/domain/models/auth_user.dart';
import 'package:gamediscoveries_mobile/features/auth/presentation/providers/auth_session_controller.dart';
import 'package:gamediscoveries_mobile/features/profile/data/privacy_repository.dart';
import 'package:gamediscoveries_mobile/features/profile/domain/privacy_settings.dart';
import 'package:gamediscoveries_mobile/features/profile/presentation/account_settings_screen.dart';

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

Widget _app(_FakePrivacyRepo repo) {
  return ProviderScope(
    retry: (int retryCount, Object error) => null,
    overrides: [
      authSessionControllerProvider.overrideWith(_SignedIn.new),
      privacyRepositoryProvider.overrideWithValue(repo),
    ],
    child: const MaterialApp(home: AccountSettingsScreen()),
  );
}

SwitchListTile _switch(WidgetTester tester, String title) {
  return tester.widget<SwitchListTile>(
    find.ancestor(of: find.text(title), matching: find.byType(SwitchListTile)),
  );
}

void main() {
  testWidgets('shows account details and current privacy values', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(_app(_FakePrivacyRepo()));
    await tester.pumpAndSettle();

    expect(find.text('@rudi_gamer'), findsOneWidget);
    expect(find.text('rudi@example.com'), findsOneWidget);
    expect(_switch(tester, 'Show favorites').value, isTrue);
    expect(_switch(tester, 'Show play history').value, isFalse);
  });

  testWidgets('saves a privacy toggle', (WidgetTester tester) async {
    final repo = _FakePrivacyRepo();
    await tester.pumpWidget(_app(repo));
    await tester.pumpAndSettle();

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
    await tester.pumpWidget(_app(_FakePrivacyRepo(fail: true)));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Show favorites'));
    await tester.pumpAndSettle();

    expect(_switch(tester, 'Show favorites').value, isTrue);
    expect(
      find.text('Our servers are having trouble. Please try again later.'),
      findsOneWidget,
    );
  });
}
