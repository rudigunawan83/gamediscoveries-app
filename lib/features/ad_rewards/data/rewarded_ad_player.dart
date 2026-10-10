import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../../../app/config/app_config.dart';

class RewardedAdUnavailable implements Exception {
  const RewardedAdUnavailable(this.message);

  final String message;

  @override
  String toString() => message;
}

/// Loads and shows one rewarded video tagged for server-side verification.
abstract class RewardedAdPlayer {
  /// `ANDROID` / `IOS`, or null when rewarded ads are not configured here.
  String? get platform;

  /// Returns true when the viewer watched long enough to earn the reward.
  Future<bool> show({required String userId, required String customData});
}

class AdMobRewardedAdPlayer implements RewardedAdPlayer {
  // Google's public sample units. Debug builds always use them: showing real
  // ads to ourselves counts as invalid traffic and can get the account banned.
  static const String _testAndroidUnit =
      'ca-app-pub-3940256099942544/5224354917';
  static const String _testIosUnit = 'ca-app-pub-3940256099942544/1712485313';

  Future<InitializationStatus>? _initialized;

  String? get _adUnitId {
    if (kIsWeb) return null;
    if (Platform.isAndroid) {
      return _orTestUnit(AppConfig.admobRewardedAndroid, _testAndroidUnit);
    }
    if (Platform.isIOS) {
      return _orTestUnit(AppConfig.admobRewardedIos, _testIosUnit);
    }
    return null;
  }

  static String? _orTestUnit(String configured, String testUnit) {
    if (!kReleaseMode) return testUnit;
    return configured.isEmpty ? null : configured;
  }

  @override
  String? get platform {
    if (_adUnitId == null) return null;
    return Platform.isIOS ? 'IOS' : 'ANDROID';
  }

  static Future<InitializationStatus> _initialize() async {
    final testDevices = AppConfig.admobTestDevices;
    if (testDevices.isNotEmpty) {
      await MobileAds.instance.updateRequestConfiguration(
        RequestConfiguration(testDeviceIds: testDevices),
      );
    }
    return MobileAds.instance.initialize();
  }

  @override
  Future<bool> show({
    required String userId,
    required String customData,
  }) async {
    final unitId = _adUnitId;
    if (unitId == null) {
      throw const RewardedAdUnavailable('Rewarded ads are not available.');
    }

    await (_initialized ??= _initialize());

    final loaded = Completer<RewardedAd>();
    await RewardedAd.load(
      adUnitId: unitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: loaded.complete,
        onAdFailedToLoad: (LoadAdError error) => loaded.completeError(
          const RewardedAdUnavailable('No video available right now.'),
        ),
      ),
    );
    final ad = await loaded.future.timeout(
      const Duration(seconds: 30),
      onTimeout: () =>
          throw const RewardedAdUnavailable('No video available right now.'),
    );

    await ad.setServerSideOptions(
      ServerSideVerificationOptions(userId: userId, customData: customData),
    );

    var earned = false;
    final closed = Completer<void>();
    ad.fullScreenContentCallback = FullScreenContentCallback<RewardedAd>(
      onAdDismissedFullScreenContent: (RewardedAd ad) {
        ad.dispose();
        if (!closed.isCompleted) closed.complete();
      },
      onAdFailedToShowFullScreenContent: (RewardedAd ad, AdError error) {
        ad.dispose();
        if (!closed.isCompleted) {
          closed.completeError(
            const RewardedAdUnavailable('The video could not be shown.'),
          );
        }
      },
    );
    await ad.show(
      onUserEarnedReward: (AdWithoutView ad, RewardItem reward) =>
          earned = true,
    );
    await closed.future;
    return earned;
  }
}

final rewardedAdPlayerProvider = Provider<RewardedAdPlayer>(
  (Ref ref) => AdMobRewardedAdPlayer(),
);
