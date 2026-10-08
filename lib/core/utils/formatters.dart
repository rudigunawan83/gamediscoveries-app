import 'package:intl/intl.dart';

final NumberFormat _compact = NumberFormat.compact(locale: 'en_US');
final NumberFormat _grouped = NumberFormat.decimalPattern('en_US');

String formatCompact(num value) => _compact.format(value);

String formatGrouped(num value) => _grouped.format(value);

String formatTimeAgo(DateTime? time, {DateTime? now}) {
  if (time == null) return '';

  final diff = (now ?? DateTime.now()).difference(time.toLocal());
  if (diff.inMinutes < 1) return 'just now';
  if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
  if (diff.inHours < 24) return '${diff.inHours}h ago';
  if (diff.inDays < 7) return '${diff.inDays}d ago';
  return DateFormat('d MMM yyyy').format(time.toLocal());
}

String formatRemaining(DateTime? until, {DateTime? now}) {
  if (until == null) return '';

  final diff = until.toLocal().difference(now ?? DateTime.now());
  if (diff.isNegative) return 'Expired';
  if (diff.inDays >= 1) return '${diff.inDays}d ${diff.inHours % 24}h left';
  if (diff.inHours >= 1) return '${diff.inHours}h ${diff.inMinutes % 60}m left';
  return '${diff.inMinutes}m left';
}

DateTime? parseDate(Object? value) {
  return value is String ? DateTime.tryParse(value) : null;
}

int parseInt(Object? value) => (value as num?)?.toInt() ?? 0;

double parseDouble(Object? value) => (value as num?)?.toDouble() ?? 0;
