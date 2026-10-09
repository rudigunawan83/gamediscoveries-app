import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gamediscoveries_mobile/core/utils/formatters.dart';
import 'package:gamediscoveries_mobile/features/favorites/data/library_repository.dart';
import 'package:gamediscoveries_mobile/features/favorites/presentation/continue_playing_section.dart';
import 'package:gamediscoveries_mobile/features/favorites/presentation/library_providers.dart';
import 'package:gamediscoveries_mobile/shared/models/game_summary.dart';
import 'package:go_router/go_router.dart';

GameSummary _game(String title) => GameSummary(
  id: title,
  slug: title.toLowerCase().replaceAll(' ', '-'),
  title: title,
  category: 'Arcade',
  mobileReady: true,
);

HistoryEntry _entry(
  String title, {
  int total = 0,
  int duration = 0,
  int plays = 1,
  String? platform,
}) => HistoryEntry(
  game: _game(title),
  durationSeconds: duration,
  totalPlaySeconds: total,
  playCount: plays,
  lastPlatform: platform,
  playedAt: DateTime.now().subtract(const Duration(hours: 2)),
);

Widget _app(List<HistoryEntry>? history) {
  final router = GoRouter(
    routes: <RouteBase>[
      GoRoute(
        path: '/',
        builder: (_, _) => const Scaffold(
          body: SingleChildScrollView(child: ContinuePlayingSection()),
        ),
      ),
      GoRoute(
        path: '/game/:slug',
        builder: (_, GoRouterState s) =>
            Text('detail:${s.pathParameters['slug']}'),
        routes: <RouteBase>[
          GoRoute(
            path: 'play',
            builder: (_, GoRouterState s) =>
                Text('player:${s.pathParameters['slug']}'),
          ),
        ],
      ),
      GoRoute(path: '/history', builder: (_, _) => const Text('history')),
    ],
  );
  return ProviderScope(
    overrides: [playHistoryProvider.overrideWith((Ref ref) async => history)],
    child: MaterialApp.router(routerConfig: router),
  );
}

void main() {
  test('formatPlayTime', () {
    expect(formatPlayTime(0), '<1m');
    expect(formatPlayTime(59), '<1m');
    expect(formatPlayTime(720), '12m');
    expect(formatPlayTime(3600), '1h');
    expect(formatPlayTime(3900), '1h 5m');
  });

  test('details prefers server total and shows last platform', () {
    final details = ContinuePlayingCard.details(
      _entry('Cut Rope', total: 3900, duration: 60, platform: 'WEB'),
    );
    expect(details, startsWith('on Web · '));
    expect(details, endsWith(' · 1h 5m total'));

    expect(
      ContinuePlayingCard.details(_entry('Old', duration: 120)),
      isNot(contains('on ')),
    );
  });

  testWidgets('hidden for guests and empty history', (WidgetTester t) async {
    await t.pumpWidget(_app(null));
    await t.pumpAndSettle();
    expect(find.text('Continue Playing'), findsNothing);

    await t.pumpWidget(_app(const <HistoryEntry>[]));
    await t.pumpAndSettle();
    expect(find.text('Continue Playing'), findsNothing);
  });

  testWidgets('Continue opens the player for the last played game', (
    WidgetTester t,
  ) async {
    await t.pumpWidget(
      _app(<HistoryEntry>[
        _entry('Cut Rope', total: 3900, platform: 'ANDROID'),
        _entry('Cut Rope', total: 3900, platform: 'ANDROID'),
        _entry('Bubble Pop', total: 300, platform: 'WEB'),
      ]),
    );
    await t.pumpAndSettle();

    expect(find.text('Continue Playing'), findsOneWidget);
    expect(find.text('Cut Rope'), findsOneWidget);
    expect(find.byIcon(Icons.android_rounded), findsOneWidget);
    expect(find.text('Recently Played'), findsOneWidget);
    expect(find.text('Bubble Pop'), findsOneWidget);

    await t.tap(find.text('Continue'));
    await t.pumpAndSettle();
    expect(find.text('player:cut-rope'), findsOneWidget);
  });
}
