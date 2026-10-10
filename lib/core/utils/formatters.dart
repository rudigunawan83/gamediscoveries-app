import 'package:intl/intl.dart';

import '../../l10n/app_localizations.dart';

final Map<String, NumberFormat> _compact = <String, NumberFormat>{};
final Map<String, NumberFormat> _grouped = <String, NumberFormat>{};

/// `1.2K` / `1,2 rb`, following the active app language.
String formatCompact(AppLocalizations l10n, num value) => _compact
    .putIfAbsent(
      l10n.localeName,
      () => NumberFormat.compact(locale: l10n.localeName),
    )
    .format(value);

/// `12,345` / `12.345`, following the active app language.
String formatGrouped(AppLocalizations l10n, num value) => _grouped
    .putIfAbsent(
      l10n.localeName,
      () => NumberFormat.decimalPattern(l10n.localeName),
    )
    .format(value);

String formatTimeAgo(AppLocalizations l10n, DateTime? time, {DateTime? now}) {
  if (time == null) return '';

  final diff = (now ?? DateTime.now()).difference(time.toLocal());
  if (diff.inMinutes < 1) return l10n.timeJustNow;
  if (diff.inMinutes < 60) return l10n.timeMinutesAgo(diff.inMinutes);
  if (diff.inHours < 24) return l10n.timeHoursAgo(diff.inHours);
  if (diff.inDays < 7) return l10n.timeDaysAgo(diff.inDays);
  return DateFormat.yMMMd(l10n.localeName).format(time.toLocal());
}

/// Time left until [until] such as `2d 5h left`, or "Expired" once past.
String formatRemaining(
  AppLocalizations l10n,
  DateTime? until, {
  DateTime? now,
}) {
  if (until == null) return '';

  final diff = until.toLocal().difference(now ?? DateTime.now());
  if (diff.isNegative) return l10n.timeExpired;
  return l10n.timeLeft(_span(l10n, diff));
}

/// Time until [until] such as `2d 5h`; empty when unknown or already past.
String formatTimeUntil(
  AppLocalizations l10n,
  DateTime? until, {
  DateTime? now,
}) {
  if (until == null) return '';

  final diff = until.toLocal().difference(now ?? DateTime.now());
  return diff.isNegative ? '' : _span(l10n, diff);
}

String _span(AppLocalizations l10n, Duration diff) {
  if (diff.inDays >= 1) {
    return '${l10n.timeDays(diff.inDays)} ${l10n.timeHours(diff.inHours % 24)}';
  }
  if (diff.inHours >= 1) {
    return '${l10n.timeHours(diff.inHours)} '
        '${l10n.timeMinutes(diff.inMinutes % 60)}';
  }
  return l10n.timeMinutes(diff.inMinutes);
}

/// Play time such as `1h 5m`, `12m` or `<1m`.
String formatPlayTime(AppLocalizations l10n, int seconds) {
  if (seconds < 60) return l10n.timeUnderMinute;
  final hours = seconds ~/ 3600;
  final minutes = (seconds % 3600) ~/ 60;
  if (hours == 0) return l10n.timeMinutes(minutes);
  return minutes == 0
      ? l10n.timeHours(hours)
      : '${l10n.timeHours(hours)} ${l10n.timeMinutes(minutes)}';
}

DateTime? parseDate(Object? value) {
  return value is String ? DateTime.tryParse(value) : null;
}

int parseInt(Object? value) => (value as num?)?.toInt() ?? 0;

double parseDouble(Object? value) => (value as num?)?.toDouble() ?? 0;
