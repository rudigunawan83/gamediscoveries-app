import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gamediscoveries_mobile/core/errors/error_messages.dart';
import 'package:gamediscoveries_mobile/core/l10n/locale_resolution.dart';
import 'package:gamediscoveries_mobile/core/network/api_exception.dart';
import 'package:gamediscoveries_mobile/core/utils/formatters.dart';

void main() {
  final en = lookupAppLocalizations(const Locale('en'));
  final id = lookupAppLocalizations(const Locale('id'));
  final now = DateTime(2026, 10, 10, 12);

  test('formatTimeAgo is relative and localized', () {
    expect(formatTimeAgo(en, now, now: now), 'just now');
    expect(formatTimeAgo(id, now, now: now), 'baru saja');
    expect(
      formatTimeAgo(en, now.subtract(const Duration(minutes: 5)), now: now),
      '5m ago',
    );
    expect(
      formatTimeAgo(id, now.subtract(const Duration(hours: 3)), now: now),
      '3 jam lalu',
    );
    expect(
      formatTimeAgo(id, now.subtract(const Duration(days: 2)), now: now),
      '2 hr lalu',
    );
    expect(formatTimeAgo(en, null, now: now), '');
  });

  test('formatRemaining and formatTimeUntil use localized units', () {
    final until = now.add(const Duration(days: 1, hours: 4));
    expect(formatRemaining(en, until, now: now), '1d 4h left');
    expect(formatRemaining(id, until, now: now), 'sisa 1 hr 4 j');
    expect(
      formatRemaining(id, now.subtract(const Duration(minutes: 1)), now: now),
      'Berakhir',
    );
    expect(
      formatTimeUntil(id, now.add(const Duration(minutes: 45)), now: now),
      '45 mnt',
    );
    expect(formatTimeUntil(en, null, now: now), '');
  });

  test('numbers follow the locale separators', () {
    expect(formatGrouped(en, 12500), '12,500');
    expect(formatGrouped(id, 12500), '12.500');
    expect(formatCompact(en, 1500), '1.5K');
    expect(formatCompact(id, 1500), '1,5\u00a0rb');
  });

  test('friendlyErrorMessage maps status codes per locale', () {
    const server = ApiException(message: 'boom', statusCode: 503);
    const offline = ApiException(message: 'x', type: 'connectionError');
    expect(
      friendlyErrorMessage(id, server),
      'Server kami sedang bermasalah. Silakan coba lagi nanti.',
    );
    expect(
      friendlyErrorMessage(id, offline),
      startsWith('Kamu sedang offline'),
    );
    expect(
      friendlyErrorMessage(en, StateError('x')),
      isNot(contains('StateError')),
    );
  });
}
