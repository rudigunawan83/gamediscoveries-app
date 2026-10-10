import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:in_app_update/in_app_update.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

/// Device side of app updates: installed build, install source, Play's
/// in-app update flow and opening download links.
abstract class AppUpdatePlatform {
  /// `android` / `ios`, or null where update checks don't apply.
  String? get platform;

  Future<int> currentBuild();

  Future<bool> installedFromPlayStore();

  /// Runs Google Play's in-app update UI. Returns false when Play cannot
  /// handle it (no update visible to Play yet, or not a Play install).
  Future<bool> startPlayUpdate({required bool immediate});

  Future<bool> openUrl(String url);
}

class DeviceAppUpdatePlatform implements AppUpdatePlatform {
  static const String _playStoreInstaller = 'com.android.vending';

  Future<PackageInfo>? _info;

  Future<PackageInfo> _package() => _info ??= PackageInfo.fromPlatform();

  @override
  String? get platform {
    if (kIsWeb) return null;
    if (Platform.isAndroid) return 'android';
    if (Platform.isIOS) return 'ios';
    return null;
  }

  @override
  Future<int> currentBuild() async =>
      int.tryParse((await _package()).buildNumber) ?? 0;

  @override
  Future<bool> installedFromPlayStore() async =>
      !kIsWeb &&
      Platform.isAndroid &&
      (await _package()).installerStore == _playStoreInstaller;

  @override
  Future<bool> startPlayUpdate({required bool immediate}) async {
    try {
      final info = await InAppUpdate.checkForUpdate();
      if (info.updateAvailability != UpdateAvailability.updateAvailable) {
        return false;
      }
      if (immediate) {
        if (!info.immediateUpdateAllowed) return false;
        await InAppUpdate.performImmediateUpdate();
        return true;
      }
      if (!info.flexibleUpdateAllowed) return false;
      final result = await InAppUpdate.startFlexibleUpdate();
      if (result == AppUpdateResult.success) {
        await InAppUpdate.completeFlexibleUpdate();
      }
      return true;
    } on PlatformException {
      return false;
    }
  }

  @override
  Future<bool> openUrl(String url) {
    return launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
  }
}

final appUpdatePlatformProvider = Provider<AppUpdatePlatform>(
  (Ref ref) => DeviceAppUpdatePlatform(),
);
