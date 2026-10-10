import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gamediscoveries_mobile/core/l10n/locale_resolution.dart';
import 'package:gamediscoveries_mobile/core/utils/formatters.dart';
import 'package:gamediscoveries_mobile/features/favorites/data/library_repository.dart';
import 'package:gamediscoveries_mobile/features/favorites/presentation/continue_playing_section.dart';
import 'package:gamediscoveries_mobile/features/favorites/presentation/library_providers.dart';
import 'package:gamediscoveries_mobile/shared/models/game_summary.dart';
import 'package:go_router/go_router.dart';

import '../../helpers/localized_app.dart';

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
    child: localizedRouterApp(router),
  );
}

void main() {
  test('formatPlayTime', () {
    final en = lookupAppLocalizations(const Locale('en'));
    expect(formatPlayTime(en, 0), '<1m');
    expect(formatPlayTime(en, 59), '<1m');
    expect(formatPlayTime(en, 720), '12m');
    expect(formatPlayTime(en, 3600), '1h');
    expect(formatPlayTime(en, 3900), '1h 5m');

    final id = lookupAppLocalizations(const Locale('id'));
    expect(formatPlayTime(id, 30), '<1 mnt');
    expect(formatPlayTime(id, 3900), '1 j 5 mnt');
  });

  test('details prefers server total and shows last platform', () {
    final en = lookupAppLocalizations(const Locale('en'));
    final details = ContinuePlayingCard.details(
      en,
      _entry('Cut Rope', total: 3900, duration: 60, platform: 'WEB'),
    );
    expect(details, startsWith('on Web · '));
    expect(details, endsWith(' · 1h 5m total'));

    expect(
      ContinuePlayingCard.details(en, _entry('Old', duration: 120)),
      isNot(contains('on ')),
    );

    final id = lookupAppLocalizations(const Locale('id'));
    final localized = ContinuePlayingCard.details(
      id,
      _entry('Cut Rope', total: 3900, platform: 'WEB'),
    );
    expect(localized, startsWith('di Web · '));
    expect(localized, endsWith(' · total 1 j 5 mnt'));
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
