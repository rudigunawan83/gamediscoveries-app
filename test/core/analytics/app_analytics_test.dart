import 'package:flutter_test/flutter_test.dart';
import 'package:gamediscoveries_mobile/core/analytics/app_analytics.dart';

void main() {
  late List<List<Map<String, Object?>>> sent;
  late DateTime now;
  late bool failSend;

  AppAnalytics build() => AppAnalytics(
    send: (List<Map<String, Object?>> events) async {
      if (failSend) throw Exception('offline');
      sent.add(events);
    },
    anonymousId: () => 'anon-1',
    platform: 'ANDROID',
    appVersion: () async => '1.0.4+5',
    clock: () => now,
    flushDelay: const Duration(milliseconds: 10),
  );

  setUp(() {
    sent = <List<Map<String, Object?>>>[];
    now = DateTime.utc(2026, 10, 11, 12);
    failSend = false;
  });

  test('sends screen views as mobile app events', () async {
    final analytics = build();
    analytics.screenView('/home');
    await analytics.flush();

    final event = sent.single.single;
    expect(event['eventType'], 'SCREEN_VIEW');
    expect(event['source'], 'MOBILE');
    expect(event['platform'], 'ANDROID');
    expect(event['deviceType'], 'MOBILE');
    expect(event['anonymousId'], 'anon-1');
    expect(event['pageUrl'], 'app://gamediscoveries/home');
    expect(event['occurredAt'], '2026-10-11T12:00:00.000Z');
    expect(event.containsKey('userId'), isFalse);
    analytics.dispose();
  });

  test('skips repeated screens and too-short searches', () {
    final analytics = build();
    analytics.screenView('/home');
    analytics.screenView('/home');
    analytics.search('a');
    analytics.search('  puzzle ');
    analytics.search('puzzle');

    final events = analytics.pending;
    expect(events.map((e) => e['eventType']), <String>['SCREEN_VIEW', 'SEARCH']);
    expect(events.last['metadata'], <String, Object?>{'query': 'puzzle'});
    expect(events.last['pageUrl'], 'app://gamediscoveries/home');
    analytics.dispose();
  });

  test('reports game load outcomes with the game id', () {
    final analytics = build();
    analytics.gameLoaded('g-1', loadMs: 1200);
    analytics.gameLoadFailed('g-2', reason: 'load_timeout');

    final events = analytics.pending;
    expect(events.map((e) => e['eventType']), <String>[
      'GAME_LOADED',
      'GAME_LOAD_FAILED',
    ]);
    expect(events.first['gameId'], 'g-1');
    expect(events.first['metadata'], <String, Object?>{'loadMs': 1200});
    expect(events.last['metadata'], <String, Object?>{'reason': 'load_timeout'});
    analytics.screenView('/home');
    expect(analytics.pending.last.containsKey('gameId'), isFalse);
    analytics.dispose();
  });

  test('starts a new session after 30 minutes of inactivity', () {
    final analytics = build();
    analytics.screenView('/home');
    now = now.add(const Duration(minutes: 10));
    analytics.screenView('/discover');
    now = now.add(const Duration(minutes: 31));
    analytics.screenView('/play');

    final sessions = analytics.pending.map((e) => e['sessionId']).toList();
    expect(sessions[0], sessions[1]);
    expect(sessions[2], isNot(sessions[1]));
    analytics.dispose();
  });

  test('keeps events when sending fails and retries later', () async {
    final analytics = build();
    failSend = true;
    analytics.screenView('/home');
    await analytics.flush();
    expect(analytics.pending, hasLength(1));

    failSend = false;
    await analytics.flush();
    expect(analytics.pending, isEmpty);
    expect(sent.single, hasLength(1));
    analytics.dispose();
  });

  test('flushes automatically after the delay', () async {
    final analytics = build();
    analytics.screenView('/home');
    await Future<void>.delayed(const Duration(milliseconds: 30));

    expect(sent, hasLength(1));
    expect(sent.single.single['appVersion'], isNull);
    analytics.screenView('/discover');
    await analytics.flush();
    expect(sent.last.single['appVersion'], '1.0.4+5');
    analytics.dispose();
  });
}
