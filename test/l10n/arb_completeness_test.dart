import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

Map<String, dynamic> _readArb(String locale) =>
    jsonDecode(File('lib/l10n/app_$locale.arb').readAsStringSync())
        as Map<String, dynamic>;

Set<String> _messageKeys(Map<String, dynamic> arb) =>
    arb.keys.where((String key) => !key.startsWith('@')).toSet();

/// Top-level ICU arguments such as `{count}` or `{count, plural, ...}`.
Set<String> _arguments(String message) {
  final names = <String>{};
  var depth = 0;
  for (var i = 0; i < message.length; i++) {
    final char = message[i];
    if (char == '{') {
      if (depth == 0) {
        final match = RegExp(r'^\{\s*(\w+)').firstMatch(message.substring(i));
        if (match != null) names.add(match.group(1)!);
      }
      depth++;
    } else if (char == '}') {
      depth--;
    }
  }
  return names;
}

void main() {
  final en = _readArb('en');
  final id = _readArb('id');

  test('every English key is translated to Indonesian and vice versa', () {
    final missingInId = _messageKeys(en).difference(_messageKeys(id));
    final extraInId = _messageKeys(id).difference(_messageKeys(en));
    expect(missingInId, isEmpty, reason: 'Missing in app_id.arb');
    expect(extraInId, isEmpty, reason: 'Unknown keys in app_id.arb');
  });

  test('no translation is left empty', () {
    for (final arb in <Map<String, dynamic>>[en, id]) {
      for (final key in _messageKeys(arb)) {
        expect((arb[key] as String).trim(), isNotEmpty, reason: key);
      }
    }
  });

  test('translations use the same placeholders as English', () {
    for (final key in _messageKeys(en)) {
      expect(
        _arguments(id[key] as String),
        _arguments(en[key] as String),
        reason: key,
      );
    }
  });

  test('keys are semantic camelCase identifiers', () {
    for (final key in _messageKeys(en)) {
      expect(key, matches(RegExp(r'^[a-z][a-zA-Z0-9]+$')), reason: key);
    }
  });
}
