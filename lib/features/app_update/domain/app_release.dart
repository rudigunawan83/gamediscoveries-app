enum UpdateUrgency { none, optional, required }

/// Release info from `GET /api/v1/app/version`. Builds are integer build
/// numbers (Android versionCode, the part after `+` in pubspec `version`).
class AppRelease {
  const AppRelease({
    required this.latestVersion,
    required this.latestBuild,
    required this.minSupportedBuild,
    this.storeUrl,
    this.apkUrl,
    this.releaseNotes,
  });

  factory AppRelease.fromJson(Map<String, dynamic> json) {
    return AppRelease(
      latestVersion: json['latestVersion'] as String? ?? '',
      latestBuild: (json['latestBuild'] as num?)?.toInt() ?? 0,
      minSupportedBuild: (json['minSupportedBuild'] as num?)?.toInt() ?? 0,
      storeUrl: json['storeUrl'] as String?,
      apkUrl: json['apkUrl'] as String?,
      releaseNotes: json['releaseNotes'] as String?,
    );
  }

  final String latestVersion;
  final int latestBuild;
  final int minSupportedBuild;
  final String? storeUrl;
  final String? apkUrl;
  final String? releaseNotes;

  UpdateUrgency urgencyFor(int currentBuild) {
    if (currentBuild <= 0) return UpdateUrgency.none;
    if (currentBuild < minSupportedBuild) return UpdateUrgency.required;
    if (currentBuild < latestBuild) return UpdateUrgency.optional;
    return UpdateUrgency.none;
  }
}
