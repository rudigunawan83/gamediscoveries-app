import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/app_update_platform.dart';
import '../data/app_update_repository.dart';
import '../domain/app_release.dart';

class AppUpdateOffer {
  const AppUpdateOffer({
    required this.release,
    required this.urgency,
    required this.fromPlayStore,
  });

  final AppRelease release;
  final UpdateUrgency urgency;

  /// Play installs update through Google Play; APK installs download the
  /// new APK from our site.
  final bool fromPlayStore;

  bool get isRequired => urgency == UpdateUrgency.required;
}

/// Null when the app is up to date, the platform has no update channel, or
/// the check failed (a failed check never blocks the app).
final appUpdateOfferProvider = FutureProvider<AppUpdateOffer?>((Ref ref) async {
  final device = ref.watch(appUpdatePlatformProvider);
  final platform = device.platform;
  if (platform == null) return null;

  final AppRelease release;
  try {
    release = await ref.watch(appUpdateRepositoryProvider).getRelease(platform);
  } catch (_) {
    return null;
  }

  final urgency = release.urgencyFor(await device.currentBuild());
  if (urgency == UpdateUrgency.none) return null;

  return AppUpdateOffer(
    release: release,
    urgency: urgency,
    fromPlayStore: await device.installedFromPlayStore(),
  );
}, retry: (int retryCount, Object error) => null);
