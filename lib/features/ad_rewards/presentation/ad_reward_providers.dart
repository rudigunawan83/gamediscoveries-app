import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_exception.dart';
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

class AdRewardOutcome {
  const AdRewardOutcome(this.message, {this.xp = 0});

  final String message;

  /// XP confirmed by the server, 0 when nothing was granted (yet).
  final int xp;
}

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
      return const AdRewardOutcome('Rewarded videos are not available.');
    }

    try {
      final ticket = await _repository.createTicket(platform: platform);
      final earned = await _player.show(
        userId: ticket.userId,
        customData: ticket.customData,
      );
      if (!earned) {
        return const AdRewardOutcome('Watch the full video to earn XP.');
      }

      for (var i = 0; i < pollAttempts; i++) {
        await Future<void>.delayed(pollInterval);
        final state = await _repository.getTicket(ticket.ticketId);
        if (state.isPending) continue;
        if (state.isRewarded && state.xpAwarded > 0) {
          return AdRewardOutcome(
            '+${state.xpAwarded} XP added!',
            xp: state.xpAwarded,
          );
        }
        return AdRewardOutcome(_reasonMessage(state.reason));
      }
      return AdRewardOutcome(
        'Thanks! Your +${ticket.xpReward} XP will appear once the view is verified.',
      );
    } on RewardedAdUnavailable catch (e) {
      return AdRewardOutcome(e.message);
    } on ApiException catch (e) {
      return AdRewardOutcome(e.message);
    }
  }

  static String _reasonMessage(String? reason) => switch (reason) {
    'DAILY_LIMIT_REACHED' => "You've used all rewarded videos for today.",
    'DAILY_XP_CAP_REACHED' => 'Daily XP cap reached, no XP this time.',
    'EXPIRED' => 'That took too long. Please try again.',
    _ => "This view couldn't be verified.",
  };
}

final adRewardFlowProvider = Provider<AdRewardFlow>((Ref ref) {
  return AdRewardFlow(
    ref.watch(adRewardRepositoryProvider),
    ref.watch(rewardedAdPlayerProvider),
  );
});
