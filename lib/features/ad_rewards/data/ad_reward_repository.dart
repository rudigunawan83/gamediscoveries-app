import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/providers/network_providers.dart';
import '../../../core/utils/formatters.dart';

class AdRewardStatus {
  const AdRewardStatus({
    required this.enabled,
    required this.xpPerAd,
    required this.dailyLimit,
    required this.watchedToday,
    required this.remainingToday,
  });

  factory AdRewardStatus.fromJson(Map<String, dynamic> json) {
    return AdRewardStatus(
      enabled: json['enabled'] as bool? ?? false,
      xpPerAd: parseInt(json['xpPerAd']),
      dailyLimit: parseInt(json['dailyLimit']),
      watchedToday: parseInt(json['watchedToday']),
      remainingToday: parseInt(json['remainingToday']),
    );
  }

  final bool enabled;
  final int xpPerAd;
  final int dailyLimit;
  final int watchedToday;
  final int remainingToday;
}

/// Server ticket the rewarded ad carries as SSV custom data. XP is granted
/// only when AdMob calls the backend with it, never by the app.
class AdRewardTicket {
  const AdRewardTicket({
    required this.ticketId,
    required this.customData,
    required this.userId,
    required this.xpReward,
  });

  factory AdRewardTicket.fromJson(Map<String, dynamic> json) {
    return AdRewardTicket(
      ticketId: json['ticketId'] as String? ?? '',
      customData: json['customData'] as String? ?? '',
      userId: json['userId'] as String? ?? '',
      xpReward: parseInt(json['xpReward']),
    );
  }

  final String ticketId;
  final String customData;
  final String userId;
  final int xpReward;
}

class AdRewardTicketState {
  const AdRewardTicketState({
    required this.status,
    required this.xpAwarded,
    this.reason,
  });

  factory AdRewardTicketState.fromJson(Map<String, dynamic> json) {
    return AdRewardTicketState(
      status: json['status'] as String? ?? 'PENDING',
      xpAwarded: parseInt(json['xpAwarded']),
      reason: json['reason'] as String?,
    );
  }

  final String status;
  final int xpAwarded;
  final String? reason;

  bool get isPending => status == 'PENDING';
  bool get isRewarded => status == 'REWARDED';
}

class AdRewardRepository {
  const AdRewardRepository(this._api);

  final ApiClient _api;

  Future<AdRewardStatus> getStatus() {
    return _api.get<AdRewardStatus>(
      '/api/v1/me/ad-rewards',
      parser: (Object? json) =>
          AdRewardStatus.fromJson(json as Map<String, dynamic>? ?? const {}),
    );
  }

  Future<AdRewardTicket> createTicket({required String platform}) {
    return _api.post<AdRewardTicket>(
      '/api/v1/me/ad-rewards/tickets',
      body: <String, dynamic>{'platform': platform},
      parser: (Object? json) =>
          AdRewardTicket.fromJson(json as Map<String, dynamic>? ?? const {}),
    );
  }

  Future<AdRewardTicketState> getTicket(String ticketId) {
    return _api.get<AdRewardTicketState>(
      '/api/v1/me/ad-rewards/tickets/${Uri.encodeComponent(ticketId)}',
      parser: (Object? json) => AdRewardTicketState.fromJson(
        json as Map<String, dynamic>? ?? const {},
      ),
    );
  }
}

final adRewardRepositoryProvider = Provider<AdRewardRepository>((Ref ref) {
  return AdRewardRepository(ref.watch(apiClientProvider));
});
