import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

Map<String, dynamic> _arb(String name) =>
    jsonDecode(File('lib/l10n/$name').readAsStringSync())
        as Map<String, dynamic>;

Set<String> _messageKeys(Map<String, dynamic> arb) =>
    arb.keys.where((String key) => !key.startsWith('@')).toSet();

/// Widget property names whose string literals are shown to users.
final RegExp _visibleLiteral = RegExp(
  r"(?:\bText\(|TextSpan\(\s*text:|\b(?:tooltip|hintText|labelText|helperText|errorText|semanticLabel|semanticsLabel|label|title|subtitle|message):)\s*'[A-Za-z]",
);

/// Paths (file or folder prefix) whose literals are intentionally not
/// translated, with the reason.
const Map<String, String> _allowed = <String, String>{
  'lib/l10n/': 'generated localizations',
  'lib/app/app.dart': 'OS task switcher title is the brand name',
  'lib/shared/widgets/brand_logo.dart': 'brand wordmark',
  'lib/core/network/':
      'ApiException diagnostics; the UI shows friendlyErrorMessage instead',
};

void main() {
  final en = _arb('app_en.arb');
  final id = _arb('app_id.arb');

  test('Indonesian translates exactly the English keys', () {
    final enKeys = _messageKeys(en);
    final idKeys = _messageKeys(id);

    expect(enKeys.difference(idKeys), isEmpty, reason: 'missing in id');
    expect(idKeys.difference(enKeys), isEmpty, reason: 'unknown in id');
  });

  test('every translation is non-empty and keeps its placeholders', () {
    for (final key in _messageKeys(en)) {
      final value = id[key] as String;
      expect(value.trim(), isNotEmpty, reason: key);

      final meta = en['@$key'] as Map<String, dynamic>?;
      final placeholders =
          (meta?['placeholders'] as Map<String, dynamic>?)?.keys ??
          const <String>[];
      for (final name in placeholders) {
        expect(
          value.contains('{$name}') || value.contains('{$name,'),
          isTrue,
          reason: '$key is missing {$name} in id',
        );
      }
    }
  });

  test('UI code does not hardcode user-facing text', () {
    final offenders = <String>[];
    final files = Directory('lib')
        .listSync(recursive: true)
        .whereType<File>()
        .where((File f) => f.path.endsWith('.dart'));

    for (final file in files) {
      final path = file.path.replaceAll(r'\', '/');
      if (_allowed.keys.any(path.startsWith)) continue;
      final source = file.readAsStringSync();
      for (final match in _visibleLiteral.allMatches(source)) {
        final line = '\n'.allMatches(source.substring(0, match.start)).length;
        offenders.add('$path:${line + 1}');
      }
    }

    expect(offenders, isEmpty);
  });
}
