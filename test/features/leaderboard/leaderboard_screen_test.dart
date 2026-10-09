import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gamediscoveries_mobile/features/auth/domain/models/auth_session_state.dart';
import 'package:gamediscoveries_mobile/features/auth/domain/models/auth_user.dart';
import 'package:gamediscoveries_mobile/features/auth/presentation/providers/auth_session_controller.dart';
import 'package:gamediscoveries_mobile/features/leaderboard/data/leaderboard_repository.dart';
import 'package:gamediscoveries_mobile/features/leaderboard/domain/leaderboard_models.dart';
import 'package:gamediscoveries_mobile/features/leaderboard/presentation/leaderboard_screen.dart';
import 'package:gamediscoveries_mobile/features/notifications/presentation/notifications_providers.dart';

class _SignedIn extends AuthSessionController {
  @override
  Future<AuthSessionState> build() async =>
      const AuthSessionState.authenticated(
        AuthUser(
          id: 'me',
          email: 'me@example.com',
          displayName: 'Rudi',
          roles: <String>['Player'],
        ),
      );
}

LeaderboardEntry _entry(int rank, String name, int score, {int? level}) =>
    LeaderboardEntry(
      rank: rank,
      userId: 'u$rank',
      name: name,
      score: score,
      gamesPlayed: 7,
      level: level,
    );

class _FakeRepository implements LeaderboardRepository {
  final List<String> requested = <String>[];

  @override
  Future<List<LeaderboardSummary>> listLeaderboards() async =>
      const <LeaderboardSummary>[
        LeaderboardSummary(code: 'GLOBAL', name: 'Global', type: 'ALL_TIME'),
        LeaderboardSummary(code: 'WEEKLY', name: 'Weekly', type: 'WEEKLY'),
      ];

  @override
  Future<LeaderboardDetail> getLeaderboard(
    String code, {
    int limit = 50,
  }) async {
    requested.add(code);
    return LeaderboardDetail(
      name: code,
      totalParticipants: 60,
      items: <LeaderboardEntry>[
        _entry(1, 'RizkyGamer', 29450, level: 30),
        _entry(2, 'LunaPlay', 22340, level: 27),
        _entry(3, 'DanuBlitz', 21750, level: 26),
        _entry(4, 'AyuGame', 18320, level: 18),
        _entry(5, 'GameMaster', 17890),
      ],
      me: LeaderboardEntry(
        rank: 47,
        userId: 'me',
        name: 'Rudi',
        score: 18450,
        gamesPlayed: 3,
        level: 12,
      ),
    );
  }
}

Widget _app(_FakeRepository repository) {
  return ProviderScope(
    retry: (int retryCount, Object error) => null,
    overrides: [
      authSessionControllerProvider.overrideWith(_SignedIn.new),
      leaderboardRepositoryProvider.overrideWithValue(repository),
      notificationsProvider.overrideWith((Ref ref) async => null),
    ],
    child: const MaterialApp(home: LeaderboardScreen()),
  );
}

void main() {
  testWidgets('shows podium, ranked rows with level and my docked rank', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(_app(_FakeRepository()));
    await tester.pumpAndSettle();

    expect(find.text('Leaderboard'), findsOneWidget);
    for (final label in <String>['Global', 'Weekly', 'Monthly']) {
      expect(find.text(label), findsOneWidget);
    }
    expect(find.text('RizkyGamer'), findsOneWidget);
    expect(find.text('29,450 XP'), findsOneWidget);
    expect(find.text('AyuGame'), findsOneWidget);
    expect(find.text('Lv 18'), findsOneWidget);
    expect(find.text('7 games played'), findsOneWidget);
    expect(find.text('#47'), findsOneWidget);
    expect(find.text('You'), findsOneWidget);
    expect(find.text('Lv 12'), findsOneWidget);
    expect(find.text('18,450 XP'), findsOneWidget);
  });

  testWidgets('switching scope loads that leaderboard', (
    WidgetTester tester,
  ) async {
    final repository = _FakeRepository();
    await tester.pumpWidget(_app(repository));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Weekly'));
    await tester.pumpAndSettle();
    expect(repository.requested, contains('WEEKLY'));

    await tester.tap(find.text('Monthly'));
    await tester.pumpAndSettle();
    expect(find.text('No rankings yet'), findsOneWidget);
  });

  testWidgets('small phone with large text does not overflow', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1;
    tester.platformDispatcher.textScaleFactorTestValue = 1.4;
    addTearDown(tester.view.reset);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

    await tester.pumpWidget(_app(_FakeRepository()));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
  });
}
