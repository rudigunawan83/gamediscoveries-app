import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/errors/error_messages.dart';
import '../../../core/network/api_exception.dart';
import '../../../l10n/app_localizations.dart';
import '../../auth/presentation/providers/auth_session_controller.dart';
import '../data/ad_reward_repository.dart';
import '../data/rewarded_ad_player.dart';

/// `null` when the viewer is a guest or rewarded ads are not set up on this
/// device; the Watch & Earn card is hidden then.
final adRewardStatusProvider = FutureProvider<AdRewardStatus?>((Ref ref) async {
  if (!await ref.watch(isSignedInProvider.future)) return null;
  if (ref.watch(rewardedAdPlayerProvider).platform == null) return null;
  final status = await ref.watch(adRewardRepositoryProvider).getStatus();
  return status.enabled ? status : null;
});

enum AdRewardResult {
  unavailable,
  noVideo,
  showFailed,
  notCompleted,
  granted,
  pending,
  dailyLimit,
  dailyXpCap,
  expired,
  unverified,
  failed,
}

class AdRewardOutcome {
  const AdRewardOutcome(
    this.result, {
    this.xp = 0,
    this.expectedXp = 0,
    this.error,
  });

  final AdRewardResult result;

  /// XP confirmed by the server, 0 when nothing was granted (yet).
  final int xp;

  /// XP the ticket is worth while the server has not confirmed the view.
  final int expectedXp;

  /// Set when [result] is [AdRewardResult.failed].
  final Object? error;
}

String adRewardMessage(AppLocalizations l10n, AdRewardOutcome outcome) =>
    switch (outcome.result) {
      AdRewardResult.unavailable => l10n.adRewardUnavailable,
      AdRewardResult.noVideo => l10n.adRewardNoVideo,
      AdRewardResult.showFailed => l10n.adRewardShowFailed,
      AdRewardResult.notCompleted => l10n.adRewardNotCompleted,
      AdRewardResult.granted => l10n.adRewardGranted(outcome.xp),
      AdRewardResult.pending => l10n.adRewardPending(outcome.expectedXp),
      AdRewardResult.dailyLimit => l10n.adRewardDailyLimit,
      AdRewardResult.dailyXpCap => l10n.adRewardDailyXpCap,
      AdRewardResult.expired => l10n.adRewardExpired,
      AdRewardResult.unverified => l10n.adRewardUnverified,
      AdRewardResult.failed => switch (outcome.error) {
        final Object error => friendlyErrorMessage(l10n, error),
        null => l10n.errorGeneric,
      },
    };

/// Ticket → rewarded video → wait for the backend to confirm AdMob's
/// server-side verification. The app never reports XP itself.
class AdRewardFlow {
  const AdRewardFlow(
    this._repository,
    this._player, {
    this.pollInterval = const Duration(seconds: 2),
    this.pollAttempts = 6,
  });

  final AdRewardRepository _repository;
  final RewardedAdPlayer _player;
  final Duration pollInterval;
  final int pollAttempts;

  Future<AdRewardOutcome> watch() async {
    final platform = _player.platform;
    if (platform == null) {
      return const AdRewardOutcome(AdRewardResult.unavailable);
    }

    try {
      final ticket = await _repository.createTicket(platform: platform);
      final earned = await _player.show(
        userId: ticket.userId,
        customData: ticket.customData,
      );
      if (!earned) {
        return const AdRewardOutcome(AdRewardResult.notCompleted);
      }

      for (var i = 0; i < pollAttempts; i++) {
        await Future<void>.delayed(pollInterval);
        final state = await _repository.getTicket(ticket.ticketId);
        if (state.isPending) continue;
        if (state.isRewarded && state.xpAwarded > 0) {
          return AdRewardOutcome(AdRewardResult.granted, xp: state.xpAwarded);
        }
        return AdRewardOutcome(_rejection(state.reason));
      }
      return AdRewardOutcome(
        AdRewardResult.pending,
        expectedXp: ticket.xpReward,
      );
    } on RewardedAdUnavailable catch (e) {
      return AdRewardOutcome(switch (e.reason) {
        RewardedAdFailure.notConfigured => AdRewardResult.unavailable,
        RewardedAdFailure.noVideo => AdRewardResult.noVideo,
        RewardedAdFailure.showFailed => AdRewardResult.showFailed,
      });
    } on ApiException catch (e) {
      return AdRewardOutcome(AdRewardResult.failed, error: e);
    }
  }

  static AdRewardResult _rejection(String? reason) => switch (reason) {
    'DAILY_LIMIT_REACHED' => AdRewardResult.dailyLimit,
    'DAILY_XP_CAP_REACHED' => AdRewardResult.dailyXpCap,
    'EXPIRED' => AdRewardResult.expired,
    _ => AdRewardResult.unverified,
  };
}

final adRewardFlowProvider = Provider<AdRewardFlow>((Ref ref) {
  return AdRewardFlow(
    ref.watch(adRewardRepositoryProvider),
    ref.watch(rewardedAdPlayerProvider),
  );
});
