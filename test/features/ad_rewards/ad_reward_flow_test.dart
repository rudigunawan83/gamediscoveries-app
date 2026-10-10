import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gamediscoveries_mobile/core/l10n/locale_resolution.dart';
import 'package:gamediscoveries_mobile/features/ad_rewards/data/ad_reward_repository.dart';
import 'package:gamediscoveries_mobile/features/ad_rewards/data/rewarded_ad_player.dart';
import 'package:gamediscoveries_mobile/features/ad_rewards/presentation/ad_reward_providers.dart';
import 'package:gamediscoveries_mobile/features/ad_rewards/presentation/watch_ad_reward_card.dart';

import '../../helpers/localized_app.dart';

class _FakePlayer implements RewardedAdPlayer {
  _FakePlayer({this.earned = true, this.platform = 'ANDROID'});

  final bool earned;
  @override
  final String? platform;
  final List<(String, String)> shown = <(String, String)>[];

  @override
  Future<bool> show({
    required String userId,
    required String customData,
  }) async {
    shown.add((userId, customData));
    return earned;
  }
}

class _FakeRepository implements AdRewardRepository {
  _FakeRepository(this.states);

  final List<AdRewardTicketState> states;
  int polls = 0;
  int tickets = 0;

  @override
  Future<AdRewardStatus> getStatus() async => const AdRewardStatus(
    enabled: true,
    xpPerAd: 50,
    dailyLimit: 5,
    watchedToday: 2,
    remainingToday: 3,
  );

  @override
  Future<AdRewardTicket> createTicket({required String platform}) async {
    tickets++;
    return const AdRewardTicket(
      ticketId: 't-1',
      customData: 'secret-token',
      userId: 'user-1',
      xpReward: 50,
    );
  }

  @override
  Future<AdRewardTicketState> getTicket(String ticketId) async =>
      states[(polls++).clamp(0, states.length - 1)];
}

class _ThrowingPlayer implements RewardedAdPlayer {
  _ThrowingPlayer(this.failure);

  final RewardedAdFailure failure;

  @override
  String? get platform => 'ANDROID';

  @override
  Future<bool> show({required String userId, required String customData}) =>
      throw RewardedAdUnavailable(failure);
}

final _en = lookupAppLocalizations(const Locale('en'));
final _id = lookupAppLocalizations(const Locale('id'));

const _pending = AdRewardTicketState(status: 'PENDING', xpAwarded: 0);
const _rewarded = AdRewardTicketState(status: 'REWARDED', xpAwarded: 50);

AdRewardFlow _flow(_FakeRepository repo, _FakePlayer player) =>
    AdRewardFlow(repo, player, pollInterval: Duration.zero, pollAttempts: 3);

void main() {
  test('passes the server ticket to the ad and reports verified XP', () async {
    final repo = _FakeRepository(<AdRewardTicketState>[_pending, _rewarded]);
    final player = _FakePlayer();

    final outcome = await _flow(repo, player).watch();

    expect(player.shown.single, ('user-1', 'secret-token'));
    expect(outcome.result, AdRewardResult.granted);
    expect(outcome.xp, 50);
    expect(adRewardMessage(_en, outcome), '+50 XP added!');
    expect(adRewardMessage(_id, outcome), '+50 XP ditambahkan!');
  });

  test('skipping the video grants nothing and does not poll', () async {
    final repo = _FakeRepository(<AdRewardTicketState>[_rewarded]);

    final outcome = await _flow(repo, _FakePlayer(earned: false)).watch();

    expect(outcome.xp, 0);
    expect(repo.polls, 0);
    expect(outcome.result, AdRewardResult.notCompleted);
    expect(adRewardMessage(_en, outcome), contains('full video'));
  });

  test('unverified view stays pending without claiming XP', () async {
    final repo = _FakeRepository(<AdRewardTicketState>[_pending]);

    final outcome = await _flow(repo, _FakePlayer()).watch();

    expect(outcome.xp, 0);
    expect(repo.polls, 3);
    expect(outcome.result, AdRewardResult.pending);
    expect(
      adRewardMessage(_en, outcome),
      contains('+50 XP will appear once the view is verified'),
    );
  });

  test('server rejection is explained', () async {
    final repo = _FakeRepository(<AdRewardTicketState>[
      const AdRewardTicketState(
        status: 'REJECTED',
        xpAwarded: 0,
        reason: 'DAILY_LIMIT_REACHED',
      ),
    ]);

    final outcome = await _flow(repo, _FakePlayer()).watch();

    expect(outcome.xp, 0);
    expect(outcome.result, AdRewardResult.dailyLimit);
    expect(adRewardMessage(_en, outcome), contains('all rewarded videos'));
    expect(adRewardMessage(_id, outcome), contains('sudah habis'));
  });

  test('ad player failures map to localized reasons', () async {
    final repo = _FakeRepository(<AdRewardTicketState>[_rewarded]);
    final flow = AdRewardFlow(
      repo,
      _ThrowingPlayer(RewardedAdFailure.noVideo),
      pollInterval: Duration.zero,
      pollAttempts: 1,
    );

    final outcome = await flow.watch();

    expect(outcome.result, AdRewardResult.noVideo);
    expect(adRewardMessage(_id, outcome), 'Belum ada video saat ini.');
  });

  test('unsupported device does not request a ticket', () async {
    final repo = _FakeRepository(<AdRewardTicketState>[_rewarded]);

    final outcome = await _flow(repo, _FakePlayer(platform: null)).watch();

    expect(repo.tickets, 0);
    expect(outcome.xp, 0);
    expect(outcome.result, AdRewardResult.unavailable);
  });

  testWidgets('card shows XP per video and remaining views', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          adRewardStatusProvider.overrideWith(
            (Ref ref) async => const AdRewardStatus(
              enabled: true,
              xpPerAd: 50,
              dailyLimit: 5,
              watchedToday: 2,
              remainingToday: 3,
            ),
          ),
        ],
        child: localizedApp(home: const Scaffold(body: WatchAdRewardCard())),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Watch & Earn'), findsOneWidget);
    expect(find.textContaining('+50 XP · 3/5 left today'), findsOneWidget);
    expect(find.widgetWithText(FilledButton, '+50 XP'), findsOneWidget);
  });

  testWidgets('card is translated to Indonesian', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          adRewardStatusProvider.overrideWith(
            (Ref ref) async => const AdRewardStatus(
              enabled: true,
              xpPerAd: 50,
              dailyLimit: 5,
              watchedToday: 5,
              remainingToday: 0,
            ),
          ),
        ],
        child: localizedApp(
          home: const Scaffold(body: WatchAdRewardCard()),
          locale: const Locale('id'),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Tonton & Raih XP'), findsOneWidget);
    expect(
      find.text('Semua 5 video sudah ditonton. Kembali lagi besok!'),
      findsOneWidget,
    );
  });

  testWidgets('card is hidden when rewarded ads are off', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          adRewardStatusProvider.overrideWith((Ref ref) async => null),
        ],
        child: localizedApp(home: const Scaffold(body: WatchAdRewardCard())),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Watch & Earn'), findsNothing);
  });
}
